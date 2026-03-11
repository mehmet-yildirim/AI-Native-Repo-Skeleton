# iOS Standards (Swift / SwiftUI)

## Swift
- `async/await` for all async work — no callbacks or completion handlers
- `@MainActor` on all ViewModels and UI-updating code
- `actor` for shared mutable state; `Sendable` on types crossing actor boundaries
- No force-unwrap (`!`) in production; `guard let` over deeply nested `if let`
- Sealed `enum` with associated values for state modeling

## SwiftUI State
| Wrapper | Use case |
|---------|---------|
| `@State` | Local ephemeral view state |
| `@StateObject` | ViewModel owned by this view |
| `@ObservedObject` | ViewModel passed from parent |
| `@EnvironmentObject` | Shared dependency injected at ancestor |
| `@Observable` | iOS 17+ replacement for ObservableObject |

- `NavigationStack` + `navigationDestination(for:)` — not deprecated `NavigationView`
- `.task` modifier for async work (auto-cancels on view disappear)
- `LazyVStack` / `List` for long lists — never `VStack` + `ForEach`

## Architecture — MVVM + Clean
- View → ViewModel (@MainActor) → Use Case → Repository (protocol) → Network/Persistence
- Repository protocol enables mocking; inject via `init` — no singletons for business logic
- SwiftData (iOS 17+) preferred; Core Data for existing projects

## Networking
- `URLSession` with `async/await`; `Codable` for JSON; `CodingKeys` for snake_case mapping
- Cancel in-flight requests automatically via `.task` modifier

## Testing
- Swift Testing (`@Test`, `@Suite`) for new tests (Xcode 16+)
- XCTest for existing codebases; mock protocols — not concrete types
- `@MainActor` on async ViewModel tests

## App Store
- `xcconfig` files for environment-specific settings
- Fastlane + Match for signing and TestFlight upload
- Privacy manifest (`PrivacyInfo.xcprivacy`) required for SDK APIs
- Commit `Package.resolved`; prefer SPM over CocoaPods
