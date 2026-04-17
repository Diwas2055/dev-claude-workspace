# dev-claude-workspace

A production-ready FastAPI backend workspace pre-configured with a structured `.claude/` folder for maximum developer efficiency with Claude Code.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | FastAPI (Python 3.12) |
| Database | PostgreSQL + SQLAlchemy (async) |
| Cache / Queue | Redis |
| Migrations | Alembic |
| Testing | Pytest + httpx |
| Linting / Format | Ruff |
| Infrastructure | Docker + Docker Compose |

---

## Project Structure

```
dev-claude-workspace/
├── app/
│   ├── api/v1/          # Route handlers (thin — no business logic here)
│   ├── services/        # Business logic layer
│   ├── repositories/    # DB query layer (SQLAlchemy)
│   ├── models/          # ORM models
│   ├── schemas/         # Pydantic request/response schemas
│   └── core/            # Config, dependencies, middleware
├── tests/               # Mirrors app/ structure
├── alembic/             # Migration scripts
├── CLAUDE.md            # Claude Code — global project instructions
├── CLAUDE.local.md      # Claude Code — personal overrides (not committed)
└── .claude/             # Claude Code configuration (see below)
```

---

## Quick Start

```bash
# 1. Start infrastructure
docker compose up -d

# 2. Install dependencies
uv sync

# 3. Apply database migrations
alembic upgrade head

# 4. Start dev server
uvicorn app.main:app --reload

# 5. Run tests
pytest -x -v

# 6. Lint and format
ruff check . && ruff format .
```

---

## .claude/ Folder — Claude Code Setup

This workspace ships with a fully structured `.claude/` folder. Every part has a specific purpose — nothing is a placeholder.

```
.claude/
├── settings.json          # Permissions + hook wiring
├── settings.local.json    # Local-only permission overrides (not committed)
├── rules/                 # Modular developer rules by concern
├── hooks/                 # Auto-running scripts (format, block, validate)
├── commands/              # Reusable prompt workflows
├── skills/                # Multi-step packaged workflows
└── agents/                # Specialized role-based AI personas
```

### Rules

Scoped instruction files — each owns one engineering concern.

| File | Covers |
|---|---|
| [rules/api.md](.claude/rules/api.md) | Route design, schemas, error handling, versioning |
| [rules/database.md](.claude/rules/database.md) | ORM patterns, repositories, migrations, indexes |
| [rules/testing.md](.claude/rules/testing.md) | Test structure, fixtures, coverage, what NOT to mock |
| [rules/security.md](.claude/rules/security.md) | Auth, input validation, secrets, logging, dependencies |
| [rules/code-style.md](.claude/rules/code-style.md) | Python style, naming, async, imports, comments |
| [rules/git-workflow.md](.claude/rules/git-workflow.md) | Branching, commits, PRs, forbidden actions |

### Hooks

Scripts that fire automatically — wired in `settings.json`.

| Script | Trigger | What it does |
|---|---|---|
| [format-on-edit.sh](.claude/hooks/format-on-edit.sh) | After every file edit | Runs `ruff format` + `ruff check --fix` on changed `.py` file |
| [block-dangerous-commands.sh](.claude/hooks/block-dangerous-commands.sh) | Before every shell command | Blocks `rm -rf`, `git push --force`, `DROP TABLE`, `.env` access, etc. |
| [pre-stop-checks.sh](.claude/hooks/pre-stop-checks.sh) | Before Claude stops | Checks for lint issues, debug prints, merge conflict markers |
| [notify-on-completion.sh](.claude/hooks/notify-on-completion.sh) | When Claude stops | Prints session summary: branch, timestamp, files changed |

### Commands

Reusable prompt workflows — invoke by name in Claude Code.

| Command | Purpose |
|---|---|
| [review-pr](.claude/commands/review-pr.md) | Structured PR review: correctness, security, tests, API contracts |
| [write-tests](.claude/commands/write-tests.md) | Generate integration tests with full coverage spec |
| [investigate-bug](.claude/commands/investigate-bug.md) | 5-step systematic bug investigation process |
| [add-endpoint](.claude/commands/add-endpoint.md) | Full endpoint scaffold checklist: schema → model → repo → service → route → tests |
| [summarize-changes](.claude/commands/summarize-changes.md) | Generate PR description or release notes from current branch diff |

**Usage:**
```
/review-pr
/write-tests
/add-endpoint
```

### Skills

Packaged multi-step workflows with supporting files — for complex, repeatable processes.

| Skill | Purpose |
|---|---|
| [release-prep](.claude/skills/release-prep/) | Cut a release: changelog, migration checklist, deployment steps |
| [api-audit](.claude/skills/api-audit/) | Full API surface audit with a per-endpoint checklist |
| [db-migration](.claude/skills/db-migration/) | Safe migration generation, review, and test workflow |
| [onboarding-docs](.claude/skills/onboarding-docs/) | Generate developer guides for modules and features |

> **Commands vs Skills:** Use a command when the task fits in one prompt file. Use a skill when the workflow has multiple steps, needs companion documents, or is important enough to standardize carefully.

### Agents

Specialized role-based personas with narrow, focused expertise.

| Agent | Role | Use When |
|---|---|---|
| [code-reviewer](.claude/agents/code-reviewer.md) | Senior backend reviewer | PR review, pre-merge spot checks |
| [security-auditor](.claude/agents/security-auditor.md) | AppSec engineer | Auth flows, new endpoints, security-sensitive releases |
| [test-writer](.claude/agents/test-writer.md) | Integration test expert | Generating or expanding Pytest + httpx test coverage |
| [db-expert](.claude/agents/db-expert.md) | PostgreSQL + SQLAlchemy specialist | Schema design, N+1 issues, migration strategy, index review |
| [documentation-editor](.claude/agents/documentation-editor.md) | Technical writer | API docs, ADRs, module guides, onboarding material |

---

## Permissions

`settings.json` pre-configures what Claude is and is not allowed to run:

**Allowed automatically:**
- `pytest`, `ruff`, `uvicorn`, `alembic`, `docker compose`
- `uv add`, `uv run`, `pip install`
- Safe git commands: `status`, `diff`, `log`, `add`, `commit`, `checkout`, `branch`, `pull`

**Always blocked:**
- `git push --force`, `git reset --hard`
- `rm -rf`
- `DROP TABLE`, `TRUNCATE`, `DROP DATABASE`
- Reading `.env`, secrets, or credentials files

---

## Team vs Personal Configuration

| File | Committed | Purpose |
|---|---|---|
| `CLAUDE.md` | Yes | Shared project instructions for all team members |
| `.claude/settings.json` | Yes | Shared permissions, hooks, and project behavior |
| `.claude/rules/*` | Yes | Shared engineering standards |
| `CLAUDE.local.md` | No | Personal overrides for local workflow |
| `.claude/settings.local.json` | No | Personal/machine-specific permission overrides |

Add `CLAUDE.local.md` and `.claude/settings.local.json` to `.gitignore`.

---

## Development Conventions

- **Route handlers stay thin** — validate input, call service, return response
- **Business logic lives in services** — never in handlers or repositories
- **All DB access through repositories** — services never query directly
- **Every new endpoint needs an integration test** — no exceptions
- **No raw SQL in application code** — Alembic migrations only
- **Async everywhere** — never block the event loop

---

## Adding to This Structure

| What you want to add | Where it goes |
|---|---|
| New project-wide rule | `.claude/rules/<concern>.md` |
| Repeatable single-step prompt | `.claude/commands/<name>.md` |
| Complex multi-step workflow | `.claude/skills/<name>/SKILL.md` + supporting files |
| Specialized AI persona | `.claude/agents/<role>.md` |
| Auto-running automation | `.claude/hooks/<name>.sh` + wire in `settings.json` |
| Personal preference | `CLAUDE.local.md` or `~/.claude/CLAUDE.md` |

---

## Resources

- [Claude Code Docs](https://docs.anthropic.com/claude-code)
- [FastAPI Docs](https://fastapi.tiangolo.com)
- [SQLAlchemy Async Docs](https://docs.sqlalchemy.org/en/20/orm/extensions/asyncio.html)
- [Alembic Docs](https://alembic.sqlalchemy.org)
- [Ruff Docs](https://docs.astral.sh/ruff)
