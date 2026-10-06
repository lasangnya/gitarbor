# Gitarbor

Gitarbor grows a GitHub repository into a watercolour botanical tree. Paste
`owner/repo` and watch its branches and commits grow, scrub through the
history, then print the tree as a herbarium plate or export it as a PDF. It
runs on macOS, Windows, web, iOS and Android.

## How git becomes a tree

| In the repository                  | On the tree                         |
| ---------------------------------- | ----------------------------------- |
| Default branch                     | Trunk                               |
| Branch                             | Limb                                |
| Commits                            | Leaves along the limb               |
| Commit age                         | Leaf colour (fresh green to autumn) |
| Merged branch                      | Blossoms                            |
| Stale branch                       | Drooping, dry limb                  |
| Closed unmerged or deleted branch  | Cut stub                            |
| Author                             | Coloured tag                        |

## Running it

```sh
flutter pub get
flutter run -d macos      # or windows, chrome, an iOS or Android device
```

Notes for an exFAT drive: macOS code signing fails when `build/` lives on
exFAT, so symlink `build/` to a folder on an APFS volume. exFAT also leaves
`._*` files behind, which make `flutter test` hang, so run `dot_clean .`
(or `find lib test -name '._*' -delete`) before testing.

## GitHub sign-in

Public repositories work without signing in, but unauthenticated requests are
limited to 60 per hour. Signing in raises that to 5,000 per hour and lets you
plant private repositories.

- **Device flow**: choose Connect GitHub, enter the short code on github.com.
  The app ships with a built-in OAuth client ID.
- **Your own OAuth app**: build with
  `--dart-define=GITHUB_CLIENT_ID=your_client_id`.
- **Personal access token**: paste one in the same sheet.

Tokens are kept in the system keychain. Responses are cached on disk with
their ETag, so refreshing a repository costs few or no rate-limit points.

## Printing

The Print tab lays the tree out as a herbarium plate: choose paper size,
paper tone, colour or ink, numbered labels, then print or save a PDF.

## Keyboard

On the Live screen: Space replays growth, `+` / `-` zoom, `0` fits, `L`
toggles labels, Left / Right scrub by 5%, Escape clears the selection. Tab
reaches every control and shows a focus ring.

## Project layout

- `lib/data`: GitHub client, OAuth device flow, ETag cache, repository and
  branch classification.
- `lib/tree`: tree model, geometry, sprite atlas and the watercolour
  painter, plus the renderer debug screen.
- `lib/ui`: theme tokens, Plant, Growing and Live screens, settings sheet.
- `lib/print`: plate rendering, print screen and PDF export.
- `lib/state`: Riverpod providers for settings, tokens, recent trees and
  planting.

## Testing

```sh
flutter analyze
flutter test
flutter test --update-goldens test/tree/   # after changing the painter
```
