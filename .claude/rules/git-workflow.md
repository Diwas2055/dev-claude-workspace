# Git Workflow Rules

## Branching
- Branch from `develop` for all features and fixes
- Branch naming: `feature/TICKET-123-short-description`, `fix/TICKET-456-short-description`
- Never work directly on `main` or `develop`
- Delete branches after merging

## Commits
- Use conventional commits: `feat:`, `fix:`, `chore:`, `refactor:`, `test:`, `docs:`
- Commit message subject: imperative, ≤72 chars, no trailing period
- Body (optional): explain WHY, not WHAT — the diff shows what
- Never commit: debug prints, commented-out code, `.env` files, `*.pyc`
- Each commit must leave the codebase in a working state

## Pull Requests
- PR title matches the commit convention
- PR description must include: what changed, why, how to test
- Link the Linear/Jira ticket in the PR description
- All CI checks must pass before requesting review
- Squash merge into `develop` — keep history clean
- Never force-push to shared branches

## Code Review
- Respond to all review comments before merging
- "Approved with nits" means nits must be addressed before merge
- Reviewer must re-approve after significant post-review changes

## Forbidden
- `git push --force` on `main` or `develop`
- `git reset --hard` without explicit user confirmation
- Merging your own PR without a second reviewer
