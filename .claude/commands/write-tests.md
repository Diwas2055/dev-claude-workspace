# write-tests

Write integration tests for the specified module or endpoint.

## Instructions

1. Identify what is being tested: endpoint, service function, or repository method
2. Check `tests/` for existing fixtures in `conftest.py` — reuse them
3. Write tests in the correct mirror location under `tests/`

## Required Coverage per Endpoint

- Happy path with valid input → assert correct status code + response shape
- Missing required fields → assert 422 Unprocessable Entity
- Invalid field types → assert 422 with field-specific error
- Unauthorized request (no token) → assert 401
- Forbidden request (wrong role/ownership) → assert 403
- Not found (nonexistent ID) → assert 404
- Duplicate/conflict (if applicable) → assert 409

## Test Structure

```python
async def test_<action>_<context>(client: AsyncClient, db_session: AsyncSession):
    # Arrange
    ...
    # Act
    response = await client.post("/api/v1/...", json={...})
    # Assert
    assert response.status_code == 201
    data = response.json()
    assert data["field"] == expected_value
```

## Rules
- Use factory functions for test data — never hardcoded UUIDs or emails
- Each test must be fully isolated — no shared state between tests
- Do not mock the DB — hit the test database
- Only mock external HTTP calls (third-party APIs, email, SMS)
