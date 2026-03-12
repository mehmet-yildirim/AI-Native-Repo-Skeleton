# Kotlin Multiplatform (KMP) Standards

## What Belongs in Shared (commonMain)
- Domain: entities, use cases, repository interfaces
- Data: repository implementations, Ktor API services, DTOs, SQLDelight data sources
- Presentation: ViewModels (using `androidx.lifecycle:lifecycle-viewmodel` KMP edition)
- **Not in commonMain:** Hilt, Room, Android Context, Dispatchers.IO, Retrofit, platform UI

## expect / actual
- `expect` in `commonMain` declares the contract; `actual` in `androidMain` / `iosMain` implements it
- Keep `expect` surface minimal — prefer interfaces + DI over `expect/actual` for complex contracts
- Typical `expect/actual` uses: `PlatformContext`, `createDatabase()`, `platformLogger()`

## Networking (Ktor — multiplatform only)
- `ktor-client-android` for Android; `ktor-client-darwin` for iOS — never Retrofit in shared code
- Install `ContentNegotiation` with `kotlinx.serialization` — not Gson/Moshi
- Wrap all API calls in `Result<T>` at the service layer
- Use `HttpTimeout` plugin; set `requestTimeoutMillis` and `connectTimeoutMillis`

## Serialization
- `@Serializable` from `kotlinx.serialization` — works on all KMP targets
- `@SerialName("snake_case")` for JSON key mapping
- `Json { ignoreUnknownKeys = true; coerceInputValues = true }` for resilient parsing

## Local Storage (SQLDelight)
- Write SQL in `.sq` files under `commonMain/sqldelight/`; SQLDelight generates type-safe Kotlin
- Use `asFlow().mapToList(Dispatchers.Default)` for reactive queries
- One `.sqm` file per migration, numbered sequentially
- `multiplatform-settings` for simple key-value preferences (not SharedPreferences)

## Dependency Injection (Koin)
- Hilt is Android-only — use Koin for shared DI
- Define `module {}` blocks in `commonMain`; add platform-specific modules in `androidMain` / `iosMain`
- `startKoin { androidContext(ctx); modules(...) }` on Android; `startKoin { modules(...) }` on iOS
- `koinViewModel()` in Compose Multiplatform; `get()` in non-Compose code

## Coroutines
- `Dispatchers.Default` and `Dispatchers.Main` — safe in `commonMain`
- **`Dispatchers.IO` is JVM/Android only — never use in commonMain**
- Use `expect fun ioDispatcher(): CoroutineDispatcher` if IO dispatcher is needed in shared code
- Always re-throw `CancellationException` in `catch` blocks
- `SupervisorJob()` for service-level scopes that should not cancel on child failure

## ViewModel
- `androidx.lifecycle:lifecycle-viewmodel` supports KMP since 2.8 — use it in `commonMain`
- `viewModelScope` works on both Android and iOS
- Expose state as `StateFlow<UiState>` — same pattern as Android-only VMs
- iOS: if not using lifecycle-viewmodel, manage scope manually and call `scope.cancel()` from Swift `deinit`

## Compose Multiplatform (shared UI)
- `@Composable` code in `commonMain/composeApp` — same APIs as Android Compose
- Use `compose.resources` DSL for strings/images — not `R.drawable` or `R.string`
- Platform-specific composables via `@Composable expect fun` / `actual fun`
- SKIE plugin: converts `Flow` → Swift `AsyncSequence`, sealed classes → Swift enums

## Testing
- `kotlin.test` for assertions — not JUnit (JVM-only)
- `kotlinx.coroutines.test.runTest` for coroutine tests in `commonTest`
- Use fakes over mocks — MockK/Mockito are JVM-only; write `FakeRepository` / `FakeApiService`
- Platform-specific integration tests in `androidTest` / `iosTest` source sets

## Architecture
- `domain/` → pure Kotlin; zero external dependencies
- `data/` → DTOs, Ktor services, SQLDelight sources, repository implementations
- `presentation/` → ViewModels, UiState sealed classes
- DTOs never leave the data layer; map to domain models at repository boundary

## Build
- Version catalog (`libs.versions.toml`) for all KMP dependencies
- `macos-latest` GitHub Actions runner required for iOS framework builds
- Cache `~/.konan` (Kotlin Native toolchain) and Gradle caches in CI — builds are slow
- Run `./gradlew :shared:allTests` for all-platform shared tests
