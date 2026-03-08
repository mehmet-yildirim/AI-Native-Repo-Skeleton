# .NET / C# Standards

## Style & Naming
- 4-space indent, Allman braces for types/methods
- `PascalCase` for everything public; `_camelCase` for private fields; `IPrefix` for interfaces
- Async methods: suffix with `Async`; `var` when type is obvious
- Nullable reference types enabled: `<Nullable>enable</Nullable>`

## ASP.NET Core
- Constructor injection — never `ServiceLocator` or static access
- Minimal APIs for new .NET 8+ services; return `TypedResults.*` for testability
- `IOptions<T>` for configuration — never `IConfiguration` in services
- `ILogger<T>` for all logging — never `Console.WriteLine`

## Architecture — Clean
- API → Application (MediatR CQRS) → Domain → Infrastructure
- Domain has zero external dependencies
- Result pattern (`Result<T>`) for business errors — not exceptions
- DTOs/Records for all API inputs and outputs; never expose domain entities

## EF Core
- Fluent API config in `IEntityTypeConfiguration<T>` classes
- Migrations code-reviewed and applied via pipeline (never auto-migrate)
- `AsNoTracking()` for read-only queries; explicit `Include()` to avoid N+1
- Repository pattern over naked `DbContext` in application layer

## Testing (xUnit + NSubstitute + FluentAssertions)
- Unit tests: no ASP.NET host; mock with NSubstitute
- Integration tests: `WebApplicationFactory<Program>` + Testcontainers
- `FluentAssertions` for readable assertions
- `AutoFixture` for test data

## C# 12 / .NET 8+ Features to Use
- Records and primary constructors; `required` members; `IAsyncEnumerable<T>`; `CancellationToken` everywhere
