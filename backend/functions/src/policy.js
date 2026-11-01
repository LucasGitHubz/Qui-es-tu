export const PREMIUM_ID = 'com.lucasamelin.quiestu.premium.monthly';
export const PRODUCT_PREFIX = 'com.lucasamelin.quiestu';
export const BUNDLE_ID = 'com.lucasamelin.Qui-es-tu';
export const APP_ID = 6740242586;
export const validID = value => typeof value === 'string' && /^[a-z0-9][a-z0-9_-]{0,79}$/.test(value);

export function canAccess(transaction, productID, now = Date.now(), graceExpiresDate) {
  if (!transaction || transaction.bundleId !== BUNDLE_ID || transaction.revocationDate != null || transaction.isUpgraded) return false;
  if (transaction.productId === productID && transaction.type === 'Non-Consumable') return true;
  return transaction.productId === PREMIUM_ID && transaction.type === 'Auto-Renewable Subscription'
    && (transaction.expiresDate > now || graceExpiresDate > now);
}

export function validateQuiz(quiz) {
  if (!validID(quiz.id)) throw new Error('Invalid quiz ID');
  if (typeof quiz.title !== 'string' || !quiz.title.trim() || typeof quiz.image !== 'string' || !quiz.image.trim()) throw new Error('Missing title or image');
  if (quiz.productID !== `${PRODUCT_PREFIX}.quiz.${quiz.id}`) throw new Error('Product ID must match quiz ID');
  if (!Array.isArray(quiz.questions) || quiz.questions.length !== 10) throw new Error('Exactly ten questions required');
  quiz.questions.forEach((q, index) => {
    if (q.number !== index + 1 || typeof q.question !== 'string' || !q.question.trim()) throw new Error('Invalid question');
    if (!q.answers || Object.keys(q.answers).sort().join(',') !== '1,2,3,4' || Object.values(q.answers).some(a => typeof a !== 'string' || !a.trim())) throw new Error('Four answers required');
  });
  const entries = Object.entries(quiz.matchingResults ?? {});
  if (entries.length < 4) throw new Error('At least four results required');
  const profiles = new Set();
  for (const [name, answers] of entries) {
    if (!Array.isArray(answers) || answers.length !== 10 || answers.some(a => ![1, 2, 3, 4].includes(a))) throw new Error('Invalid matching profile');
    if (!quiz.resultDescriptions?.[name]?.trim() || !quiz.resultImages?.[name]?.trim()) throw new Error('Missing result copy or artwork');
    const key = answers.join(',');
    if (profiles.has(key)) throw new Error('Duplicate result profile');
    profiles.add(key);
  }
  return quiz;
}

export function publicRelease(quiz, releasedAt) {
  return { id: quiz.id, title: quiz.title, image: quiz.image, productID: quiz.productID,
    subtitle: quiz.subtitle ?? '', releasedAt };
}

export function deliverableQuiz(quiz, releasedAt) {
  return { ...publicRelease(quiz, releasedAt), questions: quiz.questions,
    matchingResults: quiz.matchingResults, resultDescriptions: quiz.resultDescriptions,
    resultImages: quiz.resultImages };
}
