# Self-Maintenance Protocol

*Lazy-loaded: read when triggers fire, not at boot.*

---

## 1. Session Start Checklist

1. Read `MEMORY.md` (auto-loaded by Claude Code)
2. Check Health Metrics dashboard
3. If MEMORY.md >180 lines: read Section 3 (compression), execute before proceeding
4. Read `corrections.md` to load all corrections (not just hot five)
5. If working on tasks: read `ptl.yaml` for current priorities
6. If Health Metrics show anomalies: investigate and fix

**Triggers for reading this file:**
- Health metric out of bounds
- MEMORY.md >180 lines
- Integrity check fails
- User asks about protocol
- Session end (always)

---

## 2. State Update Triggers

Update `## Current State` in MEMORY.md when ANY of these changed:
- Key project metrics (test coverage, page count, version, milestone progress)
- Major decisions made
- Blockers resolved or created
- Dependencies added or removed
- Architecture changes

If nothing substantive changed, don't touch it. Avoid churn.

---

## 3. Compression Rules

**MEMORY.md line cap: 200 lines. Enforcement threshold: 180 lines.**

When MEMORY.md >180 lines:

1. **BEFORE doing anything else in the session**, read this section
2. Identify oldest ROUTINE session in `## Active Sessions`
3. Move full summary to `session-details.md`
4. Replace with 1-line pointer: `Session NN (ROUTINE, YYYY-MM-DD) — [topic]. Details in session-details.md.`
5. If no ROUTINE sessions remain, compress oldest PARADIGM to 3-5 lines (never less)
6. Update Health Metrics line count
7. Verify MEMORY.md is now <180 lines before proceeding

**session-details.md compression:**
- If session-details.md >200 lines: compress oldest ROUTINE blocks to 2-line entries
- PARADIGM sessions: keep full detail indefinitely
- Archive sessions >6 months old to separate file if needed

**Never compress:**
- Identity section
- Current State
- L1 Corrections
- Health Metrics
- File Map

---

## 4. Session End Protocol (MANDATORY)

**Run these steps at the end of EVERY session:**

1. **Update Current State** (Section 2 triggers)
2. **Update PTL statuses** for any items discussed
3. **Write session summary** in MEMORY.md `## Active Sessions`:
   - Session number and date
   - Significance flag: PARADIGM or ROUTINE
   - 3-5 line summary
4. **Classify significance:**
   - **PARADIGM:** Changed approach, new insight, corrected assumption, major milestone, or user flags it
   - **ROUTINE:** Incremental progress, expected execution, no significant decisions
   - **If unsure, default PARADIGM** — cost of keeping a 5-line block is negligible
5. **Update Health Metrics:**
   - Line count (use `wc -l memory/MEMORY.md`)
   - PTL item count
   - Corrections count
   - Broken file refs (should be 0)
   - Oldest unarchived ROUTINE session
6. **Run integrity checks** (Section 7)
7. **Commit memory files:** run `scripts/memory-sync.sh`

**Do not skip session end protocol.** This is the L3 recovery mechanism.

---

## 5. Corrections Management

**When user corrects you:**
1. Acknowledge immediately
2. Add to `corrections.md` with format:
   ```
   ## Correction #N: [Short name]
   [What you get wrong] → [What to write instead]
   Established: [date]. Last violated: [date or "never"].
   ```
3. If this is a repeat violation (2+ times), promote to L1 (hot corrections in MEMORY.md)
4. Never make the same mistake twice — that's the entire point

**L1 Corrections (Hot Five):**
- MEMORY.md displays max 5 corrections
- Swap based on violation frequency
- When rotating: log rotation with date and reason in corrections.md
- L1 corrections are pointers — full text lives in corrections.md

**When you violate a correction:**
1. Update "Last violated" date in corrections.md
2. If violation count increases, consider promoting to L1
3. If already in L1, no action needed beyond date update

---

## 6. PTL (Prioritized Task List) Maintenance

**Canonical file:** `ptl.yaml`
**Display:** Rendered on demand

**Commands:**
- `PTL` — Show active items (tiers 1-3, statuses READY/ACTIVE/BLOCKED/REVIEW/TODO)
- `PTL full` — Show all tiers including DONE/DROPPED
- `PTL add: [description]` — Add new item (ask for tier and status)
- `PTL update PTL-NNN: [changes]` — Update existing item
- `PTL close PTL-NNN` — Mark as DONE

**Items addressed by stable ID (PTL-NNN), not display position.**

**Tier definitions:**
1. Urgent / Close Now
2. Active Projects
3. Queued
4. Infrastructure
5. Someday

**Statuses:** READY, ACTIVE, BLOCKED, REVIEW, NEEDS_PLAN, TODO, DONE, DROPPED

**Decay rules:**
- Tier 1: No auto-decay. Untouched >1 week → flag to user, consider demotion to Tier 2
- Tier 2: Untouched >3 weeks → STALE, >6 weeks → archive to DONE or DROPPED
- Tier 3+: Untouched >4 weeks → STALE, >8 weeks → archive
- Items with NEEDS_PLAN status >8 weeks → STALLED (flag to user)

**Bandwidth cap:** PTL item count target <60. If exceeded, review and archive.

---

## 7. Integrity Checks

Run at session end. **Do not silently fix — flag anomalies to user.**

1. **File references:** All paths in MEMORY.md file map must resolve
2. **Corrections count:** Health Metrics corrections count must match `wc -l corrections.md`
3. **L1-L2 sync:** L1 corrections in MEMORY.md must match their counterparts in corrections.md (text can differ for brevity, but core meaning must align)
4. **Orphan files:** Files in memory/ not referenced in MEMORY.md file map
5. **Broken links:** Any markdown links in MEMORY.md that point to non-existent files

**If integrity check fails:**
1. Describe the anomaly to user
2. Propose fix
3. Wait for approval before fixing (unless trivial, like updating a count)

---

## 8. File Map Maintenance

MEMORY.md should contain a `## File Map` section listing all L2 files with short descriptions.

**Template:**
```
## File Map
- `memory/corrections.md` — Recurring errors and how to avoid them
- `memory/protocol.md` — Session lifecycle rules (this file)
- `memory/ptl.yaml` — Prioritized task list
- `memory/decisions.md` — Structural decisions with rationale
- `memory/session-details.md` — Full session history
- `memory/people.md` — Key contacts in tiers
```

Update when files are added or removed. Keep descriptions to one line.

---

## 9. System Review (Every 10 Sessions)

When Health Metrics shows "Sessions since System Review" ≥10:

1. Ask user: "Anything missing from my context?"
2. Review file map for orphans
3. Review corrections.md for outdated entries
4. Review ptl.yaml for stalled items
5. Reset "Sessions since System Review" counter to 0

---

## 10. Protocol Self-Limiting

This file stays under 200 lines. No explanations — only triggers and actions. If edge cases accumulate, compress into general principles.

**This is a living document.** Add sections as patterns emerge. Archive sections that become obsolete.
