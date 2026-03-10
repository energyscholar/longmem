# Longmem Uninstall Prompt

Paste this into Claude Code in your project directory:

---

Remove longmem from this project. Steps:

1. Run `.longmem/scripts/memory-sync.sh` to create a final git snapshot
2. Show me what will be deleted (list files in .longmem/)
3. Ask for confirmation
4. After confirmation: rm -rf .longmem/
5. Remove the block between <!-- LONGMEM START --> and <!-- LONGMEM END --> from CLAUDE.md
6. If CLAUDE.md is now empty, delete it
7. Confirm removal is complete. Note: memory history is preserved in git — recoverable via `git log --all -- .longmem/`

---
