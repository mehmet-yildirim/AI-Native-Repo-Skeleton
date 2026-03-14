# Architecture Guidelines

## Standing Rules (apply to every code change)

### Prefer Hexagonal Architecture
Default to Hexagonal (Ports & Adapters) unless the project's `docs/architecture/overview.md` specifies otherwise.
- **Domain**: pure business logic — no framework, no I/O, no outer-layer imports
- **Application**: use cases / services — depends only on domain interfaces (ports)
- **Infrastructure**: implements ports — DB, HTTP clients, queues. Domain never imports vendor SDKs directly.
- **Interface**: controllers, CLI handlers — depends only on application layer
- Dependency rule: always point inward.

### Adapter Pattern for External Integrations
For every external system (third-party API, payment, email, SMS, queue, cloud storage, analytics):
1. Define an interface in the domain or application layer.
2. Implement it in infrastructure using the vendor SDK.
3. Inject the implementation — never call vendor SDKs from domain or application code.

### Apply Suitable Design Patterns
| Situation | Pattern(s) |
|-----------|-----------|
| External system integration | **Adapter**, Gateway |
| Multiple interchangeable algorithms | **Strategy** |
| Object construction complexity | **Factory**, Builder |
| Decoupled side effects / events | **Observer**, Event Bus |
| Cross-cutting concerns | **Decorator**, Middleware |
| Expensive resource access | **Repository**, Proxy |
| Complex conditional flows | **Chain of Responsibility**, State |
| Single entry point to subsystem | **Facade** |

Use patterns where they reduce coupling or clarify intent — never force a pattern onto simple code.

---

## Layer Discipline
- Dependencies point inward: Interface → Application → Domain → (no external deps)
- Domain layer: pure business logic, no framework or I/O dependencies
- Application layer: use cases / services, depends only on domain
- Infrastructure layer: DB, HTTP clients, message queues — implements domain ports
- Controllers / handlers: HTTP parsing only, delegate to application layer immediately

## What Goes Where
- Business rules: Domain / Use Case layer (NEVER in controllers)
- HTTP request parsing: Controller only
- Database queries: Repository / Infrastructure layer (NEVER in services directly)
- Input validation: Controller / DTO layer
- Business invariant validation: Domain layer

## Dependency Injection
- Inject all dependencies through constructors
- No service locators or global singletons
- Every dependency must be injectable for testing

## Database
- Parameterized queries always — no raw SQL string interpolation
- Migrations are code: committed, reviewed, versioned
- Never modify production data manually — use migration scripts
- Index all foreign keys and common query predicates

## API Design
- REST: plural noun resources, semantic HTTP verbs, consistent error shape
- Versioned: `/v1/`, `/v2/` in URL path
- Paginate all list endpoints
- Return errors as: `{ error: { code, message, details } }`

## Documentation
- Significant architectural decisions → ADR in `docs/architecture/decisions/`
