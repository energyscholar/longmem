# Self-Maintenance Protocol

*Lazy-loaded: read when triggers fire, not at boot. Keep under 200 lines.*

---

## 1. Session Start

1. Check Health Metrics in MEMORY.md (especially line count)
2. If MEMORY.md >180 lines: compress oldest ROUTINE session first
3. Read ptl.yaml for priorities
4. Scan L1 Corrections in MEMORY.md

## 2. State Update Triggers

Update `## Current State` in MEMORY.md when ANY of these changed:
- Key project metrics (coverage, page count, version, etc.)
- Major decisions made
- Blockers resolved or created
- Milestones reached

If nothing changed, don't touch it.

## 3. Session End (MANDATORY)

1. Run Section 2 checklist
2. Update ptl.yaml statuses for items discussed
3. Write new session summary in MEMORY.md `## Active Sessions`
4. Assign significance: **PARADIGM** or **ROUTINE**
   - PARADIGM: Changed approach, new insight, corrected assumption, or user flags it
   - ROUTINE: Everything else
   - **If unsure, default PARADIGM** — cost of keeping a 5-line block is negligible
5. Update Health Metrics table
6. Commit memory files to git

## 4. Compression Rules

1. MEMORY.md keeps 2-3 active sessions. Older sessions → session-details.md
   - PARADIGM: 3-5 lines, kept indefinitely
   - ROUTINE: 2-3 lines (never 1-line — too much signal loss)
2. session-details.md >200 lines → compress oldest ROUTINE blocks to 2-line entries

## 5. Corrections Management

- When user corrects you: add to corrections.md immediately
- If a correction is violated 2+ times: promote to L1 (MEMORY.md hot corrections)
- L1 holds max 5 corrections. Swap in more-violated ones as needed.
- Log rotations with date and reason.

## 6. PTL Maintenance

Canonical file: `ptl.yaml`. Display rendered on demand.

Commands: "PTL" (active), "PTL full" (all tiers), "PTL add:", "PTL done:", "PTL drop:".
Items addressed by stable ID (PTL-NNN), not display position.

Per-tier decay:
- Tier 1: No decay. Untouched >1 week → demote to Tier 2.
- Tier 2: 3 weeks → STALE, 6 weeks → archive.
- Tier 3+: 4 weeks → STALE, 8 weeks → archive.

## 7. Integrity Checks

- File paths in MEMORY.md must resolve (verify with ls when writing)
- Corrections count in Health Metrics must match corrections.md
- L1 corrections in MEMORY.md must match their counterparts in corrections.md
- Any anomaly: flag to user, do not silently fix

## 8. Protocol Self-Limiting

This file stays under 200 lines. No explanations — only triggers and actions.
If edge cases accumulate, compress into general principles.
