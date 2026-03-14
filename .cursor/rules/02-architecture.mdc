---
description: Architecture guidelines, patterns, and layer boundaries. Apply when designing or implementing features.
globs:
alwaysApply: false
---

# Architecture Guidelines

> See `docs/architecture/overview.md` for the full architecture document with diagrams.

## Standing Rules (apply to every code change)

### 1 — Prefer Hexagonal Architecture

**Default to Hexagonal (Ports & Adapters) unless the project's architecture doc specifies a different pattern.**

- **Domain layer**: Pure business logic. No framework, no I/O, no dependencies on outer layers.
- **Application layer**: Use cases / services. Orchestrates domain objects. Depends only on domain interfaces (ports), never on concrete infrastructure.
- **Infrastructure layer**: DB, HTTP clients, message queues, file system. Implements domain ports — the domain never imports from a third-party SDK directly.
- **Interface layer**: Controllers, CLI handlers, gRPC servers. Depends on application layer only.

**Dependency rule**: Dependencies point inward only. Domain never imports from infra or interface.

### 2 — Adapter Pattern for All External Integrations

Before calling any external system (third-party API, payment gateway, email, SMS, queue, cloud storage, feature flags, analytics, etc.):

1. Define an interface in the domain or application layer describing what is needed.
2. Implement it in the infrastructure layer using the vendor SDK.
3. Inject the implementation at runtime — never call external SDKs from domain or application code directly.

### 3 — Apply Suitable Design Patterns

Choose the pattern that best reduces coupling and clarifies intent. Never force a pattern onto simple code.

| Situation | Preferred pattern(s) |
|-----------|---------------------|
| External system integration | **Adapter**, Gateway |
| Multiple interchangeable algorithms | **Strategy** |
| Object construction complexity | **Factory**, Builder |
| Decoupled side effects / domain events | **Observer**, Event Bus |
| Cross-cutting concerns (logging, auth, retry) | **Decorator**, Middleware |
| Controlled access to expensive resources | **Repository**, Proxy |
| Complex multi-step conditional logic | **Chain of Responsibility**, State |
| Single entry point to a subsystem | **Facade** |

---

## Project-Specific Architectural Pattern

TODO: Describe your chosen pattern and link to docs.

Examples to choose from (delete what doesn't apply):

### Hexagonal / Ports & Adapters
- **Domain layer**: Pure business logic. No framework, no I/O, no dependencies on outer layers.
- **Application layer**: Use cases / services. Orchestrates domain objects. Depends only on domain.
- **Infrastructure layer**: DB, HTTP clients, message queues, file system. Implements domain ports.
- **Interface layer**: Controllers, CLI handlers, gRPC servers. Depends on application layer.

**Dependency rule**: Dependencies point inward only. Domain never imports from infra or interface.

### Clean Architecture (similar to above)
- Entities → Use Cases → Interface Adapters → Frameworks & Drivers
- Same dependency rule: inner rings know nothing about outer rings

### MVC / Layered
- **Models**: Data structures + persistence
- **Services**: Business logic
- **Controllers**: HTTP handling, request/response mapping
- Do not put business logic in controllers or models

## Layer Boundaries

### What belongs where

| Concern | Correct Layer | Wrong Layer |
|---------|--------------|-------------|
| Business rules | Domain / Use Case | Controller |
| HTTP request parsing | Controller | Service |
| Database queries | Repository / Infra | Service |
| External API calls | Infra / Client | Domain |
| Validation of user input | Controller / DTO | Domain |
| Validation of invariants | Domain | Controller |

### Cross-cutting concerns
- **Logging**: Use a structured logger. Log at service/infra boundaries, not inside domain logic.
- **Metrics**: Emit metrics from infra adapters and application services.
- **Tracing**: Propagate trace context via function parameters or context objects — never globals.
- **Auth**: Authenticate at the interface layer; authorize in the application/domain layer.

## Data Flow

```
Request → Router → Controller → Use Case / Service → Domain → Repository
                                                              ↓
Response ← Controller ← Use Case / Service ←        Repository → DB
```

Never skip layers. A controller must not query the database directly.

## Dependency Management

- **Dependency Injection**: Inject dependencies through constructors (preferred) or factory functions
- No service locators or global singletons (except loggers and config)
- Test-friendly: every dependency must be injectable with a mock/stub

## State Management (Frontend)

TODO: Add rules if this is a frontend or full-stack project.

- e.g., Server state via React Query / SWR; UI state via Zustand / Context
- e.g., No Redux unless justified — prefer simpler solutions

## API Design

TODO: Select and complete the relevant section.

### REST
- Use plural nouns for resources: `/users`, `/orders`
- Use HTTP verbs semantically: GET (read), POST (create), PUT (replace), PATCH (update), DELETE
- Return consistent error shapes: `{ error: { code, message, details } }`
- Version via URL prefix: `/v1/`, `/v2/` — never via header for public APIs
- Paginate all list endpoints: cursor-based preferred over offset for large datasets

### GraphQL
- Mutations must be idempotent where possible
- Use DataLoader for all N+1 query patterns
- Input validation in resolvers; business rules in services

## Database

- Never use raw SQL strings with user input — always use parameterized queries / ORM
- Migrations are code: committed, versioned, and reviewed like application code
- Never modify data directly in production — write a migration script
- Add indexes for all foreign keys and common query predicates
- Soft-delete over hard-delete for audited entities

## Event-Driven / Async (if applicable)

TODO: Add rules if the project uses message queues or event sourcing.

- Events are named in past tense: `UserCreated`, `OrderShipped`
- Events are immutable once published
- Consumers must be idempotent
- Dead-letter queue required for every consumer

## Decision Records

All significant architectural decisions must be recorded as ADRs in `docs/architecture/decisions/`.
Use the template at `docs/architecture/decisions/0001-template.md`.
