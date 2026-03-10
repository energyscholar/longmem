#!/bin/bash
# memory-sync.sh — Commit memory files to git for L3 recovery
set -e
REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"

# Verify git repository exists
if [ ! -d .git ]; then
    echo "Error: $REPO is not a git repository. Run 'git init' first."
    exit 1
fi

git add memory/ CLAUDE.md
git commit -m "Memory sync: $(date +%Y-%m-%d)" 2>/dev/null || true
echo "Memory synced to $REPO"
