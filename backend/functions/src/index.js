import { readFileSync } from 'node:fs';
import { initializeApp } from 'firebase-admin/app';
import { getFirestore, Timestamp, FieldValue } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import { onRequest } from 'firebase-functions/v2/https';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { defineSecret } from 'firebase-functions/params';
import { AppStoreServerAPIClient, Environment, SignedDataVerifier } from '@apple/app-store-server-library';
import { APP_ID, BUNDLE_ID, PREMIUM_ID, canAccess, validID, validateQuiz, publicRelease, deliverableQuiz } from './policy.js';

initializeApp();
const db = getFirestore();
const signingKey = defineSecret('APPLE_SIGNING_KEY');
const keyID = defineSecret('APPLE_KEY_ID');
const issuerID = defineSecret('APPLE_ISSUER_ID');
const secrets = [signingKey, keyID, issuerID];
const region = 'europe-west1';

function verifier(environment) {
  const roots = ['AppleRootCA-G2.cer', 'AppleRootCA-G3.cer'].map(file => readFileSync(new URL(`../certs/${file}`, import.meta.url)));
  return new SignedDataVerifier(roots, true, environment, BUNDLE_ID, APP_ID);
}

async function verifiedProof(jws) {
  // Both are Apple-verified; sandbox is necessary for TestFlight/App Review.
  for (const environment of [Environment.PRODUCTION, Environment.SANDBOX]) {
    const verify = verifier(environment);
    try { return { transaction: await verify.verifyAndDecodeTransaction(jws), verify, environment }; }
    catch { /* Try the other Apple environment, never decode without verification. */ }
  }
  throw new Error('Unverified transaction');
}

export const paidQuiz = onRequest({ region, secrets, maxInstances: 10, timeoutSeconds: 30 }, async (req, res) => {
  res.set('Cache-Control', 'private, no-store');
  if (req.method !== 'POST') return res.status(405).end();
  const { quizID, signedTransaction } = req.body ?? {};
  if (!validID(quizID) || typeof signedTransaction !== 'string' || signedTransaction.length > 30000) return res.status(400).end();
  try {
    const [release, content] = await Promise.all([
      db.doc(`quizReleases/${quizID}`).get(), db.doc(`paidQuizzes/${quizID}`).get()
    ]);
    if (!release.exists || !content.exists || release.data().releasedAt.toMillis() > Date.now()) return res.status(404).end();
    const quiz = content.data();
    const { transaction, verify, environment } = await verifiedProof(signedTransaction);
    if (![quiz.productID, PREMIUM_ID].includes(transaction.productId) || !transaction.transactionId) return res.status(403).end();
    const client = new AppStoreServerAPIClient(signingKey.value(), keyID.value(), issuerID.value(), BUNDLE_ID, environment);
    // Ask Apple again to reject refunded/revoked purchases even if an old JWS is replayed.
    const latest = await client.getTransactionInfo(transaction.transactionId);
    const current = await verify.verifyAndDecodeTransaction(latest.signedTransactionInfo);
    let allowed = false;
    if (current.productId === PREMIUM_ID) {
      const response = await client.getAllSubscriptionStatuses(current.originalTransactionId);
      for (const group of response.data ?? []) {
        for (const item of group.lastTransactions ?? []) {
          if (![1, 4].includes(item.status)) continue; // Active or billing grace.
          const active = await verify.verifyAndDecodeTransaction(item.signedTransactionInfo);
          const renewal = await verify.verifyAndDecodeRenewalInfo(item.signedRenewalInfo);
          if (active.originalTransactionId !== current.originalTransactionId) continue;
          allowed ||= canAccess(active, quiz.productID, Date.now(), item.status === 4 ? renewal.gracePeriodExpiresDate : undefined);
        }
      }
    } else {
      allowed = canAccess(current, quiz.productID);
    }
    if (!allowed) return res.status(403).end();
    return res.json(deliverableQuiz(quiz, release.data().releasedAt.toMillis()));
  } catch {
    // Never log signed purchase proofs, raw Apple responses, or quiz answers.
    return res.status(503).json({ error: 'Content temporarily unavailable' });
  }
});

// Friday, 18:00 Paris, including daylight-saving changes. Only reviewed, due drafts publish.
export const publishWeeklyQuiz = onSchedule({ region, schedule: '0 18 * * 5', timeZone: 'Europe/Paris', retryCount: 3 }, async () => {
  const due = await db.collection('quizDrafts').where('approved', '==', true)
    .where('releaseAt', '<=', Timestamp.now()).orderBy('releaseAt').limit(1).get();
  if (due.empty) return;
  const draft = due.docs[0];
  const quiz = validateQuiz(draft.data());
  const releasedAt = Timestamp.now();
  await db.runTransaction(async tx => {
    const latest = await tx.get(draft.ref);
    const existing = await tx.get(db.doc(`quizReleases/${quiz.id}`));
    const free = await tx.get(db.doc(`quizzes/${quiz.id}`));
    if (!latest.exists || !latest.data().approved || latest.data().releaseAt.toMillis() > Date.now()
      || existing.exists || free.exists) return;
    validateQuiz(latest.data());
    // The transaction publishes metadata only after private content exists atomically.
    tx.create(db.doc(`paidQuizzes/${quiz.id}`), deliverableQuiz(latest.data(), releasedAt));
    tx.create(db.doc(`quizReleases/${quiz.id}`), publicRelease(latest.data(), releasedAt));
    tx.update(draft.ref, { approved: false, publishedAt: releasedAt });
  });
});

export const notifyQuizRelease = onDocumentCreated({ region, document: 'quizReleases/{quizID}', retry: true }, async event => {
  const quiz = event.data?.data();
  if (!quiz || !validID(quiz.id) || quiz.releasedAt.toMillis() > Date.now()) return;
  const content = await db.doc(`paidQuizzes/${quiz.id}`).get();
  if (!content.exists) return;
  const delivery = db.doc(`notificationDeliveries/${quiz.id}`);
  // Claim before sending: Firestore trigger retries must not send duplicate promotions.
  try { await delivery.create({ state: 'sending', createdAt: FieldValue.serverTimestamp() }); }
  catch (error) { if (error.code === 6) return; throw error; }
  try {
    const messageID = await getMessaging().send({
      topic: 'weekly_quizzes_fr',
      notification: { title: 'Un nouveau quiz est disponible !', body: `${quiz.title} · Inclus avec Premium ou disponible à l’achat.` },
      data: { quiz_id: quiz.id },
      apns: { headers: { 'apns-collapse-id': quiz.id }, payload: { aps: { sound: 'default' } } }
    });
    await delivery.update({ state: 'sent', messageID, sentAt: FieldValue.serverTimestamp() });
  } catch (error) {
    await delivery.delete();
    throw error;
  }
});

// Configure this URL for App Store Server Notifications V2 (production and sandbox).
export const appleNotifications = onRequest({ region, maxInstances: 5 }, async (req, res) => {
  if (req.method !== 'POST') return res.status(405).end();
  const payload = req.body?.signedPayload;
  if (typeof payload !== 'string' || payload.length > 100000) return res.status(400).end();
  let notification;
  for (const environment of [Environment.PRODUCTION, Environment.SANDBOX]) {
    try { notification = await verifier(environment).verifyAndDecodeNotification(payload); break; }
    catch { /* Only verified Apple notifications are recorded. */ }
  }
  if (!notification?.notificationUUID) return res.status(403).end();
  try {
    await db.doc(`subscriptionEvents/${notification.notificationUUID}`).create({
      type: notification.notificationType ?? 'UNKNOWN', subtype: notification.subtype ?? null,
      environment: notification.data?.environment ?? 'UNKNOWN',
      signedDate: notification.signedDate, receivedAt: FieldValue.serverTimestamp(),
      // Retain pilot lifecycle measurements for one year; Firestore TTL removes them.
      expiresAt: Timestamp.fromMillis(Date.now() + 365 * 24 * 60 * 60 * 1000)
    });
  } catch (error) { if (error.code !== 6) return res.status(503).end(); }
  return res.status(200).end();
});
