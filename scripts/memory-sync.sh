#!/bin/bash
# memory-sync.sh — Commit memory files to git for L3 recovery
set -e
REPO="$(dirname "$(dirname "$(realpath "$0")")")"
cd "$REPO"
git add memory/ CLAUDE.md
git commit -m "Memory sync: $(date +%Y-%m-%d)" 2>/dev/null || true
echo "Memory synced."
