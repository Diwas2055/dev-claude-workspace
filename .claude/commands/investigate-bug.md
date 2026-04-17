# investigate-bug

Systematically investigate a reported bug.

## Process

**Step 1 — Understand the report**
- What is the expected behavior?
- What is the actual behavior?
- What endpoint, service, or function is involved?
- Is there a stack trace or error log?

**Step 2 — Locate the source**
- Trace from the route handler → service → repository → DB
- Identify where the behavior diverges from the expectation
- Check recent git changes to the relevant files (`git log -p -- path/to/file`)

**Step 3 — Reproduce locally**
- Write a failing test that demonstrates the bug before fixing it
- Confirm the test fails on current code

**Step 4 — Fix**
- Make the minimal change that fixes the bug
- Do not refactor surrounding code in the same commit
- Confirm the failing test now passes
- Confirm no other tests regressed (`pytest -x -v`)

**Step 5 — Report**
Summarize:
- Root cause (one sentence)
- Files changed
- Test added
- Any follow-up risks or related areas to watch
