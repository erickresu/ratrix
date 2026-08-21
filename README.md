# Ratrix

Freight rate management and shipping calculator for CERRO RATRIX, built on a Flutter Clean Architecture starter (BLoC + GetIt DI).

## Features

- **Rates dashboard** — active rates, clients, routes at a glance, recent rates table.
- **Rate wizard** — create/edit Published or Custom rates: routes, breakweight brackets, addons (fuel surcharge, insurance, THC, etc.), all 7 breakweight pricing options (Fixed, Flat, Cumulative, Excess, plus "Minimum" first-bracket-flat-fee variants of Fixed/Cumulative/Excess).
- **Shipping calculator** — pick a client + rate table, enter cargo dimensions/weight, get a full freight breakdown (base freight, surcharges, VAT) against actual vs. volumetric weight.
- **Custom client rates** — per-client rate tables with filtering, sorting, pagination.
- Light/dark theme, responsive layout (desktop inline sidebar / mobile-tablet collapsible drawer).

## Getting Started

```bash
flutter pub get
flutter run -d chrome    # or android / windows / etc
flutter test
flutter analyze
```

Wire your backend's base URL in `lib/core/config/api_config.dart`.

## Architecture

Clean Architecture + BLoC + GetIt DI, per-feature in `lib/features/{name}/{data,domain,presentation}`. All BLoCs/repos are registered in `lib/core/di/injection_container.dart`.

```
UI dispatches Event → BLoC handles → emits State → UI rebuilds
```

Single Dio client (`lib/core/api/api_client.dart`) with bearer-token auth via interceptor; `LocalStorageService` splits session storage between `flutter_secure_storage` (token) and `SharedPreferences` (non-sensitive identity).

See [CLAUDE.md](CLAUDE.md) for the full contributor guide (adding a feature, test conventions, notes for AI-assisted changes).
