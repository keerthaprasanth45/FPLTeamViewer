# FPL Team Viewer

Native iOS app for browsing Premier League teams and squads from the Fantasy Premier League API.

## How to build and run

1. Open `FPLTeamViewer.xcodeproj` in Xcode 15 or later.
2. Select an iOS Simulator (iOS 17+).
3. Press Run (⌘R).

From the command line:

```bash
xcodebuild -scheme FPLTeamViewer -destination 'platform=iOS Simulator,name=iPhone 16' test
```

If that simulator name is not installed, list destinations with `xcodebuild -scheme FPLTeamViewer -showdestinations` and substitute one that is available.

## Assumptions

- The public endpoint is `https://fantasy.premierleague.com/api/bootstrap-static/`.
- `elements` are players, `element_types` are positions, and a player's `team` field matches a team `id`.
- FPL `now_cost` is stored in tenths of millions of pounds (for example `55` is £5.5m).
- Cached JSON is the last successful API payload, not a transformed subset.

## Architecture

A small MVVM layout with a composition root:

- **Repository** (`DefaultFPLRepository`) talks to `URLSession` through an `HTTPClient` protocol and persists raw JSON with `FileBootstrapCache`.
- **Mapper** converts Codable DTOs into UI-facing models (player counts, positions, formatted prices).
- **View models** own async load/refresh/search state on the main actor.
- **UI** uses `Main.storyboard` for screens and table cells. `AppTheme` centralises colours, fonts, and spacing.
- Protocols exist so unit tests never call the live FPL API.

Caching is file-based in Application Support so a later offline launch can still show the last successful bootstrap.

## Known limitations

- There is no player detail screen.
- Refresh failure is shown as a banner; there is no retry-on-banner control beyond pull-to-refresh.
- The app icon is the default placeholder.
- Search only covers the currently selected team's squad, as specified.
