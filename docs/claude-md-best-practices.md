# CLAUDE.md Best Practices — FastAPI & Python

A practical guide to writing `CLAUDE.md` files that make Claude Code
produce correct, idiomatic FastAPI + Python code from the first response.

---

## What CLAUDE.md Is (and Is Not)

Claude reads `CLAUDE.md` at the start of every session. It sets the mental
model for the entire conversation — what the project is, how it's organized,
what patterns to follow, and what must never happen.

**It is:**
- A project operating guide
- The source of truth for project-specific conventions
- The place for constraints Claude must always respect

**It is not:**
- A tutorial on FastAPI or SQLAlchemy (Claude already knows those)
- A changelog or status document
- A place for personal preferences
- An exhaustive list of every rule (use `rules/` for that)

> **Keep it under 150–200 lines.** Claude's built-in knowledge already
> covers roughly a third of common FastAPI patterns. CLAUDE.md should
> cover only what is *specific to your project*.

---

## File Hierarchy

Claude merges `CLAUDE.md` files from multiple locations. More specific
files take precedence.

```
~/.claude/CLAUDE.md          # Global — your personal defaults across all projects
    ↓
your-project/CLAUDE.md       # Project — shared by the whole team
    ↓
CLAUDE.local.md              # Local — personal overrides, never committed
    ↓
app/core/CLAUDE.md           # Subdirectory — scoped to that path only
```

| Level | File | Put here |
|---|---|---|
| Global | `~/.claude/CLAUDE.md` | Personal style, preferred tools across all repos |
| Project | `CLAUDE.md` | Stack, architecture, shared conventions, hard constraints |
| Local | `CLAUDE.local.md` | Machine-specific notes, local port overrides |
| Subdirectory | `<dir>/CLAUDE.md` | Rules specific to one sensitive or divergent area |

> Add `CLAUDE.local.md` and `.claude/settings.local.json` to `.gitignore`.

---

## Recommended Sections

Not every project needs every section. Add what's genuinely useful.
Delete what isn't. An accurate short file beats an exhaustive stale one.

```markdown
## Project Overview
## Tech Stack
## Project Structure
## Dev Commands
## Architecture & Patterns
## Async Conventions          ← critical for FastAPI
## Database Conventions       ← critical for SQLAlchemy async
## Coding Conventions
## Testing Rules
## Hard Constraints
```

---

## Section 1 — Project Overview

Two to three sentences. Answer: what does this system do, who uses it,
and what does it optimize for?

**Good:**
```markdown
## Project Overview
REST API backend for a B2B SaaS payments platform. Serves the web app,
mobile clients, and third-party integrations. Optimizes for reliability,
auditability, and fast iteration — prefer clarity over cleverness.
```

**Bad:**
```markdown
## Project Overview
This project was started in 2022 by our team to modernize the legacy
system. We value quality, innovation, and developer experience...
```

Keep it short enough that Claude can extract a crisp mental model from it.
Brand history and roadmap notes do not belong here.

---

## Section 2 — Tech Stack

State the actual technologies. Without this, Claude may introduce
libraries that are technically valid but wrong for your project.

Be explicit about versions when they affect syntax or behavior —
SQLAlchemy 2.x async API is very different from 1.x.

```markdown
## Tech Stack
- Python 3.12
- FastAPI (latest)
- PostgreSQL 16
- SQLAlchemy 2.x — async only (`AsyncSession`, `select()` query style)
- Alembic (migrations)
- Redis 7 (cache + task queue)
- Pytest + pytest-asyncio (testing)
- Ruff (lint + format)
- uv (package manager)
- Docker Compose (local infra)

Do NOT introduce:
- Celery (we use Redis queues directly)
- SQLModel (we use raw SQLAlchemy 2.x)
- Any sync DB driver (psycopg2 — use asyncpg only)
```

The "do not introduce" list is as important as the stack list.

---

## Section 3 — Project Structure

A shallow directory map with one-line purpose descriptions. Claude uses
this to know where things live without reading every file first.

```markdown
## Project Structure
- `app/api/v1/`         → route handlers (thin — no business logic)
- `app/services/`       → business logic layer
- `app/repositories/`   → DB query layer (SQLAlchemy async)
- `app/models/`         → SQLAlchemy ORM models
- `app/schemas/`        → Pydantic v2 request/response schemas
- `app/core/`           → config, dependencies, middleware, exceptions
- `app/tasks/`          → background tasks (Redis queue workers)
- `tests/`              → mirrors app/ structure
- `alembic/`            → migration scripts

Where new things go:
- New resource → one file per layer: model, schema, repository, service, router
- New background job → app/tasks/<name>.py
- New shared utility → app/core/<concern>.py
```

Keep it shallow — top level only. Deep nesting belongs in subdirectory
`CLAUDE.md` files or in `rules/`.

---

## Section 4 — Dev Commands

The commands developers run every day. Specify your actual package
manager (`uv`, `pip`, `poetry`) — do not assume.

```markdown
## Dev Commands
- `uv sync`                                          → install dependencies
- `uvicorn app.main:app --reload`                    → dev server
- `uv run pytest -x -v`                              → run tests
- `uv run pytest --cov=app --cov-report=term-missing` → with coverage
- `ruff check . && ruff format .`                    → lint + format
- `alembic upgrade head`                             → apply migrations
- `alembic revision --autogenerate -m "description"` → new migration
- `docker compose up -d`                             → start postgres + redis
```

---

## Section 5 — Architecture & Patterns

This is where you teach Claude the layered structure and its rules.

Focus on **decision rules**, not just folder names.

```markdown
## Architecture & Patterns
Three-layer architecture: Router → Service → Repository.

Rules:
- Route handlers validate input, call one service method, return a schema
- Services contain all business logic — no HTTP types, no DB sessions
- Repositories handle all DB queries — services never call SQLAlchemy directly
- Dependencies (DB session, current user, settings) injected via `Depends()`
- Domain exceptions raised in services, caught and mapped to HTTPException in routers
- All collection endpoints return paginated responses: `{ items, total, page, size }`
```

---

## Section 6 — Async Conventions (Critical)

This is the most important FastAPI-specific section. Claude frequently
generates sync/async mixing errors without explicit guidance here.

```markdown
## Async Conventions
This project is fully async. These rules have no exceptions.

- Always use `AsyncSession` — never the sync `Session`
- Use `select()` query style — never the legacy `session.query()` API
- Use `await session.execute(select(...))` pattern throughout
- Lazy loading is disabled in async — always use `selectinload()` or
  `joinedload()` explicitly for related objects
- Never call blocking functions inside async context — wrap with
  `asyncio.run_in_executor()` if a sync library is unavoidable
- Use `asyncio.gather()` for concurrent independent async calls
- Background tasks use FastAPI's `BackgroundTasks` or the Redis queue —
  never `asyncio.create_task()` inside a request handler
```

Without this section, Claude will regularly produce N+1 queries, missing
`await` calls, and sync/async mixing — all of which fail at runtime.

---

## Section 7 — Database Conventions

```markdown
## Database Conventions
- All DB access goes through the repository layer — never from services
- ORM models live in app/models/ — one file per resource
- Use SQLAlchemy 2.x `Mapped` / `mapped_column` annotations (not legacy Column)
- Every model includes: `id: Mapped[UUID]`, `created_at: Mapped[datetime]`,
  `updated_at: Mapped[datetime]`
- Relationships declared with `relationship()` + explicit `selectinload` at query time
- No raw SQL strings in application code — ORM expressions only
- Raw SQL is acceptable only inside Alembic migration scripts

Alembic workflow:
- Every schema change needs a migration — never alter tables manually
- Always review autogenerated migrations before applying — autogenerate
  misses: partial indexes, custom constraints, enum type changes
- Every migration must have a working `downgrade()`
- Migration message format: `alembic revision --autogenerate -m "add_user_avatar_url"`
```

---

## Section 8 — Coding Conventions

Rules that directly impact the quality and consistency of generated code.

```markdown
## Coding Conventions
- Type-annotate all function signatures — parameters and return types
- Strict typing: avoid `Any`; use `Unknown` or explicit unions instead
- Use `from __future__ import annotations` only when needed for forward refs
- `snake_case` for variables, functions, modules
- `PascalCase` for classes and Pydantic models
- `SCREAMING_SNAKE_CASE` for module-level constants
- Boolean names use `is_`, `has_`, `can_` prefix
- No comments by default — only when the WHY is non-obvious
- No `print()` — use structured logging (`loguru` or stdlib `logging`)
- No dead code, no commented-out blocks
- Max function length ~30 lines before considering a split
- Prefer early returns / guard clauses over deeply nested conditionals
- Named exports for shared modules; default export only for route files
```

---

## Section 9 — Testing Rules

Tell Claude what "done" means, or it will decide for you.

```markdown
## Testing Rules
Tests live in tests/ mirroring app/ structure.

Required coverage per endpoint:
- Happy path (200/201 with correct response shape)
- Validation failure → 422
- Unauthorized → 401
- Forbidden (wrong role/ownership) → 403
- Not found → 404
- Conflict/duplicate → 409 (where applicable)

Rules:
- Use pytest-asyncio with `asyncio_mode = "auto"` in pytest.ini
- Hit the real test database — never mock SQLAlchemy sessions or repos
- Only mock: external HTTP APIs, email, SMS, third-party SDKs
- Use factory functions for test data — never hardcoded UUIDs or emails
- Each test must be fully isolated — no shared state, no order dependency
- Use `pytest.raises` for expected exceptions

Before considering any task complete:
- `ruff check .` passes
- `uv run pytest -x` passes
- No unresolved type errors
```

---

## Section 10 — Hard Constraints

Things Claude must never do. Keep this short and genuinely hard —
not guidelines, not preferences.

```markdown
## Hard Constraints
- Never read, log, or modify .env or any secrets file
- Never use sync SQLAlchemy Session — always AsyncSession
- Never run DROP, TRUNCATE, or DELETE without WHERE outside migrations
- Never put business logic in route handlers
- Never expose internal exception details, stack traces, or ORM objects
  in API responses
- Never push directly to main or develop
- Never commit debug print() statements or commented-out code
- Never introduce a new dependency without listing it in pyproject.toml
```

---

## Complete Example

A well-structured `CLAUDE.md` for a FastAPI + PostgreSQL project:

```markdown
# Payments API

REST API for a B2B SaaS payments platform. Serves the web app, mobile
clients, and third-party integrations. Handles auth, subscriptions, and
transaction processing. Optimize for reliability and auditability —
prefer clarity over cleverness.

## Tech Stack
- Python 3.12 / FastAPI
- PostgreSQL 16 + SQLAlchemy 2.x (async only)
- Redis 7 (cache + task queue)
- Alembic (migrations)
- Pytest + pytest-asyncio
- Ruff (lint + format)
- uv (package manager)

Do NOT introduce: Celery, SQLModel, psycopg2, sync Session.

## Project Structure
- `app/api/v1/`       → route handlers (thin)
- `app/services/`     → business logic
- `app/repositories/` → SQLAlchemy async queries
- `app/models/`       → ORM models (SQLAlchemy 2.x Mapped style)
- `app/schemas/`      → Pydantic v2 schemas
- `app/core/`         → config, deps, middleware, exceptions
- `tests/`            → mirrors app/
- `alembic/`          → migrations

## Dev Commands
- `uv sync`                            → install deps
- `uvicorn app.main:app --reload`      → dev server
- `uv run pytest -x -v`                → tests
- `ruff check . && ruff format .`      → lint + format
- `alembic upgrade head`               → apply migrations
- `docker compose up -d`               → start infra

## Architecture & Patterns
Router → Service → Repository. No exceptions.
- Handlers: validate → call service → return schema
- Services: business logic only, no HTTP types, no DB calls
- Repositories: all SQLAlchemy queries, typed return types
- Inject DB session, auth, settings via Depends()
- Paginate all collection endpoints: { items, total, page, size }

## Async Conventions
Fully async — no exceptions.
- Always AsyncSession, never Session
- select() query style — never session.query()
- Explicitly use selectinload() / joinedload() — lazy loading is disabled
- Never block the event loop — wrap sync libs in run_in_executor()
- asyncio.gather() for concurrent independent awaits

## Database Conventions
- All DB access through repositories — services never touch SQLAlchemy
- Use Mapped / mapped_column annotations (SQLAlchemy 2.x style)
- Every model: id UUID PK, created_at, updated_at
- Every schema change needs an Alembic migration
- Always review autogenerated migrations — never apply blindly
- Every migration must have a working downgrade()

## Coding Conventions
- Type-annotate all signatures
- No Any without justification
- No print() — use loguru
- No comments unless WHY is non-obvious
- No dead code or commented-out blocks
- Early returns over deep nesting

## Testing Rules
- pytest-asyncio with asyncio_mode = "auto"
- Real test DB — no session mocking
- Factory functions for test data
- Per endpoint: 200/201, 422, 401, 403, 404 tests minimum
- Only mock: external HTTP APIs, email, SMS

## Hard Constraints
- Never read or modify .env or secrets files
- Never use sync Session — always AsyncSession
- Never put business logic in route handlers
- Never expose stack traces or ORM objects in API responses
- Never push to main or develop directly
- Never commit print() or commented-out code
```

---

## What NOT to Put in CLAUDE.md

| This belongs in... | Not in CLAUDE.md |
|---|---|
| `.claude/rules/database.md` | Migration steps, index rules, N+1 patterns |
| `.claude/rules/testing.md` | Detailed fixture setup, mock boundaries |
| `.claude/rules/security.md` | Auth patterns, secrets management detail |
| `.claude/commands/review-pr.md` | PR review workflow |
| `.claude/skills/release-prep/` | Release process steps |
| `CLAUDE.local.md` | Personal preferences, local port overrides |
| `~/.claude/CLAUDE.md` | Cross-project personal defaults |

---

## Subdirectory CLAUDE.md Files

Place a `CLAUDE.md` inside a subdirectory to scope rules to that path.
Claude picks it up automatically when working there.

**Sensitive auth module:**
```
app/core/auth/CLAUDE.md
```
```markdown
# Auth Module — Strict Rules
- Never modify token validation without a security review
- 100% test coverage required on all functions in this directory
- No debug logging — tokens must never appear in logs
- Changes require two reviewers
```

**Legacy integration with different conventions:**
```
app/integrations/legacy/CLAUDE.md
```
```markdown
# Legacy Integration
This module wraps a third-party SOAP API. Conventions differ here:
- Sync HTTP only (SOAP client has no async support) — wrap calls in run_in_executor()
- XML parsing uses lxml, not stdlib
- Error codes are strings, not HTTP status integers
```

---

## Maintenance Checklist

Before committing any change to `CLAUDE.md`:

- [ ] Under 150–200 lines total
- [ ] Every rule is prescriptive ("do X") not just descriptive ("we use X")
- [ ] Async conventions section is present and explicit
- [ ] No area-specific rules that belong in `rules/`
- [ ] No reusable workflows that belong in `commands/` or `skills/`
- [ ] No personal preferences that belong in `CLAUDE.local.md`
- [ ] Hard constraints are genuinely hard — not guidelines
- [ ] Dev commands match actual project tooling (uv vs pip vs poetry)
- [ ] Stack section includes "do not introduce" list
- [ ] No stale references to removed patterns or old libraries
- [ ] A new developer reading this gets an accurate picture in 2 minutes

---

## Using `/init` to Bootstrap

If starting from scratch, run:

```
/init
```

Claude Code analyzes your actual project structure and generates a first-draft
`CLAUDE.md` tailored to what it finds. Use that as the starting point, then
apply this guide to refine it — especially the async conventions and hard
constraints sections, which `/init` often leaves generic.
