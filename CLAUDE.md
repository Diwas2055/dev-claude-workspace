# dev-claude-workspace

## Stack
- Python 3.12 / FastAPI
- PostgreSQL + SQLAlchemy (async)
- Redis (caching, queues)
- Docker / Docker Compose
- Pytest + httpx for testing
- Ruff for linting & formatting
- Alembic for migrations

## Project Structure
- `app/api/`        → route definitions (thin handlers only)
- `app/services/`   → business logic
- `app/models/`     → SQLAlchemy ORM models
- `app/schemas/`    → Pydantic request/response schemas
- `app/repositories/` → DB query layer
- `app/core/`       → config, deps, middleware
- `tests/`          → mirrors app/ structure
- `alembic/`        → migration scripts

## Dev Commands
- `uvicorn app.main:app --reload`  → start dev server
- `pytest -x -v`                   → run tests
- `ruff check . && ruff format .`  → lint + format
- `alembic upgrade head`           → apply migrations
- `alembic revision --autogenerate -m "description"` → new migration
- `docker compose up -d`           → start infra (postgres, redis)

## Broad Conventions
- Keep route handlers thin — all logic lives in services
- Validate all inputs with Pydantic schemas; never trust raw dicts
- Use async/await throughout; never block the event loop
- All DB access goes through the repository layer
- Never expose internal exception details in API responses
- Every new endpoint needs a corresponding integration test
- Use dependency injection for DB sessions, settings, and auth

## Hard Constraints
- Never read or modify `.env` or any secrets file
- Never run `DROP`, `TRUNCATE`, or `DELETE` without a WHERE clause outside migrations
- Never push directly to `main` or `develop`
- Never commit debug prints or commented-out code
