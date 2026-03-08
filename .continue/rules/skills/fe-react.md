# React Standards

## Components
- Functional components only; named exports (not default)
- Props: TypeScript `interface`; `children: React.ReactNode`; never `React.FC`
- One component per file; co-locate test alongside component
- Composition over configuration — avoid too many boolean props
- Separate UI from logic with custom hooks

## Hooks
- Custom hooks: `use` prefix; return refs not raw values
- `useState` for local UI; `useReducer` for complex state with multiple sub-values
- `useEffect` for external system sync only — not data fetching
- Return cleanup in `useEffect` for subscriptions, timers, observers
- Full dependency arrays — no suppression comments

## State Management
- Server state: TanStack Query (React Query) — never `useEffect` + `useState` for server data
- Global UI state: Zustand (preferred) or React Context for rarely-changing values
- URL state: `useSearchParams` for filterable/shareable UI state
- Derive values via `useMemo` — do not duplicate state

## Forms
- React Hook Form for all forms; Zod for validation via `@hookform/resolvers/zod`
- Show field errors on `touched`; form-level error for server errors

## Performance
- `React.memo`, `useMemo`, `useCallback` only when profiling shows need
- Code-split routes with `React.lazy` + `<Suspense>`
- Correct `key` props — never array index for dynamic lists

## Testing (Vitest + React Testing Library + MSW)
- Test behavior via DOM — not implementation details or internal state
- Query by role/label/text; `userEvent` for interaction; MSW for network mocking
- No snapshot tests for logic-containing components
