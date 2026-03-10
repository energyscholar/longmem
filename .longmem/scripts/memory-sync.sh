#!/bin/bash
# memory-sync.sh — Commit memory files to git for L3 recovery
set -e
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO"

if [ ! -d .git ]; then
    echo "Error: $REPO is not a git repository. Run 'git init' first."
    exit 1
fi

# Health warnings (inform, don't block)
MEM=".longmem/memory/MEMORY.md"
SD=".longmem/memory/session-details.md"
if [ -f "$MEM" ]; then
    LINES=$(wc -l < "$MEM")
    [ "$LINES" -ge 180 ] && echo "WARNING: MEMORY.md is $LINES lines (cap: 200, compress at 180)"
fi
if [ -f "$SD" ]; then
    SD_LINES=$(wc -l < "$SD")
    [ "$SD_LINES" -ge 200 ] && echo "WARNING: session-details.md is $SD_LINES lines (compress oldest ROUTINE)"
fi

git add .longmem/

# Generate file checksums for lazy change detection
md5sum .longmem/memory/*.md .longmem/memory/*.yaml > .longmem/.file-hashes 2>/dev/null || true
git add .longmem/.file-hashes

if git diff --cached --quiet; then
    echo "Memory sync: no changes to commit."
else
    git commit .longmem/ -m "Memory sync: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "Memory synced: $(git log --oneline -1)"
fi
