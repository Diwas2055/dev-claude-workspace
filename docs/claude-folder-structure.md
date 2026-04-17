# How to Structure .claude/ Folder for Maximum Efficiency

A practical developer guide to organizing your Claude Code workspace so
every file has a purpose, every folder solves a specific problem, and the
whole setup scales without becoming clutter.

---

## Why Structure Matters

Most teams discover the `.claude/` folder by accident. They add a few
instructions to `CLAUDE.md`, maybe tweak `settings.json`, and leave
everything else wherever it landed. That works early on.

It stops working once the project grows.

A disorganized `.claude/` folder creates the same friction as a messy
codebase: rules become hard to find, automation scripts pile up with
cryptic names, and teammates don't know where to put new things.

A well-structured `.claude/` folder does the opposite:
- Instructions are easy to find and update
- Automation lives in predictable locations
- Reusable workflows are separated from one-off notes
- Team standards are cleanly separated from personal preferences

**Maximum efficiency = clarity. Every file earns its place.**

---

## The Target Layout

```
your-project/
├── CLAUDE.md                   # Global project instructions
├── CLAUDE.local.md             # Personal overrides (never committed)
└── .claude/
    ├── settings.json           # Permissions + hook wiring
    ├── settings.local.json     # Local permission overrides (never committed)
    ├── rules/                  # Modular, scoped instructions
    ├── hooks/                  # Auto-running scripts
    ├── commands/               # Reusable prompt workflows
    ├── skills/                 # Packaged multi-step workflows
    └── agents/                 # Specialized role-based personas
```

---

## Layer 1 — The Top Level

### `CLAUDE.md`
The entry point. Claude reads this in every session.

**Keep it focused on:**
- What the project is (2–3 sentences)
- Stack and architecture overview
- The most important dev commands
- Project-wide conventions that apply everywhere
- Hard constraints Claude must never violate

**Do not put here:**
- Area-specific rules (move to `rules/`)
- Reusable prompts (move to `commands/`)
- Process details (move to `skills/`)

### `settings.json`
The control layer. Defines what Claude is allowed to do.

**Configure here:**
- `permissions.allow` — commands Claude can run without asking
- `permissions.deny` — commands that are always blocked
- `hooks` — which scripts fire at which lifecycle events

### Personal Overrides
| File | Committed | Purpose |
|---|---|---|
| `CLAUDE.local.md` | No | Local preferences, machine-specific notes |
| `.claude/settings.local.json` | No | Local permission overrides |

Always add both to `.gitignore`.

---

## Layer 2 — `rules/`

Split instructions by concern. Each file owns one engineering area.

### When to create a new rule file
- `CLAUDE.md` is getting crowded
- Different parts of the repo need different guidance
- A specific concern (security, testing) is updated frequently

### Good rule file structure
```
.claude/rules/
├── api.md          → route design, schemas, error handling
├── database.md     → ORM, repositories, migrations, indexes
├── testing.md      → test structure, fixtures, what NOT to mock
├── security.md     → auth, secrets, input validation, logging
├── code-style.md   → naming, async, imports, comment policy
└── git-workflow.md → branching, commits, PR rules
```

### Rule file anatomy
```markdown
# <Concern> Rules

## <Category>
- Specific, actionable rule
- Another specific rule

## <Another Category>
- Rule
```

Rules should be **prescriptive, not descriptive.** Say what to do,
not what the codebase currently does.

---

## Layer 3 — `hooks/`

Scripts that fire automatically at Claude lifecycle events.

### Lifecycle events
| Event | When it fires |
|---|---|
| `PreToolUse` | Before Claude runs a tool (Bash, Edit, Write, etc.) |
| `PostToolUse` | After Claude runs a tool |
| `Stop` | When Claude finishes a session |

### Hook wiring in `settings.json`
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{ "type": "command", "command": "bash .claude/hooks/format-on-edit.sh" }]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{ "type": "command", "command": "bash .claude/hooks/block-dangerous-commands.sh" }]
      }
    ],
    "Stop": [
      {
        "hooks": [{ "type": "command", "command": "bash .claude/hooks/pre-stop-checks.sh" }]
      }
    ]
  }
}
```

### Common hook patterns

**Auto-format on edit**
```bash
#!/usr/bin/env bash
FILE=$(echo "$CLAUDE_TOOL_INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('file_path',''))")
[[ "$FILE" == *.py ]] && ruff format "$FILE" --quiet && ruff check "$FILE" --fix --quiet
```

**Block dangerous commands**
```bash
#!/usr/bin/env bash
CMD=$(echo "$CLAUDE_TOOL_INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('command',''))")
echo "$CMD" | grep -qiE "git push --force|rm -rf|DROP TABLE" && { echo "[BLOCKED]"; exit 2; }
```

**Pre-stop quality check**
```bash
#!/usr/bin/env bash
ruff check . --quiet || echo "[WARN] Lint issues found"
grep -rn "print(" app/ --include="*.py" && echo "[WARN] Debug prints found"
```

### Naming convention
```
format-on-edit.sh          ✓  clear
block-dangerous-commands.sh ✓  clear
pre-stop-checks.sh         ✓  clear
script1.sh                 ✗  meaningless
helper.sh                  ✗  vague
```

---

## Layer 4 — `commands/`

Reusable prompt workflows for tasks you repeat often.

### When to create a command
- You retype the same prompt more than twice
- A task has a consistent structure (review, summarize, scaffold)
- You want teammates to use the same workflow

### Invoke a command
```
/review-pr
/write-tests
/add-endpoint
```

### Good command structure
```markdown
# command-name

One sentence on what this does.

## Instructions / Steps
Numbered or bulleted workflow Claude follows.

## Output Format
What the response should look like.
```

### Commands vs Skills
| Use a command when | Use a skill when |
|---|---|
| Task fits in one file | Task has multiple steps |
| Mostly prompt-driven | Needs companion documents |
| Simple and direct | Important enough to standardize deeply |
| Quick, single-purpose | Reused by the whole team repeatedly |

---

## Layer 5 — `skills/`

Packaged multi-step workflows. Each skill is a self-contained directory.

### Structure
```
.claude/skills/
└── release-prep/
    ├── SKILL.md           # Entry point: purpose, steps, output
    └── release-template.md # Supporting file referenced in SKILL.md
```

### `SKILL.md` anatomy
```markdown
# Skill: <name>

## When to Use
One paragraph on the trigger conditions.

## Steps
1. Step one
2. Step two
3. ...

## Output
What the skill produces.
```

### Good candidates for skills
- Release preparation (changelog + migration checklist + deployment steps)
- API surface audit (multi-file checklist)
- Database migration workflow (generate + review + test)
- Onboarding documentation generation

### Anti-patterns
- Creating a skill for something a one-file command handles fine
- Skills with no `SKILL.md` entry point
- Overlapping skills that do the same thing with different names

---

## Layer 6 — `agents/`

Specialized role-based personas with narrow, focused expertise.

### When to create an agent
- A workflow benefits from a specific professional lens
- You want consistent behavior across all instances of a task type
- The role has its own set of priorities and blind spots

### Good agent roster for a backend team
```
.claude/agents/
├── code-reviewer.md       → correctness, edge cases, test coverage
├── security-auditor.md    → auth, injection, data exposure, secrets
├── test-writer.md         → pytest + httpx integration test expert
├── db-expert.md           → schema, N+1, indexes, migration strategy
└── documentation-editor.md → API docs, ADRs, module guides
```

### Agent file anatomy
```markdown
---
name: agent-name
description: One sentence — when Claude Code picks this agent automatically.
---

You are a <role> specializing in <domain>.

## Your Focus
- What this agent prioritizes

## Your Style
- How it communicates

## What You Ignore
- Things outside its lane (prevents scope creep)

## Output Format
How it structures its response.
```

### Agent discipline
- Each agent owns **one role** — no overlapping responsibilities
- Define what the agent **ignores** — this is as important as what it focuses on
- If two agents overlap heavily, merge them

---

## Team vs Personal Configuration

```
Shared (committed)               Personal (never committed)
─────────────────────────────    ──────────────────────────────
CLAUDE.md                        CLAUDE.local.md
.claude/settings.json            .claude/settings.local.json
.claude/rules/*                  ~/.claude/CLAUDE.md
.claude/hooks/*                  ~/.claude/settings.json
.claude/commands/*               ~/.claude/skills/
.claude/skills/*                 ~/.claude/agents/
.claude/agents/*
```

**Rule:** If a file helps the whole team work consistently → commit it.
If it reflects one person's preferences → keep it personal.

---

## Growth Progression

Add structure only when the workflow demands it.

```
Start here
    │
    ▼
CLAUDE.md + settings.json
    │
    ├─ Rules get crowded?
    │   └─▶ Add rules/
    │
    ├─ Same commands repeated?
    │   └─▶ Add commands/
    │
    ├─ Need automation?
    │   └─▶ Add hooks/
    │
    ├─ Workflows getting complex?
    │   └─▶ Add skills/
    │
    └─ Need specialized personas?
        └─▶ Add agents/
```

A small, intentional `.claude/` folder outperforms a large, cluttered one.

---

## Common Mistakes

| Mistake | Fix |
|---|---|
| Overloaded `CLAUDE.md` | Move specifics to `rules/` |
| Folders added before they're needed | Earn each folder with real demand |
| Personal prefs in shared files | Use `CLAUDE.local.md` + `~/.claude/` |
| Vague filenames (`helper.sh`, `misc.md`) | Name for purpose: `format-on-edit.sh` |
| Stale files left in place | Treat `.claude/` like code — delete dead weight |
| Same instruction in tool config AND `.claude/` | Let the tool own it; don't duplicate |

---

## Quick Reference

| File/Folder | Type | Committed | Purpose |
|---|---|---|---|
| `CLAUDE.md` | Instructions | Yes | Global project context |
| `CLAUDE.local.md` | Instructions | No | Personal overrides |
| `.claude/settings.json` | Config | Yes | Permissions + hooks |
| `.claude/settings.local.json` | Config | No | Local permission overrides |
| `.claude/rules/*.md` | Instructions | Yes | Scoped modular rules |
| `.claude/hooks/*.sh` | Automation | Yes | Auto-running scripts |
| `.claude/commands/*.md` | Workflows | Yes | Reusable prompt tasks |
| `.claude/skills/*/SKILL.md` | Workflows | Yes | Packaged multi-step processes |
| `.claude/agents/*.md` | Personas | Yes | Specialized AI roles |
