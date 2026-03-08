# Angular Standards

## Components (Angular 17+)
- Standalone components with `ChangeDetectionStrategy.OnPush` always
- `inject()` function for DI — not constructor injection in new code
- `@Input({ required: true })` for mandatory inputs; use `input()` signal for reactive inputs
- Never use `ElementRef` — prefer CDK or template references

## Signals (Angular 17+)
- `signal()` for writable state, `computed()` for derived, `effect()` for side effects
- `toSignal()` to bridge RxJS → Signals; `toObservable()` for reverse bridge
- Prefer Signals over RxJS for local component state

## RxJS
- Unsubscribe with `takeUntilDestroyed()` (Angular 16+) or `async` pipe
- Use correct flattening operator: `switchMap` (cancel), `concatMap` (queue), `exhaustMap` (ignore new)
- No nested subscriptions — compose with operators
- `shareReplay({ bufferSize: 1, refCount: true })` for multicasted streams

## Services & HTTP
- `HttpClient` only in service layer — never in components
- Functional interceptors (`HttpInterceptorFn`) for auth headers, error handling
- Return `Observable<T>` from service methods

## NgRx Signal Store
- One store per feature; `effect()` for async operations
- Actions named as verb+noun: `loadUsers`, `loadUsersSuccess`, `loadUsersFailure`

## Templates (Angular 17+ control flow)
- `@if`, `@for (item of items; track item.id)`, `@switch` — not `*ngIf`, `*ngFor`
- No complex expressions — move to computed signals or `get` accessors

## Forms
- Reactive Forms with `FormBuilder.nonNullable.group()`
- Custom validators return `ValidationErrors | null`; show errors only on `touched`

## Performance
- Lazy-load all feature routes; `@defer (on viewport)` for below-fold content
- `NgOptimizedImage` for all `<img>` tags; consider zoneless change detection
