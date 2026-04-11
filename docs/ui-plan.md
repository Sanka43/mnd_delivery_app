# MND UI plan

## Direction

- **Palette:** black / off-white surfaces, **one primary blue** (`#2563EB` light / `#3B82F6` dark). Supporting neutrals for text and dividers.
- **Accent tokens:** `MndPalette.positive` (green) and `MndPalette.warning` (amber) for stats and semantics only — not competing blues.
- **Style:** modern, premium, minimal — thin borders, low or zero elevation, spacing + typography for hierarchy.
- **Glass:** frosted **navigation, app bars, drawers, cards, auth** on **iOS & Android** only. **Web** keeps solid Material (blur cost).

## Implementation

| Piece | Location |
|--------|-----------|
| `ThemeData` light / dark | `packages/mnd_theme/lib/src/mnd_app_theme.dart` → `MndAppTheme.light` / `.dark` |
| Glass widgets + flag | `mnd_glass.dart` → `mndGlassChromeEnabled`, `MndGlassPanel`, … |
| Auth / simple message layout | `mnd_login_chrome.dart` → `MndLoginChrome` |
| App wiring | Each app `MaterialApp(theme:, darkTheme:, themeMode: ThemeMode.system, builder: …)` |

## Apps

- **mnd_admin:** shell glass (existing), dashboard glass cards, settings preview card, coming soon panel, login + role errors via `MndLoginChrome`.
- **mnd_customer / mnd_shop:** same theme; auth screens use `MndLoginChrome` on mobile.

## System UI

- `MaterialApp.builder` wraps `AnnotatedRegion<SystemUiOverlayStyle>` with transparent status bar and icon brightness from `Theme.brightness`.

## Future

- Optional `mnd_theme` usage inside heavy customer screens (e.g. food grid) for glass product tiles.
- Custom font (e.g. Inter) via `google_fonts` if product wants a distinct wordmark.
