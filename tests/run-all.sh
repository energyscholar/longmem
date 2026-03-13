#!/bin/bash
# run-all.sh — Run all longmem tests
# Usage: bash tests/run-all.sh [from repo root]
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Color output if terminal supports it
if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
    GREEN=$(tput setaf 2)
    RED=$(tput setaf 1)
    BOLD=$(tput bold)
    RESET=$(tput sgr0)
else
    GREEN=""
    RED=""
    BOLD=""
    RESET=""
fi

passed=0
failed=0
total=0

for test_file in "$SCRIPT_DIR"/test-*.sh; do
    [ -f "$test_file" ] || continue
    name=$(basename "$test_file" .sh)
    total=$((total + 1))

    if bash "$test_file" >/dev/null 2>&1; then
        echo "${GREEN}PASS${RESET}  $name"
        passed=$((passed + 1))
    else
        echo "${RED}FAIL${RESET}  $name"
        failed=$((failed + 1))
    fi
done

echo ""
echo "${BOLD}$passed passed, $failed failed${RESET} (of $total)"

[ "$failed" -eq 0 ]
