# Layer 3: Triad Protocol (Quality Gates)

*Co-designed by Bruce Stephenson and Robin Macomber.*

> **Note:** The Triad Protocol requires training discipline to use effectively. Reading this document is necessary but not sufficient. See `examples/` for worked examples of real Auditor→Generator cycles.

## The Problem

When an AI both plans and executes, quality degrades. The AI drifts: it alters code to satisfy tests, alters tests to accommodate code, and increases local consistency while decreasing meaning. Nobody catches it because the same entity that made the mistake is reviewing the mistake.

## The Solution

Separate planning from execution. Three roles, strict boundaries:

### Human (Purpose)
- Defines what needs to happen and why
- Authorizes transitions between roles
- Copy-pastes handoff prompts between shells (this IS the authorization gate)
- Decides when to override or skip the protocol

### Auditor (Plan)
- Defines objectives and success criteria
- Writes test cases that encode invariants
- Creates plan files (self-contained, referenced by path)
- Reviews Generator output against acceptance criteria
- Interprets failures structurally
- Outputs a handoff prompt (≤8 lines, references plan file)

**The Auditor does NOT:**
- Write implementation code
- Modify source files
- Invoke or spawn the Generator

### Generator (Execute)
- Reads the plan referenced in the handoff prompt
- Implements exactly what the plan specifies
- Reports completion (1-5 lines)

**The Generator does NOT:**
- Invent tests beyond the plan spec
- Redefine scope
- Expand beyond what was requested

## The Handoff

The handoff prompt is the critical artifact. It must be:
- ≤8 lines
- Reference a plan file by path
- Self-contained (the Generator has NO conversation history)

The Human copy-pastes it from the Auditor shell to the Generator shell. This physical act IS the authorization. No automation. No shortcuts.

## Information Flow

```
Human (Purpose) → Auditor (Plan) → [Copy-Paste] → Generator (Code) → Auditor (Verify)
```

## Drift Detection

Stop and flag if any of these occur:
- Code altered just to satisfy tests
- Tests altered to accommodate code
- Increasing local consistency with decreasing meaning

These are symptoms of role collapse — the Generator doing the Auditor's job, or vice versa.

## When to Use It

- Multi-step changes where planning quality determines outcome
- Refactoring where invariants must be preserved
- Any task where "it works" is not sufficient — it must work for the right reasons

## When to Skip It

- Quick fixes, typos, configuration changes
- Exploratory work where the goal isn't clear yet
- Tasks where the overhead exceeds the benefit

Say "no role needed" to deactivate the protocol for a session.

## Why It Works

The Triad Protocol exploits the fact that AI is very good at following specific instructions but degrades when it both defines and follows its own instructions. Separating the definer from the executor — with a human gate between them — preserves the strengths of both modes.

The cost is overhead. The benefit is that your code does what you intended, not what the AI decided you intended.
