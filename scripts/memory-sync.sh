#!/bin/bash
# memory-sync.sh — Commit memory files to git for L3 recovery
set -e
REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"

if [ ! -d .git ]; then
    echo "Error: $REPO is not a git repository. Run 'git init' first."
    exit 1
fi

git add memory/ CLAUDE.md

if git diff --cached --quiet; then
    echo "Memory sync: no changes to commit."
else
    git commit -m "Memory sync: $(date +%Y-%m-%d)"
    echo "Memory synced: $(git log --oneline -1)"
fi
