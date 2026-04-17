# summarize-changes

Summarize the current branch changes for a PR description or release note.

## Instructions

1. Run `git diff develop...HEAD --stat` to see files changed
2. Run `git log develop...HEAD --oneline` to see commits
3. Read the changed files to understand what was modified

## Output Format

### What changed
- Bullet list of changes grouped by area (API, DB, services, tests)
- Be specific: "Added `POST /api/v1/users/{id}/avatar` endpoint" not "updated users"

### Why
- One sentence on the motivation (from ticket context or code comments)

### How to test
- Steps to manually verify the change works
- Which automated tests cover this

### Migration required?
- Yes / No
- If yes: migration filename and what it does

### Breaking changes?
- Yes / No
- If yes: what breaks and what consumers must update

Keep the summary under 200 words. Be concrete, not vague.
