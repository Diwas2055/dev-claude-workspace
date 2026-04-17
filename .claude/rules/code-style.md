# Code Style Rules

## Python General
- Python 3.12+ — use modern syntax: `match`, `|` union types, `Self`
- Type-annotate all function signatures: parameters and return types
- Use `from __future__ import annotations` only when needed for forward refs
- Max line length: 88 (Ruff default)
- No unused imports — Ruff enforces this; fix don't suppress

## Naming
- `snake_case` for variables, functions, modules
- `PascalCase` for classes and Pydantic models
- `SCREAMING_SNAKE_CASE` for module-level constants
- Prefix private methods/attrs with `_` — never `__` (name mangling)
- Boolean variables/functions: `is_`, `has_`, `can_` prefix

## Functions & Classes
- Functions do one thing — if the name needs "and", split it
- Max function length: ~30 lines before considering a split
- Avoid deeply nested logic — early return / guard clauses preferred
- Dataclasses or Pydantic for data containers — never plain dicts as return types

## Imports
- Order: stdlib → third-party → local (Ruff `isort` handles this)
- Always use absolute imports — no relative `..` chains beyond one level
- Never use `import *`

## Comments
- Write no comments by default
- Only comment when the WHY is non-obvious: hidden constraints, workarounds, invariants
- Never describe WHAT the code does — names do that
- TODO comments must include ticket reference: `# TODO(TICKET-123): ...`

## Async
- All I/O-bound operations must be async
- Never call blocking functions inside async context — use `run_in_executor` if needed
- Use `asyncio.gather()` for concurrent independent async calls
