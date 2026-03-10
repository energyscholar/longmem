# Longmem Install Prompt

Paste this into Claude Code in your project directory:

---

Set up longmem persistent memory in this project. Steps:

1. Check installation state:
   - If `.longmem/` exists AND `.longmem/memory/MEMORY.md` exists: this is already installed. Ask user: "Longmem is already installed. Reinstall (overwrites memory), update (keeps memory), or cancel?"
   - If `.longmem/` exists but is incomplete (missing MEMORY.md): partial install detected. Remove `.longmem/` and proceed to Step 2.
   - If `.longmem/` does not exist: proceed to Step 2.
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
7. If .gitignore exists and contains a `.*` pattern but does NOT already contain `!.longmem/`, add `!.longmem/` on the line after the `.*` pattern
8. Open `.longmem/memory/MEMORY.md` and ask me to fill in: project name, start date, goal, and key people.
9. Delete /tmp/longmem-install

---
