#!/bin/bash
# test-smoke.sh — Verify longmem activates in a fresh environment
# Creates a temp clone, tests file structure and script execution
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/.." && pwd)"

errors=0
TMPDIR=""

pass() { echo "  PASS: $1"; }
fail() { echo "  FAIL: $1"; errors=$((errors + 1)); }

cleanup() {
    [ -n "$TMPDIR" ] && [ -d "$TMPDIR" ] && rm -rf "$TMPDIR"
}
trap cleanup EXIT

# --- Setup: create temp clone ---
TMPDIR=$(mktemp -d)
cp -r "$REPO/.longmem" "$TMPDIR/"
cp "$REPO/CLAUDE.md" "$TMPDIR/"
cd "$TMPDIR"
git init -q
git add -A
git commit -q -m "Initial commit"

# --- Check 1: CLAUDE.md loads with activation block ---
echo "Check 1: CLAUDE.md activation block"
if grep -q '<!-- LONGMEM START' CLAUDE.md && grep -q '<!-- LONGMEM END -->' CLAUDE.md; then
    pass "CLAUDE.md contains activation block"
else
    fail "CLAUDE.md missing activation block"
fi

# --- Check 2: directives.md is readable ---
echo "Check 2: directives.md readable"
if [ -f .longmem/directives.md ] && [ -s .longmem/directives.md ]; then
    pass "directives.md exists and non-empty"
else
    fail "directives.md missing or empty"
fi

# --- Check 3: MEMORY.md readable with expected sections ---
echo "Check 3: MEMORY.md sections"
mem_ok=1
for section in "## Identity" "## Current State" "## L1 Corrections" "## Active Sessions" "## File Map" "## Health Metrics"; do
    if ! grep -qF "$section" .longmem/memory/MEMORY.md; then
        fail "MEMORY.md missing section: $section"
        mem_ok=0
    fi
done
[ "$mem_ok" -eq 1 ] && pass "MEMORY.md has all expected sections"

# --- Check 4: memory-sync.sh creates a commit ---
echo "Check 4: memory-sync.sh creates commit"
# Make a change so sync has something to commit
echo "<!-- test -->" >> .longmem/memory/MEMORY.md
output=$(bash .longmem/scripts/memory-sync.sh 2>&1)
last_commit=$(git log --oneline -1)
if echo "$last_commit" | grep -q "Memory sync"; then
    pass "memory-sync.sh created Memory sync commit"
else
    fail "memory-sync.sh did not create expected commit: $last_commit"
fi

# --- Check 5: memory-sync.sh idempotency ---
echo "Check 5: memory-sync.sh idempotency"
output=$(bash .longmem/scripts/memory-sync.sh 2>&1)
if echo "$output" | grep -q "no changes to commit"; then
    pass "Idempotent: no duplicate commit"
else
    fail "Idempotency failed: $output"
fi

# --- Check 6: MEMORY.md growth warning ---
echo "Check 6: MEMORY.md growth warning"
# Append lines to exceed 180 threshold
for i in $(seq 1 190); do
    echo "<!-- padding line $i -->" >> .longmem/memory/MEMORY.md
done
output=$(bash .longmem/scripts/memory-sync.sh 2>&1)
if echo "$output" | grep -q "WARNING"; then
    pass "Growth warning triggered"
else
    fail "No WARNING for oversized MEMORY.md: $output"
fi

echo ""
echo "$errors error(s)"
exit "$errors"
