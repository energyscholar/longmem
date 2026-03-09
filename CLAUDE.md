# Claude Code Directives — Longmem Template

## Memory System

You have a persistent memory directory at `memory/`. Its contents persist across conversations.

### File Structure

- `memory/MEMORY.md` — Always in context. Identity, current state, hot corrections (top 5), active work, file map, health metrics. **Hard cap: 200 lines.**
- `memory/corrections.md` — Things you consistently get wrong. Short imperatives. The top 5 rotate into MEMORY.md.
- `memory/protocol.md` — Session lifecycle: start checklist, end checklist, compression rules, integrity checks, decay timers. Read when triggers fire.
- `memory/ptl.yaml` — Prioritized Task List. YAML format. Stable IDs (PTL-NNN), 5 tiers, statuses.
- `memory/decisions.md` — Structural decisions with rationale. Prevents re-litigating settled questions.
- `memory/session-details.md` — Full session history. Compression target for old routine sessions.
- `memory/people.md` — Key people: collaborators, family, colleagues, mentors, friends. Tiered by interaction frequency. Prevents "who's that?" every session.

### Session Start Protocol

1. Read `memory/MEMORY.md` (auto-loaded by Claude Code)
2. Check health metrics dashboard in MEMORY.md
3. If any health metric is out of bounds, read `memory/protocol.md` for maintenance rules
4. Read `memory/corrections.md` to load all corrections (not just the hot five)
5. If working on tasks, check `memory/ptl.yaml` for current priorities

### Session End Protocol

1. Update current state in `memory/MEMORY.md`
2. Write session summary to `memory/session-details.md`
   - Classify session as PARADIGM (major breakthrough, new direction) or ROUTINE
   - Include date, session number, summary
3. If `MEMORY.md` exceeds 180 lines:
   - Read `memory/protocol.md` Section 3 (compression rules)
   - Archive oldest ROUTINE session from MEMORY.md to session-details.md
4. Run integrity checks:
   - Verify all file paths in MEMORY.md resolve
   - Verify corrections.md has expected count
   - Check for orphan files
5. Update health metrics dashboard
6. Run `scripts/memory-sync.sh` to commit memory files to git

### PTL Commands

When the user says:
- **"PTL"** — Show current prioritized task list from `memory/ptl.yaml`
- **"PTL full"** — Show all tiers including DONE/DROPPED
- **"PTL add: [description]"** — Add new item, ask for tier and status
- **"PTL update PTL-NNN: [changes]"** — Update existing item
- **"PTL close PTL-NNN"** — Mark item as DONE

### Three-Tier Cache Model

**L1** (Always in context): `MEMORY.md` — 200-line cap enforced
**L2** (Loaded on demand): corrections, protocol, ptl, decisions, session-details, people
**L3** (Git recovery): Session-end sync script commits everything to git for versioned snapshots

### Corrections System

Each correction prevents a specific recurring error. Format:
```
## Correction #N: [Short name]
[What you get wrong] → [What to write instead]
Established: [date]. Last violated: [date or "never"].
```

The five most-violated corrections appear in MEMORY.md for visibility. All corrections are read at session start. When you violate a correction, update its "Last violated" date.

### Self-Maintenance

You maintain your own memory. Triggers:
- MEMORY.md >180 lines → compress (archive oldest ROUTINE session)
- Pending items >3 weeks → STALE
- Pending items >6 weeks → archive to session-details.md
- Pending items >8 weeks with no plan → STALLED
- Broken file references → fix immediately
- Health metrics out of bounds → read protocol.md

### Health Metrics Dashboard

Track in MEMORY.md:
- MEMORY.md line count (target: <180)
- PTL item count (target: <60)
- Pending items count
- Oldest unarchived ROUTINE session (target: <3 weeks)
- Broken file references (target: 0)
- Sessions since last system review (every 10 sessions, ask user "anything missing from my context?")

## Response Style

- **Concise.** No preambles ("I'll help you...", "Let me..."). Lead with answer or action.
- **Direct.** Don't restate what the user said — just do it.
- If you need clarification, ask — but prefer to infer from context when reasonable.

## Tool Patterns

- For large files: Grep before Read
- Don't re-read unchanged files
- Use parallel tool calls when operations are independent

## User Escape Hatches

Commands that override defaults:
- **"read full"** — Read entire file regardless of size
- **"more"** / **"verbose"** — Longer, more detailed response

---

**This is a template.** Customize MEMORY.md, corrections.md, and ptl.yaml for your project. The memory system will adapt to your workflow over 2-3 sessions.
