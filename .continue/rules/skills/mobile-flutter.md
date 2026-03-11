# Flutter / Dart Standards

## Dart (3.x)
- Sound null safety: `?` for nullable; `!` only when non-null is invariant-guaranteed
- Sealed classes for exhaustive state: `UserLoading`, `UserLoaded`, `UserError`
- Records for lightweight structured values: `(String name, int age)`
- `const` constructors on all stateless widgets — reduces rebuilds
- Files: `snake_case.dart`; classes: `UpperCamelCase`; constants: `lowerCamelCase`

## Widget Design
- `StatelessWidget` for all pure leaf components; `StatefulWidget` for local ephemeral state
- `StyleSheet`-equivalent: `const` constructors, `final` fields
- `const` widget where possible — Dart/Flutter optimizes these
- `key` parameter on widgets in lists or conditional positions

## State Management (Riverpod — preferred)
- `@riverpod` annotation + code generation (`riverpod_generator`)
- `AsyncNotifierProvider` for async operations (loading/error/data states)
- `ref.watch` for reactive reads; `ref.read` inside callbacks
- `FamilyModifier` for parameterized providers (`userProvider(userId)`)
- Bloc/Cubit as alternative for complex event-driven state machines

## Navigation (GoRouter)
- Type-safe routes with `go_router_builder` code generation
- `context.go()` for replace; `context.push()` for stack; `context.pop()` for back
- `ShellRoute` for persistent bottom navigation

## Networking & Data
- Dio for HTTP; `retrofit` + `json_serializable` for typed API clients
- `Freezed` for immutable data classes with `copyWith`, `==`, `hashCode`
- Repository pattern: API DTOs → domain models
- `flutter_secure_storage` for sensitive data; `drift` for SQLite ORM

## Testing
- `flutter_test` for unit and widget tests; `mocktail` for mocking
- `integration_test` for full E2E on real devices
- `ProviderContainer` with overrides for Riverpod unit tests
- `tester.pumpWidget(ProviderScope(...))` for widget tests

## Build & Distribution
- Flavors via `--dart-define-from-file=config.env.json`
- `flutter build appbundle` (Play Store); `flutter build ipa` (App Store)
- Fastlane or Codemagic for automated signing and submission
- Commit `pubspec.lock`; run `flutter pub outdated` in CI
