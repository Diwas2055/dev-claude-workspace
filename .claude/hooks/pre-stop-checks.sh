#!/usr/bin/env bash
# Runs before Claude stops — verifies code quality gates pass.

set -euo pipefail

echo "[hook] Running pre-stop checks..."

FAILED=0

# 1. Ruff lint check
if command -v ruff &>/dev/null; then
  echo "[check] Ruff lint..."
  if ! ruff check . --quiet 2>/dev/null; then
    echo "[WARN] Ruff lint issues found. Run: ruff check . --fix"
    FAILED=1
  else
    echo "[ok] Ruff lint passed"
  fi
fi

# 2. Check for debug artifacts
if grep -rn "print(" app/ --include="*.py" --exclude-dir=__pycache__ 2>/dev/null | grep -v "# noqa"; then
  echo "[WARN] Debug print() statements found in app/ — remove before committing"
  FAILED=1
fi

# 3. Check for unresolved merge conflict markers
if grep -rn "<<<<<<\|>>>>>>\|=======" app/ --include="*.py" 2>/dev/null; then
  echo "[WARN] Merge conflict markers found — resolve before continuing"
  FAILED=1
fi

# 4. Remind about tests if Python files were changed
CHANGED_PY=$(git diff --name-only 2>/dev/null | grep "^app/.*\.py$" || true)
if [[ -n "$CHANGED_PY" ]]; then
  echo "[remind] Python files changed — run: pytest -x -v"
fi

if [[ $FAILED -eq 1 ]]; then
  echo "[hook] Pre-stop checks found issues. Address them before finalizing."
  exit 1
fi

echo "[hook] All pre-stop checks passed."
exit 0
