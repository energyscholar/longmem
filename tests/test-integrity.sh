#!/bin/bash
# test-integrity.sh — Verify the longmem template is internally consistent
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO"

errors=0

pass() { echo "  PASS: $1"; }
fail() { echo "  FAIL: $1"; errors=$((errors + 1)); }

# --- Check 1: All File Map entries resolve ---
echo "Check 1: File Map entries resolve"
in_filemap=0
filemap_ok=1
while IFS= read -r line; do
    # Match lines like: - `.longmem/...` or - `.longmem/...`
    path=$(echo "$line" | grep -oP '`\K\.longmem/[^`]+')
    [ -z "$path" ] && continue
    in_filemap=1
    if [ ! -f "$path" ]; then
        fail "File Map entry not found: $path"
        filemap_ok=0
    fi
done < <(sed -n '/^## File Map/,/^---$/p' .longmem/memory/MEMORY.md)
[ "$filemap_ok" -eq 1 ] && [ "$in_filemap" -eq 1 ] && pass "All File Map entries resolve"

# --- Check 2: No orphan memory files ---
echo "Check 2: No orphan memory files"
orphan_ok=1
filemap_section=$(sed -n '/^## File Map/,/^---$/p' .longmem/memory/MEMORY.md)
for f in .longmem/memory/*.md .longmem/memory/*.yaml; do
    [ -f "$f" ] || continue
    # MEMORY.md contains the File Map itself — not an orphan
    [ "$f" = ".longmem/memory/MEMORY.md" ] && continue
    if ! echo "$filemap_section" | grep -qF "$f"; then
        fail "Orphan file not in File Map: $f"
        orphan_ok=0
    fi
done
[ "$orphan_ok" -eq 1 ] && pass "No orphan memory files"

# --- Check 3: directives.md references exist ---
echo "Check 3: directives.md references exist"
dir_ok=1
while IFS= read -r path; do
    if [ ! -f "$path" ] && [ ! -d "$path" ]; then
        fail "directives.md references missing: $path"
        dir_ok=0
    fi
done < <(grep -oP '`\K\.longmem/[^`]+' .longmem/directives.md | sort -u)
[ "$dir_ok" -eq 1 ] && pass "All directives.md references exist"

# --- Check 4: protocol.md section references valid ---
echo "Check 4: protocol.md section references valid"
sect_ok=1
# Extract all "Section N" references
referenced_sections=$(grep -oP 'Section \K[0-9]+' .longmem/memory/protocol.md | sort -n -u)
for n in $referenced_sections; do
    if ! grep -qP "^## $n\." .longmem/memory/protocol.md; then
        fail "protocol.md references Section $n but no ## $n. heading found"
        sect_ok=0
    fi
done
[ "$sect_ok" -eq 1 ] && pass "All protocol.md section references valid"

# --- Check 5: README file structure matches reality ---
echo "Check 5: README file structure matches reality"
readme_ok=1
# Extract paths from the file tree in README.md (lines with ├── or └──)
while IFS= read -r line; do
    # Extract filename/dirname after tree characters
    entry=$(echo "$line" | sed 's/.*[├└]── //' | sed 's/ *#.*//' | sed 's/[[:space:]]*$//')
    [ -z "$entry" ] && continue
    # Skip directory-only entries (end with /)
    case "$entry" in
        */) continue ;;
    esac
    # Build path from indentation context — use simple approach: search for file
    found=$(find . -name "$entry" -not -path './.git/*' 2>/dev/null | head -1)
    if [ -z "$found" ]; then
        fail "README lists '$entry' but file not found"
        readme_ok=0
    fi
done < <(sed -n '/^```$/,/^```$/p' README.md | grep -E '[├└]──')
[ "$readme_ok" -eq 1 ] && pass "README file structure matches reality"

# --- Check 6: CLAUDE.md activation block present ---
echo "Check 6: CLAUDE.md activation block"
if grep -q '<!-- LONGMEM START' CLAUDE.md && grep -q '<!-- LONGMEM END -->' CLAUDE.md; then
    pass "CLAUDE.md activation block present"
else
    fail "CLAUDE.md missing LONGMEM START/END markers"
fi

# --- Check 7: memory-sync.sh is executable ---
echo "Check 7: memory-sync.sh permissions"
if [ -x .longmem/scripts/memory-sync.sh ]; then
    pass "memory-sync.sh is executable"
else
    fail "memory-sync.sh is not executable"
fi

# --- Check 8: No broken markdown links ---
echo "Check 8: Markdown link targets"
link_ok=1
while IFS= read -r mdfile; do
    dir=$(dirname "$mdfile")
    while IFS= read -r target; do
        # Skip http(s) links, anchors, and empty
        case "$target" in
            http*|mailto*|\#*|"") continue ;;
        esac
        # Strip anchor fragment
        target_path="${target%%#*}"
        [ -z "$target_path" ] && continue
        # Resolve relative to the markdown file's directory
        if [ ! -f "$dir/$target_path" ] && [ ! -d "$dir/$target_path" ]; then
            fail "Broken link in $mdfile: $target_path"
            link_ok=0
        fi
    done < <(grep -oP '\[^]]*\]\(\K[^)]+' "$mdfile" 2>/dev/null)
done < <(find . -name '*.md' -not -path './.git/*' -not -path './tests/*')
[ "$link_ok" -eq 1 ] && pass "No broken markdown links"

echo ""
echo "$errors error(s)"
exit "$errors"
