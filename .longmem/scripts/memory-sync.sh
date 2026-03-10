#!/bin/bash
# memory-sync.sh — Commit memory files to git for L3 recovery
set -e
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO"

if [ ! -d .git ]; then
    echo "Error: $REPO is not a git repository. Run 'git init' first."
    exit 1
fi

git add .longmem/

# Generate file checksums for lazy change detection
md5sum .longmem/memory/*.md .longmem/memory/*.yaml > .longmem/.file-hashes 2>/dev/null || true
git add .longmem/.file-hashes

if git diff --cached --quiet; then
    echo "Memory sync: no changes to commit."
else
    git commit -m "Memory sync: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "Memory synced: $(git log --oneline -1)"
fi
