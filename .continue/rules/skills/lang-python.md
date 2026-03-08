# Python Standards

## Style
- Ruff for linting + formatting (88 char line length, double quotes)
- Imports: stdlib → third-party → internal, separated by blank lines
- Type hints on ALL public functions; strict mypy: `strict = true`
- Use `X | None` (not `Optional[X]`); `list[T]`, `dict[K, V]` (not `List`, `Dict`)

## Naming
- `snake_case` variables/functions, `PascalCase` classes, `SCREAMING_SNAKE_CASE` constants
- Private: `_single_underscore`; test files: `test_<module>.py`

## FastAPI
- Pydantic v2 models for all request/response schemas
- `Depends()` for DI (services, auth, DB sessions)
- `APIRouter` grouped by feature; lifespan context manager for startup/shutdown
- `HTTPException` for HTTP errors; custom handlers for domain errors

## SQLAlchemy 2.x
- Async session; `select()` syntax (not legacy `session.query()`)
- Alembic for migrations; explicit `async with session.begin()` transaction boundaries
- No ORM calls in domain/core layer — use repository pattern

## Testing (pytest + pytest-asyncio)
- `httpx.AsyncClient` for FastAPI integration tests
- `factory_boy` for test data factories
- Transaction rollback fixture for DB tests
- `pytest.mark.parametrize` for data-driven tests

## Modern Python (3.12+)
- `dataclasses(frozen=True, slots=True)` for value objects
- `pathlib.Path` everywhere; `asyncio.TaskGroup` for structured concurrency
- `pydantic-settings` for env var configuration; `uv` as package manager
