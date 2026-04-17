# Testing Rules

## Structure
- Test files mirror app/ structure: `tests/api/`, `tests/services/`, `tests/repositories/`
- One test file per module: `tests/api/test_users.py` for `app/api/users.py`
- Use `conftest.py` for shared fixtures — never duplicate fixture setup

## What to Test
- Every new endpoint must have at least: happy path, validation failure, auth failure
- Services must be tested independently of HTTP layer
- Repository tests must hit a real test database — no mocking the DB layer
- Test edge cases explicitly: empty lists, None values, boundary conditions

## Fixtures
- Use `pytest-asyncio` with `asyncio_mode = "auto"` in `pytest.ini`
- DB fixture must create a fresh schema per test session and rollback per test
- Use factory functions (not hardcoded data) to create test objects
- Never rely on test execution order — each test must be fully isolated

## Assertions
- Assert on specific fields, not entire object equality
- For error responses, assert both status code AND error message content
- Use `pytest.raises` for expected exceptions — never bare try/except in tests

## Running Tests
- `pytest -x -v` → stop on first failure, verbose
- `pytest --cov=app --cov-report=term-missing` → coverage report
- CI must pass 100% of tests before merge — no skipped tests without comment

## What NOT to Mock
- Never mock SQLAlchemy sessions or repositories in integration tests
- Never mock Redis in tests that verify cache behavior
- Only mock: external HTTP APIs, email services, third-party SDKs
