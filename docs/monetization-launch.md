# Weekly quiz pilot — implementation and launch

The app implements the agreed free / €0.99 permanent quiz / €1.99 monthly Premium offers. Individual ownership keeps banners. Premium unlocks all released paid quizzes and removes banners. A cancelled subscription stays usable until its entitlement ends; individual purchases survive expiry. Prices shown in the app come exclusively from StoreKit.

The 1.2.0 build 10 configuration enables purchases and keeps production ads OFF in `Qui-es-tu-Info.plist`. Debug runs use Google test ads and provide a fake paid-quiz preview; both development controls are excluded from the archive. Firebase Hosting, restricted Firestore rules, and the four Cloud Functions are deployed. The weekly scheduler is enabled, but the private drafts are not approved or scheduled. The dated sections below record setup and remaining production checks.

### Build 10 release checks — 5 November 2026

- Signed iOS archive created; bundle/version/build verified as
  `com.lucasamelin.Qui-es-tu`, `1.2.0`, `10`. All 68 compiled bitmap assets pass
  validation at 1x/2x/3x; obsolete composite paywall artwork is no longer bundled.
- Initial full test run: 63 of 67 passed. The remaining UI test was corrected to
  scroll the notification prompt above the fixed footer and passed on rerun.
  StoreKit checks were rerun on iOS 27.1 because the installed iOS 26.5 CLI test
  service rejected test-session mutations.
- Final Release test pass covers bundled assets, image preparation, result-history
  deletion, purchase restoration/refunds, subscription expiry, and French/English
  monthly and individual prices. Test fixtures are independent of Debug previews.
- `ITSAppUsesNonExemptEncryption=false`: the app's cryptography is limited to
  secure service connections, platform-protected storage and cache-key hashes;
  it does not implement a separate encryption product. See Apple's
  [export-compliance guidance](https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance/).

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

`Qui es tuTests/Pilot.storekit` provides local test products, loaded explicitly by the automated StoreKit tests. The shared scheme's Debug Run action leaves StoreKit Configuration set to None so device runs can use Apple's sandbox for the complete paid download flow. The `Pilot` test plan runs tests serially because StoreKit's test environment is shared. For local purchase-only testing, temporarily select `Pilot.storekit` in Run → Options → StoreKit Configuration; reset it to None before testing paid downloads. Local StoreKit transactions are intentionally rejected by the production server; use sandbox/TestFlight purchases for the complete paid download test. The local configuration does not apply to archived App Store builds.

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


## Debug commerce preview — 5 November 2026

A normal Debug build now shows **Quiz payant de démonstration** near the top of
home. It opens the existing paywall with a fictional **Ton pouvoir secret** quiz,
€0.99 individual price and €1.99/month Premium price. Both buttons show a demo
confirmation; neither calls StoreKit, grants ownership, nor downloads paid content.
The preview works independently of product availability and existing ownership.
It does not test Apple's payment sheet or purchase verification. It is absent from
Release builds and is never written to the remote catalogue.

When real ads are disabled, Debug builds show a labeled placeholder at the normal
banner placements (below the home catalogue and on results), for non-Premium
users after ownership resolves. This is a layout preview, not an AdMob delivery or
consent test. The existing `-adTesting` argument still selects Google's test banner
and follows the consent flow.

Current local configuration has `QuizPurchasesEnabled=true` and
`QuizAdsEnabled=false`; older dated entries above describe the configuration at
the time of those checks. The enabled purchase flag alone does not establish
App Store product approval or a successful sandbox purchase. No live console
status, device push delivery, or real purchase validation was reverified as part
of this UI preview change. The outstanding external checks above still require
confirmation before treating the launch as complete.

Verification for this change: Debug simulator build and both targeted commerce UI
tests pass (demo offers/actions/banner and existing Premium/legal navigation).
The Release simulator build also succeeds; the debug quiz fixture identifier and
banner identifier are absent from its executable. This does not validate live
purchases, live ads, or push delivery.

An ordinary Debug launch without testing arguments was also checked on the iPhone
Duo simulator. The demo card is immediately visible. The live catalogue loads
“Quel serait ton familier ?” with a €0.99 product price, confirming catalogue and
price retrieval in that session. No real transaction was initiated; this observation
does not confirm App Store review/production availability or paid-content access.


## AdMob verification and integration — 5 November 2026

### Completed in the account

- AdMob account is approved. The intended app is **Qui es-tu / iOS / 6740242586**,
  AdMob app `7657247635` (not the separate old “Qui êtes-vous ?” entry).
- Published **Qui es-tu — Consentement publicitaire Europe** and verified its
  **Publié** status. It applies only to this app, targets EEA/UK/Switzerland,
  defaults to French with English available, and includes a first-screen refusal
  choice. Its privacy URL is the canonical Over Tech Apps page.
- Reviewed both language previews. Google's generated TCF wording describes the
  account's shared partner list and broader vendor purposes (including personalized
  ads and potential precise location). Those account-wide settings also affect
  AnimalDex and were not changed. This app continues to request only non-personalized
  ads, does not request ATT or location permission, and disables publisher first-party
  ID. Publishing the standard message does not change those app restrictions.
- Verified banner **Accueil et résultats — bannière** matches
  `ca-app-pub-3802123025791172/4975243978`, with Google-optimized automatic refresh.
  No mediation group or house campaign is attached.
- Retrieved the hosted `app-ads.txt`: HTTP success and exact expected line
  `google.com, pub-3802123025791172, DIRECT, f08c47fec0942fa0`.

### App changes and verification

- Ordinary Debug runs now use Google's sample banner automatically, without a
  launch argument. Automated UI fixtures/previews still suppress network ads.
  Release still uses the configured production ad unit and the `QuizAdsEnabled`
  switch. Debug never selects the production unit.
- The fixed 320 × 50 banner uses Google's fixed-size demo unit ending in
  `/2934735716`, matching `AdSizeBanner`, rather than the adaptive demo unit.
  Source: <https://developers.google.com/admob/ios/test-ads>.
  A Debug-only status panel exposes purchase/consent gating and SDK errors on
  physical devices, with a retry action that preserves consent choices. This
  corrects a configuration mismatch; it does not by itself establish the cause
  of a particular physical-device failure.
- Physical follow-up on **Sakana (iPhone Air)**: the previously installed build
  showed no banner at the bottom of Home. Installing the updated Debug build
  while preserving app data, then launching without arguments, displayed Google's
  **Test mode** banner and reported a successful load. The current purchase and
  consent state both permit ads. The original failure had no captured error, so
  its exact cause is not proven. The physical Debug build and Release simulator
  build passed; the Release executable excludes the new diagnostic view/retry.
  Manual retry also completed successfully without changing saved consent.
  The initial physical-device capture showed a black creative area labelled
  **Test mode** despite successful callbacks. The user confirmed VPN/ad-blocking
  network settings were active; after temporarily pausing them and retrying, the
  user confirmed the full banner appeared on Sakana. A subsequent device capture
  also verified the full Google creative on the same installed build. This isolates the black
  creative to that network setup, without identifying its exact filtering component.
- Added the 50 SKAdNetwork identifiers in Google's current official iOS setup
  list. Source: <https://developers.google.com/admob/ios/quick-start>.
- Fixed SDK initialization ordering: configure content rating and first-party ID,
  await SDK startup, then expose banner eligibility. Granting consent later from
  privacy settings follows the same initialization path. Privacy form actions are
  serialized; repeated taps cannot present competing forms.
- Added Debug-only `-adTesting -adConsentEEA -adConsentReset` for reproducible
  first-launch EEA checks. Without `-adConsentReset`, saved choices are preserved.
  Simulators are UMP test devices automatically. On a physical test device, use
  `QUI_AD_TEST_DEVICE_ID` with the device's UMP test identifier. These debugging
  options are absent from Release behavior.
- Exercised the real Google UMP service on the iOS 26.5 simulator: initial EEA
  form, refusal, reopening privacy settings, acceptance, relaunch persistence,
  and subsequent consent withdrawal. Google's test banner rendered successfully.
  After withdrawal, the SDK stored zero purpose consents; UMP can still permit
  limited ads. Banner visibility alone does not mean personalized-ad consent.
- The final live UI test passed, including an ordinary Debug launch without
  arguments and a visibly rendered Google test banner. Consent checks targeted
  presented WebViews because UMP also retains offscreen preloaded forms. No
  missing SKAdNetwork warnings were observed. No real ad was clicked and no real
  revenue was tested. The temporary network-dependent test is not part of the
  regular test suite.
- Debug UI verification and the Release simulator build succeeded. The built
  Release plist contains all 50 ad-network entries and keeps production ads off.
  The latest Debug app is installed on Duo and was left at the French consent
  prompt for the user's choice.

### Remaining production dependencies

1. **App-ads verification is still blocked by the live App Store listing.** AdMob
   reports “Examen requis / Diffusion d'annonces limitée / Verify app”. Retrying
   verification failed. Apple's public lookup for live version **1.1.1** returns
   no seller website. The existing **1.2.0 Prepare for Submission** version already
   has the correct marketing and support URLs; those values were verified, not
   changed. They must become live through the app release, then Google must recrawl
   and approve the app. A correct hosted file alone cannot complete this step.
2. **Privacy labels must accompany the updated build.** App Store Connect still
   publishes “Data Not Collected”, dated two years ago. The canonical privacy URL
   is already edited for the next release. The questionnaire publishes each
   completed data type immediately, rather than keeping a future-version draft;
   exploratory unsaved selections were discarded, and no public label was changed.
   Use the worksheet below to finish declarations for the actual release binary.
3. **Production delivery stays disabled (`QuizAdsEnabled=false`).** The new
   **1.2.0 build 10** archive is a TestFlight candidate and retains this setting.
   Debug-only fake purchases and ad diagnostics are excluded. After the release
   disclosures and verification are ready, enable the switch, upload a new build,
   and update App Review notes to describe the real behavior.
   Actual paid ad fill/revenue is not established by test ads. Test-banner
   rendering is verified on both simulator and physical Sakana.

### Privacy disclosure worksheet for the new build

The application and integrated SDKs no longer justify “Data Not Collected”.
Review these collected categories against the final archive and actual service
configuration (optional Analytics/Crashlytics and notifications still count when
users enable them):

| Category | Evidence / purpose to review |
| --- | --- |
| Coarse location | AdMob IP-derived location; UMP region determination; advertising, analytics, functionality |
| Device ID | AdMob app/device identifiers; Firebase installation and push tokens; advertising, analytics, functionality |
| Product interaction | Ad interactions, optional quiz/paywall/share analytics, UMP interactions |
| Advertising data | Ad impressions and related measurement |
| Crash data | AdMob diagnostics and optional Crashlytics |
| Performance data | AdMob/UMP diagnostics |
| Other diagnostic data | AdMob and Firebase operational diagnostics |
| Other data types | Firebase Messaging SDK/device metadata disclosed in its bundled manifest |
| Purchase history | Optional `purchase_verified` analytics and verified subscription event processing; no payment-card data |

Google Mobile Ads 13.11.0's bundled manifest marks coarse location, device ID,
advertising data, and product interaction as linked. It marks diagnostics as
unlinked and the Device ID category as tracking-capable. The app's no-ATT,
non-personalized, first-party-ID-disabled configuration is relevant to the tracking
answer, but “no account” alone is not proof that collected data is unlinked.
Check the final configuration before publishing those answers. Quiz answers and
portraits remain local and should not be added as uploaded user content.

References checked for this work:
- <https://developers.google.com/admob/ios/privacy>
- <https://developers.google.com/admob/ios/banner>
- <https://developers.google.com/admob/ios/privacy/data-disclosure>
- <https://firebase.google.com/docs/ios/app-store-data-collection>
- <https://support.google.com/admob/answer/10113004>
