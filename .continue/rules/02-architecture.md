# Architecture Guidelines

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
