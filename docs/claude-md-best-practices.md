# CLAUDE.md Best Practices

A developer's guide to writing `CLAUDE.md` files that actually work — clear,
maintainable, and scoped correctly so Claude Code behaves consistently across
every session.

---

## What CLAUDE.md Is (and Is Not)

`CLAUDE.md` is the first thing Claude reads when it opens your project. It
sets the context for every session — what the project is, how it's organized,
what commands matter, and what constraints must always apply.

**It is:**
- A project operating guide
- The source of truth for global conventions
- The place for constraints Claude must never violate

**It is not:**
- A knowledge base for every detail
- A place for area-specific rules (those go in `rules/`)
- A changelog or status doc
- A collection of personal preferences

The moment `CLAUDE.md` tries to be everything, it becomes useless as anything.

---

## File Hierarchy

Claude Code loads `CLAUDE.md` files from multiple locations and merges them.
Understanding the hierarchy prevents duplication and conflicts.

```
~/.claude/CLAUDE.md          # Global: applies to ALL projects for this user
    ↓ merged with
your-project/CLAUDE.md       # Project: applies to this repo for all team members
    ↓ merged with
CLAUDE.local.md              # Local: personal overrides for this project (not committed)
    ↓ merged with
src/CLAUDE.md                # Subdirectory: applies when Claude works in src/
```

More specific files take precedence. Local overrides win over project, which
wins over global.

### What belongs at each level

| Level | File | Put here |
|---|---|---|
| Global | `~/.claude/CLAUDE.md` | Your personal defaults across all projects (editor preferences, personal style) |
| Project | `CLAUDE.md` | Stack, architecture, shared conventions, hard constraints |
| Local | `CLAUDE.local.md` | Machine-specific notes, personal workflow tweaks |
| Subdirectory | `src/CLAUDE.md` | Rules specific to that subtree (e.g. different conventions in a subpackage) |

---

## Anatomy of a Good `CLAUDE.md`

### Recommended Sections

```markdown
# Project Name

## What This Is
{2–3 sentences. What the project does, who uses it.}

## Stack
{Technology list — framework, DB, cache, test tools, linter}

## Project Structure
{Directory map with one-line descriptions}

## Dev Commands
{The commands developers run every day}

## Conventions
{Rules that apply everywhere in the codebase}

## Hard Constraints
{Things Claude must never do, regardless of instructions}
```

Not every project needs all sections. Add what's useful; cut what isn't.

---

## Section-by-Section Guidance

### What This Is

Two to three sentences only. Answer: what does this system do, and who
depends on it?

```markdown
## What This Is
Customer-facing REST API for a B2B SaaS platform. Serves the web app,
mobile apps, and third-party integrations. Handles auth, billing, and
core product data.
```

Avoid: company history, roadmap notes, or anything that changes often.

---

### Stack

List the technologies Claude needs to know to make correct decisions.
Include versions when they affect syntax or behavior.

```markdown
## Stack
- Python 3.12 / FastAPI
- PostgreSQL 16 + SQLAlchemy 2.x (async)
- Redis 7 (cache + task queue)
- Alembic (migrations)
- Pytest + httpx (testing)
- Ruff (lint + format)
- Docker Compose (local infra)
```

Avoid: listing every dependency. Focus on what shapes how Claude writes code.

---

### Project Structure

A directory map with one-line descriptions. Claude uses this to know where
things live without reading every file first.

```markdown
## Project Structure
- `app/api/v1/`       → route handlers (thin — no business logic)
- `app/services/`     → business logic layer
- `app/repositories/` → DB query layer (SQLAlchemy)
- `app/models/`       → ORM models
- `app/schemas/`      → Pydantic request/response schemas
- `app/core/`         → config, dependencies, middleware
- `tests/`            → mirrors app/ structure
- `alembic/`          → migration scripts
```

Keep it shallow — top-level directories only. Deep nesting belongs in
subdirectory `CLAUDE.md` files or in `rules/`.

---

### Dev Commands

The commands developers actually run. If Claude knows these, it can run
them correctly without guessing.

```markdown
## Dev Commands
- `uvicorn app.main:app --reload`            → start dev server
- `pytest -x -v`                             → run tests (stop on first fail)
- `pytest --cov=app --cov-report=term-missing` → tests with coverage
- `ruff check . && ruff format .`            → lint and format
- `alembic upgrade head`                     → apply migrations
- `alembic revision --autogenerate -m "msg"` → generate new migration
- `docker compose up -d`                     → start postgres + redis
```

Avoid: documenting every flag or option. List the commands that matter for
daily development.

---

### Conventions

Rules that apply across the entire codebase. These are the things you'd
tell a new developer on day one.

```markdown
## Conventions
- Route handlers stay thin — validate input, call service, return response
- Business logic lives in services, not handlers or repositories
- All DB access goes through the repository layer
- Validate all request bodies with Pydantic schemas
- Use async/await throughout — never block the event loop
- Every new endpoint requires an integration test
- Use dependency injection for DB sessions, auth, and settings
```

**Write conventions as rules, not descriptions.** Say what to do, not what
the codebase currently happens to do.

✓ "Route handlers stay thin — business logic belongs in services."
✗ "We use a service layer for business logic in most cases."

---

### Hard Constraints

Things Claude must never do. These are your safety rails — the actions that
would cause irreversible damage, security incidents, or policy violations.

```markdown
## Hard Constraints
- Never read, log, or modify `.env` or any secrets file
- Never run `DROP`, `TRUNCATE`, or `DELETE` without a WHERE clause
  outside of Alembic migration scripts
- Never push directly to `main` or `develop`
- Never commit debug `print()` statements or commented-out code
- Never expose internal error details in API responses
```

**Keep this section short and genuinely hard.** If a constraint only matters
sometimes, it's a guideline — put it in `rules/` instead.

---

## Writing Style That Works

### Be directive, not descriptive

Claude follows instructions better than it infers intent from descriptions.

```markdown
# Weak — describes, doesn't instruct
The project uses a service layer for business logic.

# Strong — instructs
Keep route handlers thin. All business logic belongs in services/.
```

### Be specific, not vague

Vague rules create inconsistent behavior. Specific rules are followed
consistently.

```markdown
# Vague
Write good tests.

# Specific
Every new endpoint needs tests for: happy path, validation failure (422),
unauthorized (401), and not found (404).
```

### Use present tense

```markdown
# Wrong
The endpoint will validate inputs using Pydantic.

# Right
The endpoint validates inputs using Pydantic.
```

### One rule per bullet

Don't bundle multiple rules into one bullet. Claude treats each bullet as
one idea.

```markdown
# Hard to parse
- Use async DB sessions and always go through repositories and never
  expose ORM objects directly in responses.

# Easy to follow
- Use async DB sessions (`AsyncSession`) throughout.
- All DB access goes through the repository layer.
- Never return ORM model objects directly — serialize through schemas.
```

---

## What NOT to Put in CLAUDE.md

### Area-specific rules
Move to `.claude/rules/<concern>.md`.

```markdown
# Wrong — too specific for CLAUDE.md
- Every migration must have a reversible downgrade()
- Use selectinload for one-to-many relationships
- Add indexes for all foreign key columns
```

These belong in `.claude/rules/database.md`.

### Reusable prompt workflows
Move to `.claude/commands/<name>.md`.

```markdown
# Wrong — this is a command, not a project instruction
When reviewing a PR, check: correctness, security, test coverage,
API contract changes. Summarize as critical / medium / suggestions.
```

### Process details for complex workflows
Move to `.claude/skills/<name>/SKILL.md`.

```markdown
# Wrong — this is a skill, not a project rule
To prepare a release: check git log since last tag, list new migrations,
review for breaking changes, generate changelog, fill out release template.
```

### Personal preferences
Move to `CLAUDE.local.md` or `~/.claude/CLAUDE.md`.

```markdown
# Wrong — personal, not a team standard
Always give me short summaries. I prefer bullet points over paragraphs.
Don't ask for confirmation, just do the task.
```

### Outdated context
Delete it. Stale instructions are worse than no instructions — they
actively mislead Claude.

```markdown
# Wrong — this is a changelog entry, not a rule
(2024-03) We migrated from Django to FastAPI. Some legacy endpoints
still use the old pattern...
```

---

## Subdirectory CLAUDE.md Files

Place a `CLAUDE.md` inside a subdirectory to scope rules to that area.
Claude picks it up when working in that path.

### Good use cases

**Different conventions in a subpackage:**
```
services/legacy-integration/CLAUDE.md
```
```markdown
# Legacy Integration Service

This module wraps a third-party SOAP API. Conventions differ here:
- Sync HTTP only (no async) — the SOAP client doesn't support it
- XML parsing uses `lxml`, not standard library
- Error codes are strings, not HTTP status codes
```

**Stricter rules in sensitive directories:**
```
app/core/auth/CLAUDE.md
```
```markdown
# Auth Module — Strict Rules

- Never modify token validation logic without a security review
- All auth functions must have 100% test coverage
- No debug logging anywhere in this directory
- Changes here require two reviewers
```

**Frontend in a monorepo:**
```
frontend/CLAUDE.md
```
```markdown
# Frontend (Next.js)

Stack: Next.js 14, TypeScript, Tailwind CSS
- Prefer server components unless client interactivity is required
- Co-locate component tests with the component file
- All API calls go through the `lib/api/` layer
```

---

## Maintenance

### Signs your CLAUDE.md needs cleanup

- It's over 150 lines
- It contains instructions that only apply to part of the repo
- There are outdated references to removed features or old patterns
- You can't remember why a specific rule is there
- Teammates ask "does this rule still apply?"

### Review cadence

Treat `CLAUDE.md` like your `README.md` — review it when:
- You finish a major refactor
- The stack changes (new framework, new DB)
- A new developer joins and asks clarifying questions
- A convention changes and needs to be updated

### A test for every line

For each line in `CLAUDE.md`, ask:
1. Is this still true?
2. Does it apply to the whole project, or just a part?
3. Would a new developer benefit from knowing this on day one?
4. Is it prescriptive (a rule) or just descriptive (a fact)?

If any answer is "no", move or remove the line.

---

## Complete Example

A well-structured `CLAUDE.md` for a FastAPI backend:

```markdown
# Payments API

REST API for a B2B SaaS payments platform. Used by the web app, mobile
clients, and third-party integrations. Handles auth, subscriptions, and
transaction processing.

## Stack
- Python 3.12 / FastAPI
- PostgreSQL 16 + SQLAlchemy 2.x (async)
- Redis 7 (cache + Celery task queue)
- Stripe SDK (payment processing)
- Alembic (migrations)
- Pytest + httpx (testing)
- Ruff (lint + format)

## Project Structure
- `app/api/v1/`       → route handlers (thin)
- `app/services/`     → business logic
- `app/repositories/` → DB queries (SQLAlchemy)
- `app/models/`       → ORM models
- `app/schemas/`      → Pydantic schemas
- `app/tasks/`        → Celery background tasks
- `app/core/`         → config, deps, middleware
- `tests/`            → mirrors app/ structure
- `alembic/`          → migrations

## Dev Commands
- `uvicorn app.main:app --reload`  → dev server
- `pytest -x -v`                   → tests
- `ruff check . && ruff format .`  → lint + format
- `alembic upgrade head`           → apply migrations
- `docker compose up -d`           → start infra
- `celery -A app.tasks worker`     → start task worker

## Conventions
- Route handlers stay thin: validate → call service → return schema
- Business logic belongs in services, not handlers or repositories
- All DB access goes through repositories
- Validate all inputs with Pydantic schemas
- Use async/await everywhere — no blocking calls in async context
- Every new endpoint needs integration tests (happy path + failure cases)
- Use dependency injection for DB sessions, auth, settings

## Hard Constraints
- Never read or modify `.env` or any secrets file
- Never run destructive SQL (DROP, TRUNCATE, DELETE without WHERE) outside migrations
- Never push directly to main or develop
- Never expose Stripe keys, internal IDs, or stack traces in API responses
- Never commit debug prints or commented-out code
```

---

## Summary Checklist

Before committing your `CLAUDE.md`:

- [ ] Under 100–150 lines (if longer, move specifics to `rules/`)
- [ ] Every section is prescriptive (rules), not just descriptive (facts)
- [ ] No area-specific rules that should live in `rules/`
- [ ] No reusable workflows that should live in `commands/` or `skills/`
- [ ] No personal preferences that should live in `CLAUDE.local.md`
- [ ] Hard constraints section is genuinely hard — not just guidelines
- [ ] Dev commands are current and correct
- [ ] Project structure reflects the actual directory layout
- [ ] No stale references to removed features or old patterns
- [ ] A new developer reading this would get an accurate picture in 2 minutes
