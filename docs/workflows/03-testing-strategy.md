# Workflow: Testing Strategy

A comprehensive guide to the testing approach used in AI-Native development, covering
automated test generation, test review, and maintaining a healthy test suite.

## Testing Philosophy

1. **Tests are specifications.** A well-written test suite documents intended behavior more
   precisely than any prose document. Write tests that would help a new developer understand
   the system.

2. **AI writes tests, humans review.** Use `/test` to generate test scaffolding, then review
   critically. AI-generated tests can be wrong, trivial, or test the wrong thing.

3. **Test the behavior, not the implementation.** Tests that break when you refactor internals
   (without changing behavior) are a liability. Tests should survive refactoring.

4. **Failing tests are signals, not noise.** A flaky test is a bug. A skipped test is
   undocumented behavior. Both must be fixed or explicitly deleted.

## Test Pyramid

```
        /\
       /  \
      / E2E \        ← Few, slow, full user journeys
     /--------\
    / Integration\   ← Moderate, service/API level
   /____________\
  /    Unit      \   ← Many, fast, business logic
 /________________\
```

### Unit Tests — The Foundation
- **What**: Single function, class, or module in complete isolation
- **When**: Write alongside implementation (not after)
- **Speed**: < 5ms each; full suite < 30 seconds
- **Mocking**: Mock ALL I/O (DB, HTTP, file system, time, randomness)
- **Coverage target**: 90%+ of business logic

### Integration Tests — The Safety Net
- **What**: Multiple components working together (service + real DB, API endpoint + auth)
- **When**: After unit tests; before merging
- **Speed**: 100ms–2s each; full suite < 5 minutes
- **Mocking**: Real DB (via Testcontainers); mock external HTTP (MSW, WireMock)
- **Coverage target**: 100% of API endpoints, all happy paths + error cases

### E2E Tests — The Confidence Check
- **What**: Full user journey from UI to database and back
- **When**: For critical user journeys; run in CI before production deploy
- **Speed**: 5–30s each; full suite < 15 minutes
- **Tools**: Playwright, Cypress, Selenium
- **Coverage target**: Top 5–10 critical user paths

## AI-Assisted Test Generation

### Generating tests with /test

```
/test src/users/user.service.ts
```

The command generates a complete test file. Always review:

**Check that the test actually tests something:**
```typescript
// BAD — tests implementation, not behavior
it('calls findById', () => {
  service.getUser('1');
  expect(repo.findById).toHaveBeenCalledWith('1');
});

// GOOD — tests behavior
it('returns the user when found', async () => {
  repo.findById.mockResolvedValue(mockUser);
  const result = await service.getUser('1');
  expect(result).toEqual(mockUser);
});
```

**Verify error cases are meaningful:**
```typescript
// GOOD — tests the specific error behavior
it('throws NOT_FOUND when user does not exist', async () => {
  repo.findById.mockResolvedValue(null);
  await expect(service.getUser('unknown')).rejects.toMatchObject({
    code: 'NOT_FOUND'
  });
});
```

**Check test independence:**
- Each test must be runnable in isolation
- No shared mutable state between tests
- `beforeEach` resets all mocks

### Review checklist for AI-generated tests
- [ ] Test name describes behavior (`does X when Y`)
- [ ] Arrange → Act → Assert structure clear
- [ ] Mocking strategy is appropriate for test type
- [ ] Edge cases covered (empty input, null, max values)
- [ ] Error cases covered (service failure, invalid input, not found)
- [ ] Test would actually catch a real bug

## Test Data Management

### Factory functions (required pattern)
```typescript
// factories/user.factory.ts
export function createUser(overrides: Partial<User> = {}): User {
  return {
    id: faker.string.uuid(),
    email: faker.internet.email(),
    name: faker.person.fullName(),
    role: 'user',
    createdAt: new Date(),
    ...overrides,
  };
}

// In tests — override only what matters for the test
const adminUser = createUser({ role: 'admin' });
const deletedUser = createUser({ deletedAt: new Date() });
```

**Rules:**
- Never construct test objects inline with all fields — use factories
- Factories provide sensible defaults; tests override only the relevant fields
- Keep factories in `tests/factories/` or co-located with the domain

### Database Fixtures
- Use transactions rolled back after each integration test (no cleanup code)
- Seed data: minimum needed for the test — no "kitchen sink" fixtures
- Testcontainers: fresh database per test suite (not per test, for speed)

## Continuous Testing During Development

### Watch mode
```bash
bun test --watch          # Re-run affected tests on file change
pytest -x --tb=short -q  # Run, stop on first failure, minimal output
go test ./... -run TestName  # Run specific test while developing
```

### Test-driven approach (for complex logic)
1. Write the failing test first (defines expected behavior)
2. Run: confirm it fails for the right reason
3. Implement just enough to make it pass
4. Refactor while keeping tests green

### Pre-commit test run
Run the fast subset before every commit:
```bash
bun test --bail     # Stop on first failure
pytest -x -q tests/unit/  # Unit tests only pre-commit
go test -short ./...       # Skip integration tests pre-commit
```

## Maintaining Test Suite Health

### Signs of an unhealthy test suite
- Tests that always pass regardless of implementation (testing nothing)
- Flaky tests (pass sometimes, fail sometimes)
- Tests that break when internals change but behavior doesn't
- Test suite taking > 10 minutes
- Coverage declining over time

### Fixing flaky tests
1. Identify the source of non-determinism (time, randomness, async timing, external service)
2. Mock or control the source
3. If unfixable, delete the test and replace with a more focused one
4. Never mark tests as `skip` without a linked issue and expiry date

### Coverage regression prevention
Add a coverage threshold check to CI:
```yaml
# Fail CI if coverage drops below threshold
- name: Check coverage
  run: |
    COVERAGE=$(cat coverage-summary.json | jq '.total.lines.pct')
    echo "Coverage: $COVERAGE%"
    node -e "if ($COVERAGE < 80) process.exit(1)"
```

## Testing Matrix by Layer

| Layer | Test Type | What to Test | Mock |
|-------|-----------|-------------|------|
| Domain logic | Unit | Business rules, invariants | Everything |
| Repository | Integration | Query correctness | Real DB via Testcontainers |
| Service | Unit | Orchestration, error handling | Repository, external services |
| API Handler | Integration | Request parsing, response format, auth | Service (or real) |
| UI Component | Unit | Render behavior, user interactions | API calls (MSW) |
| User journey | E2E | End-to-end flow | Nothing |
