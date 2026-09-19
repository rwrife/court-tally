# GitHub App Store builds and releases

The [App Store release workflow](https://github.com/rwrife/court-tally/actions/workflows/app-store.yml) builds the native **iPhone-only** app with bundle ID **`com.infinityball.courttally`**. It tests the app, signs an archive, exports and verifies an IPA, and optionally uploads it to App Store Connect.

## Run from GitHub

1. Open **Actions → App Store release → Run workflow** on **main**.
2. Choose **build** to generate and verify a signed IPA without uploading, or **upload** to build and send it to App Store Connect.
3. Enter a version such as `1.0.0`, or leave it blank to use the Xcode project version.
4. Download the IPA, dSYMs, SHA-256 checksums, and `release.json` from the completed run's artifact.

With GitHub CLI:

```sh
gh workflow run app-store.yml --ref main -f mode=build -f version=1.0.0
gh workflow run app-store.yml --ref main -f mode=upload -f version=1.0.0
```

Pushing a release tag such as **`v1.0.0`** also runs the upload path, using the tag as the marketing version. A release commit must already be on `main`; other branches cannot run the signing job. Do not create a release tag until you intend to upload that version.

The upload action waits up to 30 minutes for Apple's processing to finish before removing its temporary signing certificate. If processing is unconfirmed, it preserves the remote signing assets and reports their IDs for follow-up instead of revoking a certificate Apple may still need. This workflow does **not** submit for review, choose testers, accept agreements, or publish the app publicly. Complete those steps in App Store Connect.

## Existing GitHub secrets

The workflow uses these repository secrets, which were already present during setup:

| Secret | Value |
|---|---|
| `ASC_KEY_ID` | App Store Connect team API key ID |
| `ASC_ISSUER_ID` | API key issuer UUID |
| `ASC_KEY_P8` | Private `.p8` key contents, or their base64 encoding |
| `ASC_TEAM_ID` | Ten-character Apple Developer team ID |

The API key needs access to this app and permission to manage distribution certificates, bundle IDs, and provisioning profiles (an appropriate Admin team key). Its issuer and team must match. Keys and signing assets are never committed or included in artifacts.

The workflow creates a temporary signing key, Apple Distribution certificate, App Store profile, and isolated keychain on a GitHub-hosted runner. It registers `com.infinityball.courttally` if the bundle ID is not already present. It never revokes a pre-existing certificate or changes another app's profile. Cleanup deletes only the certificate/profile created by that run and removes local private-key files, including on failure. If Apple's certificate quota is exhausted, the workflow stops instead of deleting another certificate.

**Build-only artifacts are verification outputs:** their temporary signing identity is removed after the run. Run **upload** to create a freshly signed IPA for submission rather than submitting an old build-only artifact manually. App Store distribution uses Apple's processing and signing after upload.

If a runner is forcibly terminated or Apple's cleanup API is unavailable, inspect the cleanup log for the newly created resource IDs and remove those specific CI resources in the Apple Developer portal. The workflow never guesses which existing resources can be deleted.

## App Store Connect app record

Create an iOS app record in App Store Connect for **`com.infinityball.courttally`** before choosing **upload**. Registering a bundle ID is not the same as creating that record. The upload path checks for the app record before issuing signing assets. Build-only mode can verify the IPA before the record exists.

Use [the prepared listing](app-store.md), [6.5-inch screenshots](screenshots/README.md), and the supplied app icon. Supply a publicly hosted privacy policy URL and complete Apple's required store fields and agreements.

## Versions and build numbers

The marketing version comes from the tag, manual input, or Xcode project, in that order. Versions must use `MAJOR.MINOR.PATCH`.

Each run uses build number **`(IOS_BUILD_NUMBER_BASE + github.run_number).github.run_attempt`**, with a default base of `1000`. Reruns therefore get a new build number. The override is a GitHub repository variable, not a secret. If existing uploads have higher build numbers or the workflow is recreated, increase `IOS_BUILD_NUMBER_BASE`; the script checks Apple's component digit limits. CI overrides build settings without editing source version files.

## Validation and release gates

Every release runs the reusable native CI workflow: release-script tests, Swift scoring/storage/migration tests, and iPhone simulator UI tests. The signed IPA is independently checked for the bundle ID, selected version/build, iPhone-only device family, distribution profile, and valid code signature. Screenshot fixture code is excluded from Release builds.

Before a public release, also check physical-device scoring, restart/resume, file export/import, VoiceOver, large text, and landscape. This app has a new bundle identity: the previous `com.rwrife.courttally` installation has a separate iOS sandbox. Export JSON from the old app and import it into this one; an automatic same-sandbox migration cannot cross bundle IDs.

Local unsigned compile:

```sh
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcodebuild -project ios-native/CourtTally.xcodeproj -scheme CourtTally \
  -configuration Release -destination 'generic/platform=iOS' \
  -derivedDataPath build/native-release CODE_SIGNING_ALLOWED=NO build
```

References: [GitHub's macOS signing guidance](https://docs.github.com/en/actions/how-tos/deploy/deploy-to-third-party-platforms/sign-xcode-applications), [Apple certificate API](https://developer.apple.com/documentation/appstoreconnectapi/post-v1-certificates), [Apple profile API](https://developer.apple.com/documentation/appstoreconnectapi/post-v1-profiles), and [Apple build uploads](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds).
