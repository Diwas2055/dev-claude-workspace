#!/usr/bin/env bash
# Blocks destructive shell commands before Claude runs them.

set -euo pipefail

COMMAND=$(echo "$CLAUDE_TOOL_INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('command',''))" 2>/dev/null || echo "")

BLOCKED_PATTERNS=(
  "git push --force"
  "git push -f"
  "git reset --hard"
  "git clean -f"
  "rm -rf /"
  "rm -rf ~"
  "DROP TABLE"
  "TRUNCATE TABLE"
  "DROP DATABASE"
  "DELETE FROM.*WHERE.*1=1"
  "chmod -R 777"
  "> /dev/sda"
  "mkfs"
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qiE "$pattern"; then
    echo "[BLOCKED] Dangerous command detected: $pattern"
    echo "Command: $COMMAND"
    echo "Aborting. Review and run manually if intentional."
    exit 2
  fi
done

# Warn on .env access
if echo "$COMMAND" | grep -qE "(cat|less|more|head|tail|nano|vim)\s+\.env"; then
  echo "[BLOCKED] Direct .env file access is not permitted."
  exit 2
fi

exit 0
