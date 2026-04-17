# {Module Name} — Developer Guide

## Overview
{2-3 sentences: what this module does and why it exists}

## Entry Points
| Type | Path | Description |
|---|---|---|
| API Route | `app/api/v1/{resource}.py` | {description} |
| Background Task | `app/tasks/{name}.py` | {description} |

## Key Files
| File | Purpose |
|---|---|
| `app/models/{name}.py` | {description} |
| `app/schemas/{name}.py` | {description} |
| `app/services/{name}.py` | {description} |
| `app/repositories/{name}.py` | {description} |

## Core Flow: {Main Workflow Name}

```
POST /api/v1/{resource}
  → app/api/v1/{resource}.py :: create_{resource}()
  → app/services/{resource}.py :: create()
    → validates business rules
    → app/repositories/{resource}.py :: create()
      → INSERT INTO {table}
  ← Returns {ResourceResponse}
```

## Data Model
{Brief description of the DB table and key fields}
Key relationships: {list FK relationships}

## External Dependencies
| Dependency | Purpose | Failure behavior |
|---|---|---|
| {service} | {what it does} | {what happens if it's down} |

## Gotchas & Non-obvious Behavior
- {Constraint or invariant that would surprise a new developer}
- {Known tech debt: reference ticket if exists}
- {Edge case that has caused bugs before}

## How to Test Locally
```bash
# 1. Start infra
docker compose up -d

# 2. Apply migrations
alembic upgrade head

# 3. Run relevant tests
pytest tests/api/test_{resource}.py -v
```
