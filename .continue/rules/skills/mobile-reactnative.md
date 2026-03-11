# React Native Standards (TypeScript / Expo)

## TypeScript
- Strict mode required; `StyleSheet.create()` always — never inline style objects
- `Platform.select()` for style values; platform-specific files (`.ios.tsx`, `.android.tsx`) for divergent UX
- Type all navigation param lists: `RootStackParamList`, `TabParamList`

## Component Design
- Named exports; `Pressable` over `TouchableOpacity` for custom press behavior
- `FlashList` (Shopify) for long lists — not `FlatList` or `ScrollView` + `map()`
- `KeyboardAvoidingView` with `behavior={Platform.OS === 'ios' ? 'padding' : 'height'}`
- `accessibilityRole` and `accessibilityLabel` on all interactive elements

## State Management
- TanStack Query for all server state; Zustand with `persist` for client/auth state
- `expo-secure-store` / `react-native-mmkv` as Zustand persistence backend
- No Redux for new projects — overhead not justified

## Navigation (React Navigation v7)
- `createNativeStackNavigator` for native transitions; type all `ParamList`s
- `useNavigation<NativeStackNavigationProp<ParamList>>()` for type-safe navigation
- Deep links via `app.json` (Expo) or `AppDelegate`/`AndroidManifest` (bare)

## Networking & Storage
- Axios with interceptors for auth headers, error normalization, retry
- All network calls through TanStack Query or repository layer
- `expo-secure-store` for tokens; `react-native-mmkv` for fast key-value; `expo-sqlite` for structured data

## Performance
- `react-native-reanimated` for 60fps animations; `react-native-gesture-handler` for gestures
- `useCallback` on event handlers passed to list items
- Hermes engine enabled in both Android and iOS builds

## Testing
- `@testing-library/react-native` for component tests
- `msw/native` for network mocking; Maestro for E2E
- `jest-expo` preset (Expo) or `react-native` preset (bare)

## Build & Distribution (EAS)
- `eas.json` with dev/staging/prod build profiles; `autoIncrement: true` for production
- EAS Build for cloud builds; EAS Submit for store submissions
- EAS Update (OTA) for JS-only hotfixes only — not for new features requiring review
- Secrets via `eas secret:create` — never commit `.env` with credentials
