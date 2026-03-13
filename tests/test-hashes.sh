#!/bin/bash
# test-hashes.sh — CRC/hash verification of template files
# Detects accidental template drift. Baseline is local (gitignored).
# Usage: bash tests/test-hashes.sh [--reset]
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO"

BASELINE="$SCRIPT_DIR/.test-baseline"

# Compute hashes of all files in .longmem/ (excluding .file-hashes)
compute_hashes() {
    find .longmem/ -type f -not -name '.file-hashes' -not -path '*/.git/*' | sort | while read -r f; do
        sha256sum "$f"
    done
}

# Reset baseline
if [ "${1:-}" = "--reset" ]; then
    compute_hashes > "$BASELINE"
    echo "Baseline reset: $(wc -l < "$BASELINE") files"
    exit 0
fi

# First run: create baseline
if [ ! -f "$BASELINE" ]; then
    compute_hashes > "$BASELINE"
    echo "Baseline created: $(wc -l < "$BASELINE") files"
    exit 0
fi

# Compare against baseline
errors=0
current=$(compute_hashes)
diff_output=$(diff <(echo "$current") "$BASELINE" 2>&1) || true

if [ -n "$diff_output" ]; then
    echo "Template drift detected:"
    # Show changed files
    echo "$diff_output" | grep '^[<>]' | while IFS= read -r line; do
        file=$(echo "$line" | awk '{print $3}')
        case "$line" in
            \<*) echo "  CHANGED or ADDED: $file" ;;
            \>*) echo "  REMOVED: $file" ;;
        esac
    done
    errors=1
else
    echo "PASS: All template files match baseline"
fi

exit "$errors"
