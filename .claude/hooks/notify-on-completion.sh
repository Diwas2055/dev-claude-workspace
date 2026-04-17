#!/usr/bin/env bash
# Prints a summary notification when Claude completes a task session.

set -euo pipefail

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
CHANGED=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Claude session complete"
echo "  Time    : $TIMESTAMP"
echo "  Branch  : $BRANCH"
echo "  Changed : $CHANGED file(s)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit 0
