# اعرف أكتر | Eraf Aktar

Arabic-first learning app built with Flutter. A small, complete local-first portfolio project: discover a fact, take a short quiz, and revisit your progress.

**تطبيق بالعربي، بخط Cairo Bold، ومعلومات وكويزات ونتائج محفوظة على جهازك.**

![Mobile home](docs/1-home-mobile.png)

## What works

- Arabic RTL interface with a bundled **Cairo Bold** font. No runtime font download.
- Responsive phone and desktop layouts, plus light and dark themes.
- A daily fact card, selected by the device's local calendar date.
- 9 facts across space, technology and mathematics. The daily cycle repeats every 9 days.
- 24 multiple-choice questions, 8 per category.
- Randomized 5-question rounds with one locked answer per question, instant explanations and a final answer review.
- Local result history, average accuracy, saved facts and theme preference.
- Confirmation before leaving an unfinished quiz or deleting history.
- Recovery from malformed saved results and visible feedback if a storage write fails.
- No account, API key, server, Firebase project, tracking or paid service required.

## Run the source

Tested toolchain: **Flutter 3.50.1 stable / Dart 3.14.0**.

```sh
flutter pub get
flutter run -d chrome
```

For Android, install the Android SDK and a compatible Java 17+ JDK, accept the SDK terms as prompted, connect a device or start an emulator, then:

```sh
flutter doctor
flutter run -d <android-device-id>
```

Android project files are included. The initial development environment did **not** complete an Android APK build or a physical-device/emulator run. This is not a Play Store release, and no APK is claimed to have been tested.

## Check and build

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release --no-wasm-dry-run
```

Serve the resulting web folder instead of opening `index.html` as a local file:

```sh
cd build/web
python3 -m http.server 8080
# Open http://localhost:8080
```

The first web load needs the app's files to be served. Bundled content needs no data API. An installable offline PWA/service-worker workflow is not promised.

## Project map

| Path | Role |
| --- | --- |
| `lib/main.dart` | Theme, home, library, history, quiz and review screens |
| `lib/content.dart` | Question bank, facts, categories and deterministic daily selection |
| `lib/store.dart` | Quiz scoring/state and local persistence |
| `test/widget_test.dart` | 26 logic, storage and widget tests |
| `assets/fonts/` | Bundled Cairo Bold and font license |
| `web/`, `android/` | Platform configuration and original geometric app icon |
| `docs/TESTING.md` | Executed checks and known limits |

The app uses `ChangeNotifier` and `ListenableBuilder` for a deliberately small state layer, with `SharedPreferences` for local persistence. No backend scaffolding is left for the user to finish.

## Privacy and data limits

All progress stays on the current device/browser origin. There is no device sync, login or cloud backup. Clearing browser/app data removes saved results, bookmarks and preferences. Only the newest 100 completed results are kept. An unfinished round is discarded. A storage error can leave a change available only in the current session, and the app warns about this.

## Content sources

The Arabic educational copy is original paraphrasing. Space and programming topics are based on:

- NASA, [About the Planets](https://science.nasa.gov/solar-system/planets/)
- Dart, [Overview](https://dart.dev/overview)
- Flutter, [Architectural overview](https://docs.flutter.dev/resources/architectural-overview)

Math examples are direct calculations and elementary definitions. The app is a small general-knowledge demo, not an exhaustive curriculum. Source labels are shown on fact cards.

Cairo is bundled under the SIL Open Font License. See `assets/fonts/CAIRO-OFL.txt`. The icon is original geometric artwork. No stock photographs or private data are used.

## Implementation provenance

Created for **Mazen Dev's portfolio with AI-assisted design, implementation, testing and documentation**. This repository should not be presented as code independently hand-written by Mazen. It is a working learning project he can inspect, run and extend.

## Screenshots

![Quiz](docs/1-quiz-mobile.png)
![Dark mode](docs/1-dark-mobile.png)
![Desktop](docs/1-home-desktop.png)

## بالعربي

شغّل `flutter pub get` وبعدها `flutter run -d chrome`. التطبيق جاهز من غير إعداد Firebase أو مفاتيح API. النتائج والمفضلة والثيم بيتحفظوا محليًا بس، ومفيش مزامنة بين الأجهزة. الاختبارات ونسخة الويب اتنفذوا فعليًا، لكن نسخة Android ما اتجربتش على موبايل أو محاكي.

فضولك.. بداية الحكاية ✨
