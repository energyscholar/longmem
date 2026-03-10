# Self-Maintenance Protocol

*Lazy-loaded: read when triggers fire, not at boot.*

---

## 1. Session Start Checklist

> **Early sessions (1-5):** Most of these steps are no-ops when files are empty. Read MEMORY.md, read corrections.md, start working. The full protocol activates as your project grows.

1. Read `.longmem/memory/MEMORY.md` (auto-loaded by Claude Code)
2. Check Health Metrics dashboard
3. If MEMORY.md ≥180 lines: read Section 3 (compression), execute before proceeding
4. Read `.longmem/memory/corrections.md` to load all corrections (not just hot five)
5. If working on tasks: read `.longmem/memory/ptl.yaml` for current priorities
6. If Health Metrics show anomalies: investigate and fix

**Triggers for reading this file:**
- Health metric out of bounds
- MEMORY.md ≥180 lines
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

When MEMORY.md ≥180 lines:

1. **BEFORE doing anything else in the session**, read this section
2. Identify oldest ROUTINE session in `## Active Sessions`
3. Move full summary to `.longmem/memory/session-details.md`
4. Replace with 1-line pointer: `Session NN (ROUTINE, YYYY-MM-DD) — [topic]. Details in session-details.md.`
5. If no ROUTINE sessions remain, compress oldest PARADIGM to 3-5 lines (never less)
6. Update Health Metrics line count
7. Verify MEMORY.md is now <180 lines before proceeding

**Never compress:** Identity, Current State, L1 Corrections, Health Metrics, File Map.

**Overflow:** Section >20 lines → extract to L2 file, leave pointer. L2 file >300 lines → archive to git (L3). Index >150 lines → compress to navigation only. Always: move content → leave pointer → update File Map.

---

## 4. Session End Protocol (MANDATORY)

**Run these steps at the end of EVERY session:**

0. **Deduplication guard:** Check if `## Active Sessions` in MEMORY.md already contains a summary for the current session (match session number and today's date). If yes: this is a double-run. Skip to step 7 (memory-sync only).
1. **Update Current State** (Section 2 triggers)
2. **Update PTL statuses** for any items discussed
3. **Write session summary** in MEMORY.md `## Active Sessions`:
   - Session number and date
   - Significance flag: PARADIGM or ROUTINE
   - 3-5 line summary
4. **Classify:** PARADIGM (new insight, direction change, milestone) or ROUTINE (incremental). Default PARADIGM if unsure.
5. **Update Health Metrics:** line count, PTL count, corrections count, broken refs, oldest ROUTINE, health vector (Section 9)
6. **Run integrity checks** (Section 7)
7. **Commit memory files:** run `.longmem/scripts/memory-sync.sh`

---

## 5. Corrections Management

**When user corrects you:** Acknowledge → add to corrections.md (format: `### Correction #N: [name]`, what's wrong → what's right, dates) → if repeat (2+), promote to L1. Never make the same mistake twice.

**L1 (Hot Five):** Max 5 in MEMORY.md, swap by violation frequency. On violation: update "Last violated" date, promote if 2+.

---

## 6. PTL Maintenance

**Canonical file:** `.longmem/memory/ptl.yaml`. Commands and schema defined in directives.md.

**Decay rules:**
- Tier 1: No auto-decay. Untouched >1 week → flag to user
- Tier 2: Untouched >3 weeks → STALE, >6 weeks → archive
- Tier 3+: Untouched >4 weeks → STALE, >8 weeks → archive
- NEEDS_PLAN >8 weeks → STALLED (flag to user)

**Bandwidth cap:** Item count target <60. If exceeded, review and archive.

---

## 7. Integrity Checks

Run at session end. **Do not silently fix — flag anomalies to user.**

1. **File references:** All paths in MEMORY.md file map must resolve
2. **Corrections count:** Health Metrics count must match `### Correction #` headings in corrections.md
3. **L1-L2 sync:** L1 corrections in MEMORY.md must match counterparts in corrections.md (brevity OK, meaning must align)
4. **Orphan/broken:** Flag files in .longmem/memory/ not in File Map, or linked but missing. Update File Map when files added/removed.
5. **Path safety:** File Map entries must be relative paths within `.longmem/`. Reject `..`, `/`, or `~` prefixes.

**If integrity check fails:** Describe anomaly → propose fix → wait for approval (unless trivial).

---

## 8. System Review (Every 10 Sessions)

When Health Metrics shows "Sessions since System Review" ≥10:

1. Ask user: "Anything missing from my context?"
2. Review file map for orphans
3. Review corrections.md for outdated entries
4. Review ptl.yaml for stalled items
5. Reset "Sessions since System Review" counter to 0

---

## 9. Health Vector

Compute at session end. Store in MEMORY.md Health Metrics.

**Dimensions (each 0-1):**
- **p (pressure):** `wc -l .longmem/memory/MEMORY.md` / 200. Healthy: 0.3-0.7.
- **f (freshness):** Days since newest correction violation / 30. Healthy: < 0.5. If no corrections yet: 0.
- **v (coverage):** File Map entries that resolve / total entries. Healthy: 1.0.
- **d (drift):** Sessions since last system review / 10. Healthy: < 1.0.

**Display:** `[p=0.6 f=0.3 v=1.0 d=0.4]` in Health Metrics table.

**Change detection:** Compare current vector to stored vector from last session. If any dimension shifted > 0.2, flag: "Health: [dim] shifted [old] → [new]."

**Action thresholds (inform, don't automate):**
- p > 0.9: Compression overdue. Read Section 3.
- f > 1.0: All corrections stale 30+ days. Consider rotation (Section 5).
- v < 1.0: Broken references. Fix immediately.
- d ≥ 1.0: System review overdue. Run Section 8.

---

## 10. Crash Recovery (Tiered)

If session starts with errors (YAML parse failure, broken File Map refs, health vector anomaly):

**Tier 1 — Auto-repair:**
- Count mismatch: recalculate from source file
- Broken ref: remove from File Map, flag to user
- Stale metric: recompute from current state
- If fixed → resume normal startup

**Tier 2 — Git revert (if Tier 1 fails):**
1. If `.longmem/.recovering` exists → go to Tier 3
2. Create `.longmem/.recovering`
3. `git checkout <most-recent-sync> -- .longmem/` — revert to stable (max depth 1)
4. Preserve new corrections: `git diff <stable>..HEAD -- .longmem/memory/corrections.md`
5. Remove `.longmem/.recovering`, resume startup

**Tier 3 — Escalate:** STOP. Tell user: "Memory corrupted. Last 5 sync commits: [list]. Pick a restore point." Do NOT recurse or re-execute crashed session tasks.

---

## 11. Mid-Session Checkpoints (Optional)

After completing a major deliverable: update MEMORY.md current state, run `.longmem/scripts/memory-sync.sh`. Use judgment — checkpoint after features, plans, test suites, not small edits. ~50 tokens per checkpoint.

---

## 12. Tutorials (Progressive Disclosure)

At session start, after startup checks, if ptl.yaml has no tutorial items with status ACTIVE:

| Trigger | Item | Teaches |
|---------|------|---------|
| Session ≥3, no plan written yet | PTL-T01 | Planning (Pattern 1) |
| Session ≥5, corrections exist | PTL-T02 | Red-team (Pattern 2) |
| Session ≥8, >3 PTL items | PTL-T03 | Role separation (Pattern 3) |
| Session ≥10 | PTL-T04 | Structure over behavior (Pattern 4) |
| Health vector computed 3+ times | PTL-T05 | Inform not optimize (Pattern 5) |
| Session ≥12, corrections ≥3 | PTL-T06 | Finding your edge (Pattern 6) |
| Session ≥6, PTL items exist | PTL-T07 | Specs first (Pattern 7) |

**Rules:** Max ONE new tutorial per session. Skip if user said "no tutorials." All tutorials are tier 5, decay_exempt, owner "longmem". Add to ptl.yaml only when trigger fires. Reference: `.longmem/docs/patterns.md`.

---

## 13. Protocol Self-Limiting

This file stays under 200 lines. No explanations — only triggers and actions. Compress edge cases into general principles. This is a living document.
