# CLAUDE.md

Guidance for Claude Code when working in this repo.

## Project

Flutter starter — Clean Architecture + BLoC + GetIt DI. Fork/template for new apps; strip what you don't need, wire the real backend in `lib/core/config/api_config.dart`.

## Commands

```bash
flutter pub get
flutter run -d chrome    # or android / windows / etc
flutter test
flutter analyze
```

## Architecture

Clean Architecture + BLoC + GetIt DI, per-feature in `lib/features/{name}/{data,domain,presentation}`. All BLoCs/repos wired in `lib/core/di/injection_container.dart` — register here when adding a service.

```
UI dispatches Event → BLoC handles → emits State → UI rebuilds
```

### Backend

Single Dio client (`lib/core/api/api_client.dart`), base URL in `lib/core/config/api_config.dart`. Bearer token auto-attached from `LocalStorageService` via interceptor. `LocalStorageService` splits session storage: token in `flutter_secure_storage`, non-sensitive identity in `SharedPreferences`.

### Adding a feature

1. Copy `lib/features/_template/` → `lib/features/{name}/`, rename `Template*` classes.
2. Register datasource/repository/bloc in `lib/core/di/injection_container.dart`.
3. Write bloc tests under `test/features/{name}/` mirroring the `lib/features/{name}/` path — see `test/features/auth/presentation/bloc/auth_bloc_test.dart` for the mocktail + bloc_test pattern.

## Notes

- Never commit `.env` or hardcoded API tokens.
- Test infra: `mocktail` + `bloc_test`.
- This repo is a GitHub template — new projects should use `gh repo create <name> --template <this-repo>`, not fork.
