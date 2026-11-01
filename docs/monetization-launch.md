# Weekly quiz pilot — implementation and launch

The app implements the agreed free / €0.99 permanent quiz / €1.99 monthly Premium offers. Individual ownership keeps banners. Premium unlocks all released paid quizzes and removes banners. A cancelled subscription stays usable until its entitlement ends; individual purchases survive expiry. Prices shown in the app come exclusively from StoreKit.

Purchases and production ads are OFF in `Qui-es-tu-Info.plist` until the external setup below is complete. Firebase Hosting and restricted Firestore rules are deployed. Four private drafts are uploaded, and all four Cloud Functions are deployed and ACTIVE. The weekly scheduler is enabled, but no draft is approved or scheduled. No release notification has been sent. Existing uncommitted quiz/analytics work has been preserved.

## 1. Apple purchases

The following subscription group/product and four non-consumables are created in App Store Connect, but remain unsubmitted. Configuration reference:

- `com.lucasamelin.quiestu.premium.monthly` — reference price €1.99/month in France.

Create non-consumable products, €0.99 each in France:

- `com.lucasamelin.quiestu.quiz.bande`
- `com.lucasamelin.quiestu.quiz.superpouvoir`
- `com.lucasamelin.quiestu.quiz.escapade`
- `com.lucasamelin.quiestu.quiz.soiree`

Use the same pattern for future releases: `com.lucasamelin.quiestu.quiz.<quiz-id>`. Never reassign an existing product ID to another quiz. Complete availability, localized descriptions, review screenshots, paid agreements, and banking/tax setup in App Store Connect. Product descriptions must say that individual quizzes retain ads. Do not enable introductory offers or annual plans for this pilot.

The app only grants access from verified StoreKit current entitlements, including billing grace. Restore purchases is available in the paywall and settings. The signed transaction is sent over HTTPS to the content service; that service checks Apple again for revocations and current subscription status. No separate user account or stored answer profile is required.

`Qui es tuTests/Pilot.storekit` provides local test products and is selected in the shared scheme's Debug Run action. The `Pilot` test plan runs tests serially because StoreKit's test environment is shared. For real sandbox testing from Xcode, set Run → Options → StoreKit Configuration to None; the local configuration does not apply to archived App Store builds. Local StoreKit transactions are intentionally rejected by the production server; use sandbox/TestFlight purchases for the complete paid download test.

## 2. Firebase backend and weekly publication

The backend lives in `backend/`. Use Node 22, install with `npm ci` in `backend/functions`, and select the intended Firebase project explicitly. Deployment requires a billing-enabled Firebase project for Functions/Scheduler. Do not overwrite unrelated Firestore rules: merge the supplied rules with any existing rules first.

Collections:

| Collection | Access and purpose |
|---|---|
| `quizzes` | Existing public free catalogue, compatible with old app versions |
| `quizReleases` | Public metadata only: ID, title, image, subtitle, product ID, release timestamp |
| `paidQuizzes` | Private questions, matching profiles, descriptions, artwork references |
| `quizDrafts` | Private reviewed publication queue and editorial time/notes |
| `notificationDeliveries` | Private notification delivery status |
| `subscriptionEvents` | Private verified Apple lifecycle events, without purchase proofs |

Create Secret Manager values `APPLE_SIGNING_KEY` (complete In-App Purchase .p8 key), `APPLE_KEY_ID`, and `APPLE_ISSUER_ID` using Firebase's secret setup. Do not place them in the repository. Apple trust roots are bundled from Apple's certificate authority in `functions/certs/`; they are public certificates, not credentials.

Deploy the functions, merged rules, and index using Firebase CLI with `--project <project-id>`. Configure App Store Server Notifications V2 production and sandbox URLs to the deployed `appleNotifications` function. Put the deployed `paidQuiz` URL in `QuizPaidContentURL`. TestFlight sandbox receipts are supported and metrics distinguish sandbox from production.

The publisher runs Friday at 18:00 Europe/Paris. It publishes one approved due draft, writing private content and public metadata atomically. The release trigger sends the notification only after content exists. Metadata is refreshed on app foreground and pull-to-refresh. Artwork can reference an existing bundled asset or an HTTPS image URL, allowing new releases without app updates. Keep image URLs available for the lifetime of purchased quizzes.

The four local JSON files in `content/pilot/` contain ten questions, four complete portraits, existing artwork references, a social post draft, and editorial fields. This directory is deliberately excluded from Git until the owner approves sharing its content; a fresh checkout does not include the drafts. Backend tests use synthetic content instead. The private drafts are **not approved** and have no release dates. Read every question, play through each profile, check artwork and tone, then set four consecutive Friday dates. Enter your actual `productionMinutes`; do not invent production cost data.

Validate without writing to Firebase:

```sh
cd backend/functions
node src/upload-draft.js ../../content/pilot/01-bande.json 2026-11-06T18:00:00+01:00
```

Choose future dates when launching. Upload a draft by adding `--upload --project=<project-id>`. Add `--approve` only after your personal review and the corresponding Apple product is available. Without approval it will not publish. The publisher and uploader refuse to overwrite free or already released quizzes.

Monitor Cloud Functions failures, due drafts, and `notificationDeliveries`. FCM does not offer exactly-once delivery: the claim prevents ordinary duplicate trigger sends, but a crash can leave a `sending` record for manual investigation, and a failure after FCM accepts a message can cause a retry. Do not blindly retry a claimed promotion. Use a staging project for publication and delivery tests.

## 3. Banners and notifications

Google Mobile Ads 13.11.0 and Google's UMP consent library are integrated. The AdMob app and banner unit have been created and their real IDs are configured in the plist. Configure the required privacy messages and review banner refresh/content controls. Production ads refuse test IDs. Set `QuizAdsEnabled=true` only after verification and publishing the privacy policy.

Banners appear on the home and completed result screens only, with space around controls. Questions, the reveal, paywall, and exported cards contain no banners. Ads wait for entitlement resolution and UMP permission; errors leave quizzes usable. Requests are non-personalized, with no ATT tracking request. Non-personalized ads still require appropriate consent handling. Confirm the chosen AdMob settings/SDK data usage match the no-tracking configuration; if introducing tracking later, implement ATT before doing so.

To test Google's sample banner in a Debug run, use `-adTesting` without `-uiTesting`. Release builds ignore that argument. Use Google's test devices/ads during QA, never click live ads. Settings shows privacy options when UMP requires them. Test EEA consent, refusal, no-fill, network loss, small screens, and a Premium purchase while a banner is visible.

Enable Push Notifications for the app identifier and signing profile, and upload an APNs key in Firebase Cloud Messaging. The entitlement is included; a physical-device/TestFlight check is still required. Firebase messaging auto-initialization is off until opt-in. The result-screen prompt explicitly covers paid releases; settings offers an off switch and an iOS Settings link after denied permission. The app subscribes opted-in devices to `weekly_quizzes_fr`; disabling unregisters remote notifications and retries topic removal as needed. Notification taps route through the same purchase gate as normal quiz taps.

## 4. Privacy, pilot measurements, and release gates

The pilot privacy policy is published at <https://over-tech-apps.pages.dev/apps/qui-es-tu/privacy/> and configured in `QuizPrivacyURL`. The in-app privacy summary remains a fallback. Update App Store privacy answers for Analytics, Crashlytics, Messaging, and Mobile Ads before submitting the next version. Retention settings and rights/contact information are documented in `docs/privacy-policy.fr.md`.

After the backend, product availability, and privacy URL are verified, set `QuizPurchasesEnabled=true`. Missing required configuration disables purchase buttons. Rebuild and test both Debug and Release. The code does not create an account or collect quiz answers in analytics. Last 100 completed portraits are stored locally and can be erased in settings; local history is not an entitlement cache.

Metrics:

- Existing `quiz_started`, `quiz_completed`, `quiz_exited`: completion rate by quiz.
- `weekly_visit`: weekly returning visits, using a local previous-week marker.
- `paywall_viewed`, `purchase_verified`: funnel indicators; use App Store Connect for authoritative sales/proceeds and conversion reporting.
- `result_share_opened`: share-sheet intent, not confirmed external delivery or referral conversion.
- `banner_impression`, `banner_revenue`: AdMob impression-level estimated revenue, value and currency. Reconcile with AdMob reports.
- `subscriptionEvents`: verified SUBSCRIBED / DID_RENEW / EXPIRED etc.; filter `Production` and deduplicate on notification UUID. App Store reports remain the source for actual revenue.
- Draft `productionMinutes`: real editorial effort. Record AI, hosting, and artwork invoices separately.

Review after eight weeks from actual launch. Subscription gross examples: 100 × €1.99 = €199/month; 500 × €1.99 = €995/month, before taxes, store fees and costs. Report individual purchases and ads separately and compare actual proceeds with recurring expenses and your time. Extend the pilot if traffic is insufficient.

Before release verify real-device restore/reinstall, pending purchases, refund/revocation, subscription expiry/grace, retained individual ownership with banners, rejected tampered/expired proofs, consent refusal, notification off/on, paid notification routing, and clean exported cards. The automatic test suite covers local entitlement behaviour, content validation, persistence, and core UI; it cannot replace live Apple/AdMob/APNs setup checks.

## Implementation verification — 31 October 2026

- Debug test build and Release simulator build succeed.
- 34 existing unit tests and six new access/history/replay tests pass.
- Four simulator UI tests pass, including the Premium copy, privacy navigation, complete quiz flow, and sharing control. Screenshots were inspected; an unreadable share-button label was corrected.
- Five backend policy/content tests pass. The four drafts validate and their bundled artwork exists. Backend dependency audit reports no vulnerabilities.
- The local StoreKit individual ownership/recreation/refund integration test passes. Two StoreKit integration tests remain failing on the iOS 27.1 simulator: forced subscription expiry still returns Premium in current entitlements, and product prices return integer values instead of the configured fractional prices. These assertions remain enabled; do not treat the purchase flow as fully validated or enable production sales until they pass and the sandbox/device checks above are complete.
- A cross-check on the installed iOS 26.5 runtime cannot initialize the local StoreKit environment (`SKInternalErrorDomain` code 3 / `notEntitled`). It does not establish whether the remaining iOS 27.1 failures are app or simulator defects.

Real ad delivery/consent, APNs device delivery and App Store restoration remain unverified. The deployed paid-content endpoint rejects invalid and unreleased requests; a valid sandbox purchase/download remains unverified. The app sales and ads switches remain off. See the current external setup below.


## External setup — 1 November 2026

### Completed and verified

- App Store Connect app **6740242586** (`com.lucasamelin.Qui-es-tu`): Premium group **22534150**, monthly subscription **6829437903**, France reference price **€1.99**, French product/group localizations, all 175 territories. Business/school distribution and multiseat are disabled. No annual plan or introductory offer.
- Four non-consumable products, each France **€0.99**, all territories and French descriptions stating “Accès permanent à ce quiz. Publicités conservées.”:
  - bande: **6829439229**
  - superpouvoir: **6829439649**
  - escapade: **6829440141**
  - soiree: **6829440441**
- Apple product IDs use `com.lucasamelin.quiestu`; hyphens are not accepted in product IDs. The existing bundle ID remains unchanged. Local app/backend/content/test IDs agree.
- All products remain drafts, without submission or a new uploaded build. Review screenshots and sandbox validation are outstanding.
- AdMob linked app **7657247635**, app ID `ca-app-pub-3802123025791172~7657247635`, banner `ca-app-pub-3802123025791172/4975243978`, configured locally. Ads stay disabled.
- Over Tech Apps: <https://over-tech-apps.pages.dev/apps/qui-es-tu/> and verified <https://over-tech-apps.pages.dev/app-ads.txt>. The pilot privacy policy is published at <https://over-tech-apps.pages.dev/apps/qui-es-tu/privacy/> and linked in the app configuration.
- Firestore previously allowed every anonymous read and write. Restricted rules now permit public reads only for `quizzes` and `quizReleases`, deny client writes, and deny all access to private collections. Unauthenticated checks returned 200 for the public collections and 403 for `quizDrafts`/`paidQuizzes`. Previous rules are preserved in `backend/backups/` for audit; do not restore their insecure access.
- Four private drafts uploaded and read back: `approved=false`, `releaseAt=null`, correct product IDs. None has been released or scheduled.
- Analytics and Crashlytics are optional separate switches, off by default. Updated app builds successfully on the simulator.

### Launch status and remaining checks

1. Blaze is now enabled. All three Apple purchase secrets are stored in Firebase Secret Manager; all four functions are deployed and verified ACTIVE. `QuizPaidContentURL` is configured. The Friday 18:00 Europe/Paris scheduler is enabled. No drafts are approved or dated.
2. Production and sandbox Apple callbacks are saved and survived an App Store Connect reload. Initial Apple test requests returned 4040007 while settings propagated. Subsequent `requestTestNotification` requests succeeded for both environments, and `getTestNotificationStatus` reported SUCCESS for both. The backend verified and stored both signed TEST events. This validates the callback route, not an actual subscription purchase/renewal.
3. Complete real sandbox purchase/download/restoration and physical-device APNs delivery checks. Invalid callback signatures return 403; unknown/unreleased paid quiz requests return 404, but this does not establish the valid purchase/download flow.
4. The privacy page is published and visually checked. AdMob has a saved **draft** named “Qui es-tu — Consentement publicitaire Europe”, assigned only to app 6740242586, with the hosted privacy URL, French default plus English, and refusal enabled in all regions. Before publishing it, review the account-wide advertising-purpose/vendor defaults: its generated preview currently mentions 210 partners, personalised advertising and precise geolocation. Do not change shared defaults blindly because other apps use the same account. Align the message with this app’s non-personalized setup, then exercise UMP consent/refusal on a test device.
5. Use `https://over-tech-apps.pages.dev/apps/qui-es-tu/` as the next App Store version's marketing URL and `/apps/qui-es-tu/support/` for support, publish that metadata, and retry AdMob app-ads.txt verification. Hosting the file alone is insufficient while the live listing does not reference the domain.
6. Supply accurate review screenshots, finish App Store privacy answers and review metadata, and submit the products with a new app version only after the purchase checks pass.
7. The local StoreKit ownership/refund and expiry tests now pass. Expiry simulates cancelled renewal before forcing the paid period to end; it verifies retained individual ownership and restored banner eligibility. The fractional numeric-price assertions still fail on iOS 27.1 with both French and US locales. Diagnostic product JSON contains `priceString: "1,99"` and correct `priceFormatted` values (`1,99 €` / `€1.99`), while Product.price returns 1. The app uses Product.displayPrice. Assertions remain enabled; complete sandbox/device validation and resolve or isolate this SDK discrepancy before enabling sales or ads.
8. Owner personally reviews all four content drafts and chooses launch dates before any approval/publication. Actual production time remains to be recorded.


## Apple credential setup — 1 November 2026

- Owner explicitly authorized creation of dedicated purchase-validation and APNs keys and secure storage in Firebase.
- In-App Purchase key `NMPLT3AFFR`, named **Qui es-tu Pilot Server**, created and downloaded. Issuer ID remains the App Store Connect team issuer. Private material is outside the repository under the owner's protected local configuration directory (folder permissions 0700, files 0600); it has not been printed in tool output.
- APNs sandbox key `29UB94TLD4` (**QuiEstuPushSandbox**) and production key `ZAZZN495SW` (**QuiEstuPushProduction**) created with **Topic Specific** access to only `com.lucasamelin.Qui-es-tu`.
- Both keys uploaded and visibly confirmed in the correct Firebase iOS app, team `8LW7CGBRD9`. Existing keys for other apps were not modified.
- FCM HTTP v1 `validate_only=true` accepted the configured notification payload (HTTP 200). No device notification was sent; this does not establish end-to-end APNs delivery.
- Apple Push Notifications capability enabled on the existing app identifier. Apple requires signing profiles including that identifier to be regenerated for future builds; automatic Xcode signing should refresh them during the next device/archive build.
- After the owner enabled Blaze, all three purchase secrets were uploaded successfully as version 1 and the functions were deployed. The earlier Spark failure is resolved. Callback configuration and outstanding validation are described above.


## Deployment verification — 1 November 2026

- Firebase CLI 15.34.2 was installed in a task-local temporary directory to support Node 22; the owner’s global CLI was not replaced.
- `paidQuiz`, `appleNotifications`, `publishWeeklyQuiz`, and `notifyQuizRelease` are ACTIVE in `europe-west1`. First-use Eventarc permission propagation caused two failed attempts; the subsequent deployment succeeded with the existing service-agent role.
- Paid-content URL: <https://paidquiz-gbecdbsrma-ew.a.run.app>. Both Apple environments use <https://applenotifications-gbecdbsrma-ew.a.run.app>.
- Scheduler: `0 18 * * 5`, `Europe/Paris`, ENABLED. All four drafts were reread as `approved=false`, `releaseAt=null`; public releases and private published paid content remain empty. No release notification was sent.
- Firestore `subscriptionEvents.expiresAt` TTL is ACTIVE. Events are marked for expiry after 365 days, with asynchronous deletion. No purchase proofs or buyer IDs are stored in these documents.
- Endpoint checks: paid GET 405, malformed POST 400, unreleased quiz 404; Apple malformed POST 400 and invalid signed payload 403. Five backend tests and syntax checks pass. Plist syntax passes; the sales and ads flags remain false.
- Hosting privacy page returned HTTP 200 and its rendered layout was checked in Chrome. The app privacy and paid-content URLs point to these deployed resources.
- Apple callback delivery is validated in both environments: after initial configuration propagation errors, Apple reported SUCCESS for both signed TEST notifications. The verified events are stored privately with their environment and expiry timestamp. The local StoreKit numeric-price discrepancy and physical-device purchase/push checks remain launch gates.


## Canonical website and support — 1 November 2026

At the owner’s request, all public Qui es-tu pages use the existing Over Tech Apps website, with **overtechapps@gmail.com** as support/privacy contact. The privacy source is maintained in the `over-tech-apps` repository. Firebase Hosting now only redirects old public URLs to the corresponding Over Tech Apps pages; Firebase purchase-validation, notification services and private draft storage remain unchanged. The app configuration and fallback contact use the same canonical website/email. The developer-site root already has the matching AdMob `app-ads.txt` entry.

Verified after migration: Over Tech Apps app, support and privacy pages return HTTP 200 with `overtechapps@gmail.com`; old Firebase home/privacy/app-ads URLs return HTTP 301 to Over Tech Apps. The AdMob draft privacy URL was saved as the canonical Over Tech Apps URL. App Store Connect still displays the older Facebook privacy URL and explicitly locks editing until a new app version is created. Set the canonical privacy URL, support URL and marketing URL in that next-version draft before submission. No App Store version was created or submitted during this website correction.
