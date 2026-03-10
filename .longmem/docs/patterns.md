# Methodology Patterns

*Reference for longmem tutorials. Each pattern was learned through documented failure.*

---

## Pattern 1: Plan Before You Build

**Failure:** Sessions 25-26 of the founding project attempted migrations without written plans. Half the active PTL items were dropped. Recovery took 3 sessions.

**Pattern:** Before implementing anything non-trivial, write a short plan:
1. What am I doing? (1-2 sentences)
2. What does "done" look like? (acceptance criteria)
3. What could go wrong? (risk scan)

For simple tasks, this takes 30 seconds in your head. For complex tasks, write it down — even a 5-line plan in the PTL note field catches issues before they cost implementation time.

**Scaling:** As tasks grow, the plan grows:
- Small task: mental checklist (criteria + risks)
- Medium task: PTL note with acceptance criteria
- Large task: separate plan document with red-team review

---

## Pattern 2: Red-Team Before You Ship

**Failure:** Multiple protocol rules were shipped with edge cases that caused failures in production (adaptive thresholds caused oscillation, compression rules had positive feedback loops).

**Pattern:** After planning, ask: "What would break this?" Specifically:
- Positive feedback loops (does the fix make the problem worse?)
- Edge cases at boundaries (empty files, maximum sizes, first/last items)
- Idempotency (can this run twice safely?)
- Recursion depth (can this trigger itself?)

Iterate until remaining issues are LOW severity. Don't ship with HIGH or MEDIUM open.

**Cost:** 2-5 minutes of thinking saves 2-5 sessions of rework.

---

## Pattern 3: Separate Planning from Implementation

**Failure:** When the same session plans and implements, scope creep is universal. The planner adds features mid-implementation. The implementer second-guesses the plan. Confabulation risk rises because there's no external check.

**Pattern (Triad):** The entity that plans should not implement.
- **Auditor role:** Defines objectives, writes acceptance criteria, reviews output
- **Generator role:** Reads the plan, implements exactly what's specified, reports completion

In Claude Code: run Auditor and Generator in separate shells. The plan document is the contract between them. Copy-paste is the authorization gate.

**When to use:** When specs are ambiguous, when scope exceeds one session, when you catch yourself adding "while I'm at it..." features. Start with Pattern 1 (planning). Graduate to Pattern 3 when you need enforcement.

---

## Pattern 4: Structure Over Behavior

**Failure:** "Remember to run the sync script" was forgotten 40% of the time. "Remember to check the line count" was forgotten 60% of the time. Behavioral rules have a half-life of about 3 sessions.

**Pattern:** If something needs to happen reliably, build it into data or scripts — not into instructions that say "remember to do X."

Examples:
- Health warnings in memory-sync.sh (structural) vs "check file sizes" in protocol (behavioral)
- PTL decay rules computed from dates (structural) vs "review old items" (behavioral)
- Dedup guard checking existing sessions (structural) vs "don't run session-end twice" (behavioral)

**Test:** If the AI has a bad session and forgets half its instructions, does the thing still work? If yes, it's structural. If no, it's behavioral and fragile.

**See also:** Open threads (implicit task tracking) — a structural approach to task continuity that requires zero user maintenance. Protocol.md Section 13.

---

## Pattern 5: Inform, Don't Optimize (DN Level 0)

**Failure:** An adaptive compression threshold was designed that automatically tightened based on correction frequency. Analysis revealed a positive feedback loop: more compression triggered more corrections, which tightened the threshold further. The feature was killed before shipping.

**Pattern:** Systems that reveal state earn their cost. Systems that automate decisions reduce transparency and risk runaway.

- Health vector SHOWS you where you are → good (you decide what to do)
- Adaptive threshold MOVES you somewhere → dangerous (you lose visibility)
- Correction count displayed → good (you notice patterns)
- Auto-rotation based on count → questionable (removes human judgment)

**Rule of thumb:** If removing the feature would leave the user less informed, keep it. If removing it would leave the user less controlled, kill it.

---

## Pattern 6: Find Your Edge

**Failure:** Projects that stayed in comfortable territory (easy tasks, no corrections) learned nothing. Projects that overreached (too many tasks, too ambitious) crashed repeatedly. The productive zone is at the boundary.

**Pattern:** Your corrections tell you where your edge is. They cluster around the concepts you're still learning. The health vector tells you how much pressure you're under.

- **Too easy:** No corrections accumulating, health vector flat, sessions all ROUTINE. Try a harder tier.
- **Too hard:** Corrections piling up, p > 0.8, sessions crashing. Scale back, consolidate.
- **Productive edge:** 1-2 new corrections per 3 sessions, p around 0.5-0.7, mix of PARADIGM and ROUTINE.

This isn't about optimization. It's about noticing where you are so you can choose where to go.

---

## Pattern 7: Specs First, Then Tests, Then Code

**Failure:** Features built without specifications drifted during implementation. "I'll know it when I see it" led to three rounds of rework on the PTL migration because acceptance criteria were invented after the code was written.

**Pattern:** Write the specification. Then write failing tests that encode the spec. The gap between failing tests and passing tests IS your implementation plan.

1. Write spec (what does the feature do?)
2. Write failing acceptance tests (how do we know it works?)
3. Gap analysis (what's missing between current state and passing tests?)
4. Plan the feature to close the gap
5. Implement → iterate until tests pass
6. Red-team the result (Pattern 2)

**Why this ordering matters:** If you write code first, the tests get written to match the code (confirmation bias). If you write tests first, the code gets written to match the spec. The direction of causation determines whether you're testing what you built or building what you specified.

**Scaling:** For small tasks, the "spec" is a mental model and the "test" is checking the output. For large tasks, formal test files prevent specification drift.
