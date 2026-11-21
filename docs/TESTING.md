# Verification record

Checked on 21 November 2026 using Flutter 3.50.1 stable, Dart 3.14.0 and Chrome on Linux.

## Executed

- `flutter analyze`: no issues found, including after the Cairo Bold change.
- `flutter test --reporter expanded`: all **26 tests passed**, including a fresh clone of the published repository after the typography update.
- `flutter build web --release --no-wasm-dry-run`: successful release JavaScript build.
- Chrome loaded the release web build without JavaScript page errors.
- Actual rendered mobile home, desktop home, dark mode and quiz pixels were inspected. Final screenshots use Cairo Bold.
- Widget tests cover 320 x 640, 390 x 844 and 1440 x 1000 layouts, RTL direction, completion/review of a quiz, leaving an unfinished quiz, saved facts and dark mode.

## Automated coverage

Content IDs, category sizes, correct-option bounds and source labels; daily date stability, rotation and dates before the epoch; Arabic numerals; empty-session guard, invalid/duplicate answers, scoring, transitions and final boundary; result serialization, average, favorites/theme reload, clearing history, malformed rows and the newest-100 cap; mobile/small/desktop layouts and the core widget flows listed above.

Mock preferences are used in automated storage tests. These test serialization and state behavior, not all device/browser storage failures.

## Not verified

- Android APK compilation did not finish in the available build environment. No APK, emulator or physical Android-device test is claimed.
- iOS is not configured or built.
- App Store/Play Store distribution, production signing, cloud sync, a hosted live demo and offline PWA installation are not included.
- No claim of exhaustive accessibility certification, browser compatibility or load/security testing.

## Source review

No account credentials, API keys, personal messages, user analytics or production databases belong in this repository. Generated local SDK paths, caches and signing keys are excluded from the source package.
