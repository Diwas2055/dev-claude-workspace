# Release v{VERSION} — {DATE}

## Summary
{One paragraph describing what this release delivers}

---

## Features
- {feat: commit summary}

## Bug Fixes
- {fix: commit summary}

## Breaking Changes
- {List any breaking API or schema changes, or "None"}

---

## Database Migrations
| Migration File | Description | Reversible |
|---|---|---|
| `{filename}` | {what it does} | Yes / No |

**To apply:** `alembic upgrade head`
**To rollback:** `alembic downgrade -1`

---

## Environment Variables
| Variable | Required | Default | Notes |
|---|---|---|---|
| `{VAR_NAME}` | Yes / No | `{default}` | {description} |

---

## Deployment Steps
1. Pull latest image / deploy code
2. Run migrations: `alembic upgrade head`
3. Restart application servers
4. Verify health check: `GET /api/v1/health`
5. Run smoke tests

---

## Rollback Plan
1. Revert deployment to previous version tag
2. Run: `alembic downgrade -1` (if migration was applied)
3. Verify health check passes
