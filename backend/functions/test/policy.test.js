import test from 'node:test';
import assert from 'node:assert/strict';
import { BUNDLE_ID, PRODUCT_PREFIX, PREMIUM_ID, canAccess, validateQuiz, publicRelease, validID } from '../src/policy.js';
const productID = `${PRODUCT_PREFIX}.quiz.example`;
const purchase = { bundleId: BUNDLE_ID, PRODUCT_PREFIX, productId: productID, type: 'Non-Consumable' };
const premium = { bundleId: BUNDLE_ID, PRODUCT_PREFIX, productId: PREMIUM_ID, type: 'Auto-Renewable Subscription', expiresDate: 2000 };

test('individual ownership grants only that quiz and revocation removes it', () => {
  assert.equal(canAccess(purchase, productID, 1000), true);
  assert.equal(canAccess(purchase, 'different', 1000), false);
  assert.equal(canAccess({ ...purchase, revocationDate: 500 }, productID, 1000), false);
  assert.equal(canAccess({ ...purchase, bundleId: 'other' }, productID, 1000), false);
});
test('premium expires, honours billing grace, and rejects revoked/upgraded access', () => {
  assert.equal(canAccess(premium, productID, 1000), true);
  assert.equal(canAccess(premium, productID, 2000), false);
  assert.equal(canAccess(premium, productID, 2000, 3000), true);
  assert.equal(canAccess(premium, productID, 3000, 3000), false);
  assert.equal(canAccess({ ...premium, revocationDate: 1 }, productID, 1000, 3000), false);
  assert.equal(canAccess({ ...premium, isUpgraded: true }, productID, 1000), false);
});
test('catalogue never exposes paid questions, descriptions or editorial data', () => {
  const result = publicRelease({ id: 'example', questions: ['secret'], resultDescriptions: {}, approved: true, productionMinutes: 40 }, 1000);
  assert.deepEqual(Object.keys(result).sort(), ['id', 'title', 'image', 'productID', 'subtitle', 'releasedAt'].sort());
});
test('invalid document paths are rejected', () => {
  for (const id of ['../secret', 'a/b', '', null, 'A', 'x'.repeat(81)]) assert.equal(validID(id), false);
});
test('publication requires ten complete questions and distinct, illustrated results', () => {
  // Synthetic fixture: editorial drafts are private and are not part of the repository.
  const profiles = [1, 2, 3, 4].map(answer => [`Result ${answer}`, Array(10).fill(answer)]);
  const quiz = {
    id: 'example', title: 'Validation fixture', image: 'fixture', productID,
    questions: Array.from({ length: 10 }, (_, index) => ({
      number: index + 1, question: `Question ${index + 1}`,
      answers: { 1: 'First', 2: 'Second', 3: 'Third', 4: 'Fourth' }
    })),
    matchingResults: Object.fromEntries(profiles),
    resultDescriptions: Object.fromEntries(profiles.map(([name]) => [name, 'Fixture description'])),
    resultImages: Object.fromEntries(profiles.map(([name]) => [name, 'fixture']))
  };
  assert.equal(validateQuiz(quiz), quiz);
  assert.throws(() => validateQuiz({ ...quiz, questions: quiz.questions.slice(1) }), /ten questions/);
  assert.throws(() => validateQuiz({ ...quiz, questions: [
    { ...quiz.questions[0], answers: { 1: 'Only one' } }, ...quiz.questions.slice(1)
  ] }), /Four answers/);
  assert.throws(() => validateQuiz({ ...quiz, matchingResults: {
    ...quiz.matchingResults, 'Result 2': quiz.matchingResults['Result 1']
  } }), /Duplicate result profile/);
  assert.throws(() => validateQuiz({ ...quiz, resultImages: {} }), /Missing result/);
  assert.throws(() => validateQuiz({ ...quiz, resultDescriptions: {} }), /Missing result/);
  assert.throws(() => validateQuiz({ ...quiz, productID: `${PRODUCT_PREFIX}.quiz.other` }), /Product ID/);
});
