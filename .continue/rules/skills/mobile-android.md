# Android Standards (Kotlin / Jetpack Compose)

## Kotlin
- Coroutines + Flow — no RxJava in new code
- `StateFlow` for UI state; `SharedFlow` for one-shot events (navigation, snackbars)
- Sealed interfaces for state: `Loading`, `Success<T>`, `Error`
- No `!!` force non-null assertions; `requireNotNull()` with message at boundaries
- Kotlin DSL (`build.gradle.kts`) — not Groovy

## Jetpack Compose
- Stateless leaf composables: receive data + callbacks, no ViewModel reference
- Stateful screen composables: inject ViewModel, pass data down
- `collectAsStateWithLifecycle()` — not `collectAsState()` (lifecycle-aware)
- Unidirectional Data Flow: events up, state down
- `const` preview composables for every screen
- `LazyColumn` / `LazyRow` for lists — never `Column` + `forEach`

## Architecture — Clean + MVVM
- UI (Compose) → ViewModel (StateFlow) → Domain (UseCases) → Repository → Data Sources
- One ViewModel per screen; `viewModelScope` for coroutines
- Hilt for DI: `@HiltAndroidApp`, `@HiltViewModel`, `@AndroidEntryPoint`
- Room for local DB: Flow-returning DAOs, Alembic-style numbered migrations

## Networking
- Retrofit with `suspend` functions — no `Call<T>` wrappers
- `kotlinx.serialization` for JSON; OkHttp interceptors for auth/logging/retry
- Repository wraps results in `Result<T>` — keeps exceptions out of UI layer

## Testing
- MockK (not Mockito) for mocking; Turbine for Flow testing
- `UnconfinedTestDispatcher` for deterministic coroutine tests
- Compose testing: `createComposeRule()` + `semanticsTestTag` for stable selectors

## Build & Distribution
- Version catalog (`libs.versions.toml`) for all dependencies
- Product flavors per environment (dev/staging/prod)
- App Bundle (`.aab`) for Play Store; ProGuard/R8 rules committed and tested
- `keystore.properties` excluded from VCS; injected via CI environment
