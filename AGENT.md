# AGENT.md

## Scope

This guide applies to `bulocation_mobile`.

This project is the Flutter end-user app for:

- login/register/auth flows
- QR-based map opening
- indoor navigation
- parking guidance
- live occupancy-aware parking suggestions

## Current Product Direction

The app is not only a parking app.

Primary goal:

- indoor navigation across institutions, buildings, and floors

Parking is a major mode inside that experience.

## Important Runtime Flows

- auth/session restore
- token refresh
- QR scan -> scan context -> published map open
- facility selection -> published map load
- route drawing on map
- occupancy updates over SignalR

## Rules

1. Do not hardcode production secrets or hosts.
2. Preserve `x-app-secret` and authenticated API usage.
3. Keep map rendering coordinates aligned with published map payloads.
4. Avoid regressions in pan/zoom/route/park overlay behavior.
5. Prefer extracting widgets/helpers over growing single large screen files.
6. Keep user-facing Turkish text clean and correctly encoded.
7. Do not reintroduce mock content into real flows.

## Sensitive Files And Areas

- `lib/app/app_session_controller.dart`
- `lib/core/api_client.dart`
- `lib/services/auth_service.dart`
- `lib/services/facility_service.dart`
- `lib/services/pathfinding_service.dart`
- `lib/services/parking_service.dart`
- `lib/models/graph_data.dart`
- `lib/widgets/floor_plan_widget.dart`
- `lib/screens/home_screen.dart`
- `lib/screens/map/`

## UI Guidance

- Keep the current theme consistent across home, maps, profile, and auth.
- Production polish matters: spacing, typography, and disabled/loading states should feel intentional.
- If map UI changes are made, preserve behavior before improving appearance.

## Quality Bar

Before closing meaningful work, prefer checking:

- `flutter analyze`
- impacted flows on auth or map screens
- obvious Turkish copy issues

## Current Engineering Direction

- continue reducing oversized screen/widget files
- harden map interaction runtime
- add real widget/service tests
- remove remaining encoding issues
