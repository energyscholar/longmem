# Architecture: Three-Tier Cache Model

**longmem** is a persistent memory system for Claude Code. It uses a three-tier cache model inspired by CPU cache hierarchies: L1 (always in context), L2 (loaded on demand), L3 (git recovery).

---

## Design Constraints

1. **No dependencies.** Markdown files, a YAML file, a shell script. Works with any git-initialized directory.
2. **Context window budget.** Every line in L1 costs tokens. The 200-line cap is economics, not theory.
3. **AI-maintained.** The system maintains itself. Compression, integrity checks, health metrics — all handled by Claude.
4. **Failure recovery.** Git is the backstop. Sessions crash, context compresses, mistakes happen. L3 recovery is non-negotiable.

---

## L1: Always In Context

**File:** `.longmem/memory/MEMORY.md`
**Hard cap:** 200 lines
**Enforcement threshold:** 180 lines (triggers compression)

L1 is loaded automatically by Claude Code at every session start. Contains:

- **Identity:** Project name, goal, key people
- **Current State:** Status, key metrics, blockers
- **L1 Corrections (Hot Five):** The five most-violated corrections, visible every session
- **Active Sessions:** 2-3 most recent session summaries
- **File Map:** Paths to L2 files with one-line descriptions
- **Health Metrics Dashboard:** Line count, item count, oldest unarchived session, broken refs

**Why 200 lines?**

Context window is expensive. Every line in L1 reduces available space for actual work. The 200-line cap forces discipline: what actually needs to be in L1 vs. what can live in L2? If you're explaining the same context every session, it belongs in L1. If you reference it once a week, it belongs in L2.

Empirically, 200 lines is enough for:
- Project identity and state (~30 lines)
- Hot five corrections (~25 lines)
- 2-3 active session summaries (~30 lines)
- File map (~15 lines)
- Health metrics (~20 lines)
- Breathing room (~80 lines for project-specific content)

The cap was derived from failure: MEMORY.md hit 233 lines, context became bloated, compression rules were formalized.

---

## L2: Loaded On Demand

**Files:**
- `corrections.md` — Full error tracking. Hot five rotate into L1.
- `protocol.md` — Session lifecycle rules. Lazy-loaded when triggers fire.
- `ptl.yaml` — Prioritized Task List. YAML format, stable IDs.
- `decisions.md` — Structural decisions with rationale.
- `session-details.md` — Full session history. Compression target.
- `people.md` — Key contacts in tiers (optional but recommended).

L2 files are read when depth is needed. They provide full reference material without consuming L1 budget.

**Why separate files?**

Separation serves multiple purposes:
1. **Context efficiency:** Load only what's needed for the current task
2. **Maintenance locality:** Update corrections without touching session history
3. **Compression targets:** session-details.md grows indefinitely; other files stay stable
4. **Recovery granularity:** Git history shows which aspect of memory changed

**File design principles:**
- **corrections.md:** One correction per section. Numbered. Include date established, last violated.
- **protocol.md:** Triggers and actions only, no explanations. Self-limiting to <200 lines.
- **ptl.yaml:** Machine-readable. Schema enforced. Stable IDs (PTL-NNN).
- **decisions.md:** Date, decision, rationale, status. Prevents re-litigating settled questions.
- **session-details.md:** Chronological. PARADIGM sessions kept indefinitely, ROUTINE compressed.
- **people.md:** Three tiers (Active / Peripheral / Historical). Not just collaborators — anyone the AI needs context about.

---

## L3: Git Recovery

**Mechanism:** `.longmem/scripts/memory-sync.sh`

At session end, all memory files are committed to git:
```bash
#!/bin/bash
set -e
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO"

if [ ! -d .git ]; then
    echo "Error: $REPO is not a git repository. Run 'git init' first."
    exit 1
fi

git add .longmem/

if git diff --cached --quiet; then
    echo "Memory sync: no changes to commit."
else
    git commit -m "Memory sync: $(date +%Y-%m-%d)"
    echo "Memory synced: $(git log --oneline -1)"
fi
```

**Why git?**

Git provides:
1. **Versioned snapshots:** Every session creates a commit. If compression goes wrong, roll back.
2. **Diff visibility:** See exactly what changed between sessions.
3. **Catastrophic recovery:** Sessions crash, context window resets, AI makes mistakes. Git is the backstop.
4. **Audit trail:** When did a correction get added? When did a decision get made? Git log knows.

L3 is the reason the system survived early failures. When PTL migration dropped half the active items, git history allowed reconstruction. When MEMORY.md bloat wasn't caught early, git showed the growth curve that led to the 200-line cap.

**L3 is not optional.** Without it, the system has no memory beyond the current session.

---

## The Corrections System

This is the most valuable component and the least expected.

**Format:**
```markdown
## Correction #N: [Short name]
[What the AI gets wrong] → [What to write instead]
Established: [date]. Last violated: [date or "never"].
```

**Example:**
```markdown
## Correction #3: API Version String
Don't write "v2" → Write "v2.1" (the difference breaks the build)
Established: 2026-02-15. Last violated: 2026-02-16.
```

**How it works:**

1. User corrects the AI about something project-specific
2. Correction gets added to `corrections.md` with date
3. If violated 2+ times, it's promoted to L1 (hot five in MEMORY.md)
4. At session start, AI reads corrections.md (full list, not just hot five)
5. When AI violates a correction, "Last violated" date gets updated
6. Hot five rotates based on violation frequency

**Why this works:**

The corrections file acts as a **synthetic loss function** — locally injected penalties on future generations. The AI hasn't been fine-tuned on your project, but its environment has been modified to penalize specific errors. Persistent memory plus prohibition approximates behavioral fine-tuning without weight changes.

Before corrections: same mistakes every session (user explains, AI apologizes, repeat).
After corrections: repeat violations drop to near zero.

The system was independently analyzed by ChatGPT without being told about corrections. Its description: "The corrections file is a synthetic loss function."

---

## Self-Maintenance Protocol

The AI maintains its own memory. No human intervention required (except fixing broken things when integrity checks flag them).

**Session start:**
1. Read MEMORY.md (auto-loaded)
2. Check health metrics
3. If MEMORY.md >180 lines: compress oldest ROUTINE session before proceeding
4. Read corrections.md (all of them, not just hot five)
5. Read ptl.yaml if working on tasks

**Session end (mandatory):**
1. Update current state in MEMORY.md
2. Write session summary (classify PARADIGM or ROUTINE)
3. If MEMORY.md >180 lines: compress oldest ROUTINE session
4. Run integrity checks (file refs, correction count, L1-L2 sync, orphans)
5. Update health metrics dashboard
6. Run `.longmem/scripts/memory-sync.sh` to commit to git

**Compression rules:**
- MEMORY.md keeps 2-3 active sessions
- PARADIGM sessions: 3-5 lines, kept indefinitely
- ROUTINE sessions: 2-3 lines after compression, eventually archived
- If MEMORY.md >180 lines: archive oldest ROUTINE to session-details.md
- If no ROUTINE sessions remain: compress oldest PARADIGM to 3-5 lines (never less)

**Decay rules:**
- PTL Tier 1: untouched >1 week → flag, consider demotion
- PTL Tier 2: untouched >3 weeks → STALE, >6 weeks → archive
- PTL Tier 3+: untouched >4 weeks → STALE, >8 weeks → archive
- Items with NEEDS_PLAN >8 weeks → STALLED

**Integrity checks:**
- All file paths in MEMORY.md resolve
- Corrections count in health metrics matches `wc -l corrections.md`
- L1 corrections match their L2 counterparts (meaning, not necessarily text)
- No orphan files (files in .longmem/memory/ not referenced in file map)
- No broken markdown links

**Health metrics tracked:**
- MEMORY.md line count (target <180)
- PTL item count (target <60)
- Corrections count
- Oldest unarchived ROUTINE session (target <3 weeks old)
- Broken file references (target 0)
- Sessions since system review (every 10 sessions: ask user "anything missing?")

---

## PTL (Prioritized Task List)

**File:** `.longmem/memory/ptl.yaml`
**Format:** YAML (machine-readable, git-friendly)

**Schema:**
```yaml
meta:
  version: 1
  last_modified: "YYYY-MM-DDTHH:MM:SSZ"
  item_count: 0
  tiers:
    1: "Urgent / Close Now"
    2: "Active Projects"
    3: "Queued"
    4: "Infrastructure"
    5: "Someday"
  statuses: [READY, ACTIVE, BLOCKED, REVIEW, NEEDS_PLAN, TODO, DONE, DROPPED]

items:
  - id: PTL-001
    title: "Set up CI pipeline"
    tier: 1
    status: READY
    owner: you
    blocked_by: null
    created: 2026-03-05
    touched: 2026-03-05
    note: "GitHub Actions, run tests on push"
```

**Why YAML?**

- Machine-readable: AI can update without parsing ambiguity
- Git-friendly: Diffs are clean
- Human-readable: Easy to review
- Stable IDs: PTL-NNN persists across sessions, not display position

**Natural language commands:**
- `PTL` — Show active items (tiers 1-3, statuses READY/ACTIVE/BLOCKED/REVIEW/TODO)
- `PTL full` — Show all tiers including DONE/DROPPED
- `PTL add: [description]` — Add new item
- `PTL update PTL-NNN: [changes]` — Update existing item
- `PTL close PTL-NNN` — Mark as DONE

**Five-tier system:**

1. **Urgent / Close Now:** Ship this week. No decay.
2. **Active Projects:** Current focus. Untouched >3 weeks → STALE.
3. **Queued:** Next up. Untouched >4 weeks → STALE.
4. **Infrastructure:** Not urgent, but important. Untouched >4 weeks → STALE.
5. **Someday:** Ideas, maybe-later. Untouched >8 weeks → archive.

Tiers prevent everything from being "high priority." Decay prevents zombies.

---

## Design Rationale

**Why not a database?**

Markdown and YAML are:
- Human-readable (easy to review, easy to fix)
- Git-friendly (diffs are meaningful)
- Tool-agnostic (works with any editor, any AI)
- Zero dependencies (no schema migrations, no version conflicts)
- Recoverable (worst case: text editor and git log)

**Why not auto-memory alone?**

Claude Code ships with auto-memory (`MEMORY.md`). It gets you 20% of the way:
- No structure (AI decides what to save)
- No error tracking (corrections get forgotten)
- No task continuity (no stable IDs)
- No recovery mechanism (no git sync)
- No enforcement (no line cap, no compression rules)

longmem adds structure, discipline, and self-maintenance.

**Why not a plugin?**

Plugins add:
- Version conflicts
- Installation friction
- Maintenance burden
- Lock-in to specific tools

Markdown files add:
- Portability
- Transparency
- Simplicity

**Why the 200-line cap?**

Context window is expensive ($200/month for Claude Pro Max). Every line in L1 reduces space for actual work. The cap forces discipline and prevents bloat. Empirically derived from hitting 233 lines and realizing the system had become unwieldy.

---

## Failure Modes and Recovery

longmem evolved under pressure. Every protocol rule traces back to a specific failure.

**Compression catastrophe (Session 26):**
- Migrated from flat TODO file to structured PTL
- Roughly half of high-priority items were dropped during migration
- **Fix:** Git history allowed reconstruction. Added integrity checks for item count.

**MEMORY.md bloat (Session 25):**
- Hit 233 lines before formalizing the cap
- Context became bloated, sessions slower
- **Fix:** Formalized 200-line cap, 180-line enforcement threshold, compression rules.

**Orphan files (~Session 26):**
- Research documents accumulated without being tracked in file map
- AI didn't know they existed
- **Fix:** Added orphan detection to integrity checks.

**Pending item zombies (~Session 27-28):**
- Tasks older than 8 weeks with no plan would sit indefinitely
- **Fix:** Added STALLED status, automatic decay rules.

**Every failure strengthened the system.** That's scar tissue, not theory.

---

## Extending longmem

The system is deliberately minimal. Extensions should:
1. Solve a real, documented problem
2. Fit the three-tier cache model
3. Be maintainable by the AI itself
4. Not require infrastructure or dependencies

**Good extensions:**
- Additional L2 files for specific project needs (e.g., `api-endpoints.md`, `deployment-checklist.md`)
- Project-specific health metrics
- Custom PTL tiers or statuses
- Domain-specific corrections

**Bad extensions:**
- Database backends (breaks portability)
- Web dashboards (adds complexity)
- Automated agents (removes human judgment)
- Clever abstractions (harder to debug, harder to recover)

Keep it simple. Keep it in the filesystem. Keep it maintainable.

---

## Summary

longmem is a three-tier cache model for AI memory:
- **L1 (MEMORY.md):** Always in context, 200-line cap
- **L2 (other files):** Loaded on demand
- **L3 (git):** Recovery mechanism

Key components:
- **Corrections system:** Synthetic loss function, repeat violations drop to near zero
- **PTL:** Five-tier task list, stable IDs, automatic decay
- **Self-maintenance:** AI manages its own memory, runs integrity checks, commits to git
- **Health metrics:** Line count, item count, orphan detection, system review every 10 sessions

The system evolved under pressure. Every rule traces back to a documented failure. It's scar tissue, not theory — and it works.
