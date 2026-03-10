# Longmem Install Prompt

Paste this into Claude Code in your project directory:

---

Set up longmem persistent memory in this project. Steps:

1. If `.longmem/` already exists, stop and ask me what to do (might be an existing install)
2. Clone https://github.com/energyscholar/longmem.git to /tmp/longmem-install
3. Copy the `.longmem/` directory from the clone into this project root
4. If this project has no CLAUDE.md, create one. Append this block to CLAUDE.md:

<!-- LONGMEM START — do not edit this block manually -->
## Longmem Persistent Memory

Full directives: `.longmem/directives.md` — read at session start for complete protocol.

**Minimum session loop:**
- **Start:** Read `.longmem/memory/MEMORY.md`, then `.longmem/memory/corrections.md`
- **End:** Update `.longmem/memory/MEMORY.md`, run `.longmem/scripts/memory-sync.sh`
<!-- LONGMEM END -->

5. Run: chmod +x .longmem/scripts/memory-sync.sh
6. Run: git init (if not already a git repo)
7. If .gitignore has a `.*` pattern, add `!.longmem/` to prevent exclusion
8. Open `.longmem/memory/MEMORY.md` and ask me to fill in: project name, start date, goal, and key people.
9. Delete /tmp/longmem-install

---
