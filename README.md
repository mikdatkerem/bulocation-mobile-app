# Bulocation Mobile

Bulocation mobile is the Flutter client for QR-first indoor navigation, manual organization/site/building/floor selection, published map viewing, route drawing, and live parking occupancy.

The app is not only a parking product. Parking is one operational mode inside the broader indoor navigation experience.

## Core Flows

- Login, registration, Google sign-in, refresh token, and session restore
- First-run guide and app boot skeleton states
- Home hero with QR-first start, top-right profile access, and hidden bottom bar while the hero is active
- Manual map selection as a full-page home flow
- Recent maps under manual selection, including map asset previews
- Recent-first suggestions while searching sites, buildings, and floors
- QR reference resolution into scan context and the related published floor map
- Map screen with camera scanning, published map rendering, route drawing, glass notices, and a draggable facility panel
- SignalR-based live parking occupancy updates

## Requirements

- Flutter stable with Dart 3.x
- Android Studio / Xcode platform tooling
- For Android builds on Windows, `JAVA_HOME` should point to the Android Studio JBR/JDK. Example: `C:\Program Files\Android\Android Studio\jbr`
- Running Bulocation API

## Setup

```bash
flutter pub get
flutter analyze
flutter test
```

## Run

For Android emulator development against the local API:

```bash
flutter run \
  --dart-define=BASE_HOST=http://10.0.2.2:5011
```

For staging or production-like runs, `BASE_HOST` must be HTTPS:

```bash
flutter run --release \
  --dart-define=BASE_HOST=https://api.bulocation.com \
  --dart-define=APP_SECRET=... \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=...
```

The main mobile security layer is JWT access tokens plus the refresh-token flow. If `APP_SECRET` is defined, REST and SignalR requests also include it as `x-app-secret`. Because a mobile binary can be reverse engineered, `APP_SECRET` must never be treated as the only real security boundary.

## Project Structure

```text
lib/
  app/
    app_session_controller.dart
  core/
    api_client.dart
  models/
    auth_models.dart
    exceptions.dart
    facility_models.dart
    graph_data.dart
    recent_map.dart
  screens/
    app_shell.dart
    home_overview_screen.dart
    home_guide_screen.dart
    home_screen.dart
    login_screen.dart
    register_screen.dart
    profile_screen.dart
    map/
    home/
    auth/
    profile/
  services/
    auth_service.dart
    facility_service.dart
    parking_service.dart
    pathfinding_service.dart
    recent_maps_storage.dart
    session_storage.dart
  widgets/
    bottom_bar.dart
    embedded_scanner.dart
    floor_plan_widget.dart
    map_asset_preview.dart
    skeleton.dart
    parking_panel/
    floor_plan/
```

Note: `home_screen.dart` still contains the main map screen state. A future cleanup can rename/split it into a clearer `map_screen.dart` structure, but do not do that casually because it touches routing and state handoff.

## API Configuration

`lib/main.dart` reads these dart defines:

| Value | Purpose |
| --- | --- |
| `BASE_HOST` | API and SignalR host. Example: `https://api.bulocation.com` |
| `APP_SECRET` | Optional Cloudflare/API gateway value sent as `x-app-secret`. |
| `GOOGLE_SERVER_CLIENT_ID` | Server client id used for Google sign-in backend verification. |

Derived endpoints:

| Endpoint | Purpose |
| --- | --- |
| `$BASE_HOST/api` | REST API |
| `$BASE_HOST/hubs/parking` | SignalR parking occupancy hub |

## Platform Notes

Android:

- `applicationId`: `com.bulocation.app`
- Camera and internet permissions are defined.
- Release signing must use real store/CI keystore values, not a debug key.
- Copy `android/key.properties.example` to `android/key.properties` locally and fill real values outside git.

iOS:

- Display name: `Bulocation`
- Bundle identifier: `com.bulocation.app`
- Camera usage description is defined.
- Signing and Apple Developer Team must be configured in Xcode before release.

## Quality Checks

Run after meaningful changes:

```bash
flutter analyze
flutter test
```

If Gradle is run directly on Windows:

```powershell
$env:JAVA_HOME='C:\Program Files\Android\Android Studio\jbr'
$env:Path="$env:JAVA_HOME\bin;$env:Path"
```

Release checks:

```bash
flutter build apk --release \
  --dart-define=BASE_HOST=https://api.bulocation.com

flutter build ios --release \
  --dart-define=BASE_HOST=https://api.bulocation.com
```

## Before Production

- Android release keystore values must be defined securely in CI/store tooling.
- iOS signing must be finalized.
- Google sign-in Android/iOS native configuration must be verified.
- QR -> scan context -> published map -> route integration/widget tests should be expanded.
- SignalR should move toward a short-lived connection token strategy.
- Large organization/site lists should keep using progressive loading and skeleton states.
