# Contributing to assets_audio_player_plus

Thanks for your interest in improving this plugin. This document is the
canonical guide for anyone sending a PR.

## TL;DR

1. Open an issue first for anything bigger than a small fix.
2. Fork, branch off `master` with a descriptive name.
3. `dart format .` → `flutter analyze` → `flutter test` must all be clean.
4. Include tests and update the `example/` app when changing public API.
5. Describe what you tested, on which platforms, with which Flutter version.
6. One concern per PR.

## Repository layout

```
/                          # main plugin (Dart + platform channels)
  lib/                     # public Dart API
  android/                 # Android (Kotlin) plugin implementation
  ios/                     # iOS (Swift) plugin implementation
  macos/                   # macOS plugin implementation
  test/                    # Dart unit tests

assets_audio_player_plus_web/   # federated web implementation
  lib/web/                 # package:web + dart:js_interop bindings

example/                   # demo app exercising every feature
  lib/
    main.dart              # launcher screen
    demos/                 # one file per demo, snake_case
    widgets/               # shared UI widgets
    utils/                 # helpers (string_duration, conditional imports)
```

## Development setup

```bash
git clone https://github.com/cyclone-pk/assets_audio_player_plus.git
cd assets_audio_player_plus
flutter pub get
cd assets_audio_player_plus_web && flutter pub get && cd ..
cd example && flutter pub get && cd ..
```

Run the example app:

```bash
cd example
flutter run -d chrome     # web (DDC)
flutter run -d <android>  # Android
flutter run -d <iOS>      # iOS
```

## Required checks before pushing

> ℹ️ Automated CI is not wired up yet (to be added later). Run these locally
> before opening a PR and paste the results into the PR description.

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
(cd assets_audio_player_plus_web && flutter analyze)
(cd example && flutter analyze)
```

Recommended additional smoke tests:

- `cd example && flutter build web --release`
- `cd example && flutter build web --wasm`
- `cd example && flutter build apk --debug`

## Testing expectations

### Unit tests
Every bug fix should land with a regression test in `test/`. Pure Dart logic
(Playlist mutations, metadata handling, duration parsing) lives in unit tests.

### Example app coverage
If you touch a public API, update or add a demo in `example/lib/demos/`. The
launcher in `example/lib/main.dart` must list every demo with an accurate
one-line description. The goal is that a developer running the example app
can see what each feature does without reading source code.

### Manual testing
Platform-specific code (audio focus, notifications, background playback)
cannot be fully covered by unit tests. Your PR description must list every
platform you tested on, with the Flutter version.

### Web-specific
Web gets two build targets: standard JS (DDC/dart2js) and WebAssembly. The
web player uses `package:web` + `dart:js_interop` so it compiles to both. If
you touch `assets_audio_player_plus_web/`, test both `flutter run -d chrome` and
`flutter build web --wasm`.

## Style

- Follow `flutter_lints`. We do not override formatter defaults.
- Prefer `super.key` over `Key? key` + `super(key: key)`.
- Use string interpolation (`'$x'`), not concatenation.
- Do not add comments that restate the code. Do explain *why* non-obvious
  decisions were made.
- Keep public APIs small. Add a private helper before adding a public one.

## Review process

1. Paste the output of the local checks (see "Required checks before pushing")
   into the PR description.
2. At least one approving review from a maintainer (see CODEOWNERS).
3. CODEOWNERS are notified automatically on PRs touching their directories.
4. Maintainer handles the merge and any version bump — do not bump the
   version or edit `CHANGELOG.md` in your PR unless the maintainer asks.

## Releases

Maintainer-only:

1. Bump `version` in `pubspec.yaml` and `assets_audio_player_plus_web/pubspec.yaml`.
2. Update `CHANGELOG.md` with user-facing entries since the last tag.
3. `git tag vX.Y.Z && git push origin vX.Y.Z`.
4. `flutter pub publish` for both packages.

## Reporting security issues

Do not open a public issue for suspected security vulnerabilities. Email the
maintainer directly (see `pubspec.yaml` → `homepage`) with the details.

## License

By contributing you agree that your contribution will be licensed under the
same license as this project (see `LICENSE`).
