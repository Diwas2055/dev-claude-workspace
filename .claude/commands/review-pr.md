# review-pr

Review the current branch changes as a senior backend developer.

## Focus Areas

**Correctness**
- Does the logic match the intent of the ticket?
- Are there off-by-one errors, race conditions, or wrong assumptions?
- Are all edge cases handled (empty input, None, zero, large values)?

**API Contract**
- Are request/response schemas correct and complete?
- Are status codes appropriate for each case?
- Does this change break any existing API consumers?

**Security**
- Is user input validated before use?
- Are there any injection risks (SQL, shell, path)?
- Is authorization enforced on the new/modified endpoints?

**Database**
- Are there N+1 query risks?
- Are new columns/tables covered by a migration?
- Are indexes added where needed?

**Tests**
- Is the happy path tested?
- Are failure cases (4xx, 5xx) tested?
- Is test coverage acceptable for the risk level of this change?

## Output Format

Summarize findings in three sections:
1. **Critical** — must fix before merge
2. **Medium** — should fix, or justify skipping
3. **Suggestions** — optional improvements

Be direct and specific. Reference file paths and line numbers.
