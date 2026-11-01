import { readFileSync } from 'node:fs';
import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { validateQuiz } from './policy.js';

const [file, releaseDate, ...flags] = process.argv.slice(2);
if (!file || !releaseDate) {
  console.error('Usage: node src/upload-draft.js FILE ISO_DATE_WITH_OFFSET [--upload --project=PROJECT_ID] [--approve]');
  process.exit(1);
}
if (!/(Z|[+-]\d{2}:\d{2})$/.test(releaseDate) || !Number.isFinite(Date.parse(releaseDate))) throw new Error('Specify an ISO date with explicit timezone');
const quiz = validateQuiz(JSON.parse(readFileSync(file, 'utf8')));
const date = new Date(releaseDate);
const paris = new Intl.DateTimeFormat('en-GB', { timeZone: 'Europe/Paris', weekday: 'short', hour: '2-digit', minute: '2-digit', hourCycle: 'h23' }).formatToParts(date);
const part = type => paris.find(p => p.type === type)?.value;
if (part('weekday') !== 'Fri' || part('hour') !== '18' || part('minute') !== '00') throw new Error('Release must be Friday at 18:00 Europe/Paris');
if (date <= new Date()) throw new Error('Choose a future release');
const approved = flags.includes('--approve');
if (!flags.includes('--upload')) {
  console.log(`Valid draft: ${quiz.id}; release ${date.toISOString()}; approved=${approved}. Dry run only.`);
  process.exit(0);
}
const projectId = flags.find(flag => flag.startsWith('--project='))?.slice('--project='.length);
if (!projectId) throw new Error('Explicit --project required; no implicit production destination');
initializeApp({ credential: applicationDefault(), projectId });
const db = getFirestore();
await db.runTransaction(async tx => {
  const free = await tx.get(db.doc(`quizzes/${quiz.id}`));
  const release = await tx.get(db.doc(`quizReleases/${quiz.id}`));
  if (free.exists || release.exists) throw new Error('This quiz is already published; refusing to replace it');
  tx.set(db.doc(`quizDrafts/${quiz.id}`), { ...quiz, approved, releaseAt: Timestamp.fromDate(date) });
});
console.log(`Uploaded ${quiz.id} to ${projectId}. ${approved ? 'Approved for the scheduled release.' : 'Not approved: will not publish.'}`);
