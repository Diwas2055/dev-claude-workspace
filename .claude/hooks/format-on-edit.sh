#!/usr/bin/env bash
# Runs ruff format + ruff check --fix on any Python file Claude edits.

set -euo pipefail

FILE_PATH=$(echo "$CLAUDE_TOOL_INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('file_path',''))" 2>/dev/null || echo "")

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

if [[ "$FILE_PATH" != *.py ]]; then
  exit 0
fi

if [[ ! -f "$FILE_PATH" ]]; then
  exit 0
fi

echo "[hook] Formatting: $FILE_PATH"
ruff format "$FILE_PATH" --quiet
ruff check "$FILE_PATH" --fix --quiet

exit 0
