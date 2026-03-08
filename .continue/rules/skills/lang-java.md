# Java Standards

## Style & Naming
- 4-space indent; `PascalCase` classes, `camelCase` methods/variables, `SCREAMING_SNAKE_CASE` constants
- Package naming: `com.company.project.feature`
- Test classes: `ClassNameTest`; methods: `shouldDoX_whenY()`

## Spring Boot
- Constructor injection always — NEVER `@Autowired` field injection
- Use `@ConfigurationProperties` for config binding — avoid `@Value`
- Return `ResponseEntity<T>` from controllers
- Global error handler via `@ControllerAdvice` → `ProblemDetail` (RFC 9457)
- `@Transactional(readOnly = true)` on query service methods

## Architecture
- Controller → Service → Repository → Entity (never skip layers)
- DTOs for all request/response (never expose `@Entity` directly)
- Use `record` for immutable DTOs (Java 16+)
- No business logic in controllers or repositories

## JPA
- Fetch type: LAZY by default; use JOIN FETCH or `@EntityGraph` to avoid N+1
- Flyway or Liquibase for migrations — never `ddl-auto=update` in production
- Parameterized JPQL always — never string concatenation

## Testing
- Unit: `@ExtendWith(MockitoExtension.class)` — no Spring context
- Integration: `@SpringBootTest` + Testcontainers
- Slice: `@WebMvcTest` for controllers, `@DataJpaTest` for repos
- AssertJ for fluent assertions

## Java 21 Features to Use
- Records for DTOs, sealed classes for error types, pattern matching, virtual threads for I/O
