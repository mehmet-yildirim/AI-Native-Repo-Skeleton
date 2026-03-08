# Vue 3 Standards

## Composition API
- Always `<script setup lang="ts">` — never Options API in new code
- `defineProps<Props>()` and `defineEmits<Emits>()` with TypeScript generics
- `readonly()` to expose reactive state from composables without allowing mutation

## Reactivity
- `ref()` for primitives, `reactive()` for objects (be aware of destructuring loss)
- `computed()` for derived state; `watch()` for side effects; `watchEffect()` for auto-tracking
- Avoid `deep: true` watchers — redesign state shape instead

## Composables
- File: `use<Feature>.ts` in `src/composables/`; always return refs (not raw values)
- Clean up in `onUnmounted()`: timers, listeners, abort controllers

## Pinia (State Management)
- Setup Stores (Composition API style); one store per feature domain
- `storeToRefs()` to destructure state reactively; never mutate state outside store
- `readonly()` on exposed state in stores

## Vue Router
- `<RouterLink>` always; lazy-load routes with `() => import('./...')`
- `useRouter()` and `useRoute()` — not `this.$router`

## Templates
- `@if/@for/@switch` (Vue 17+ control flow); `track` on `@for`
- No `v-if` + `v-for` on same element; no array index as `:key`
- Complex expressions → computed properties

## Testing (Vitest + Vue Test Utils)
- `createTestingPinia` for Pinia stores; `await nextTick()` after state changes
- Test behavior via rendered output — not internal state
