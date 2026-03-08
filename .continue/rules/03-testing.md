# Testing Standards

## Test Types
- **Unit**: Single function in isolation, mock all I/O, < 1ms each
- **Integration**: Multiple components, real DB in transaction, mock external HTTP
- **E2E**: Full user journey, no mocks

## File Organization
- Unit tests co-located with source: `user.service.test.ts` next to `user.service.ts`
- E2E tests in dedicated `tests/e2e/` directory

## Writing Tests
```
it('<does X> when <condition Y>', () => {
  // Arrange — set up state
  // Act    — call the thing under test
  // Assert — verify outcomes
});
```

## Rules
- Tests must be deterministic — same result every run on every machine
- No shared mutable state between tests
- Test names describe behavior, not implementation
- Use factory functions for test data, not raw object literals
- Mock: DB, HTTP clients, file system, clock, randomness in unit tests
- Don't mock: the module under test, pure utility functions

## What Must Be Tested
- All business logic
- All API endpoints (happy path + error cases)
- All error handling paths
- Boundary conditions: empty, max, invalid types
- Security-critical code: auth, authorization, input validation

## Coverage Targets
- Business logic: 90%+
- API endpoints: 100% (all happy + error paths)
- E2E: all critical user journeys
