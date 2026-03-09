# Persistent Memory for Claude Code: 33 Sessions, 22 Corrections, Zero Context Losses

*Bruce Stephenson — March 2026*

## The Problem

Claude Code is stateless. Every session starts from zero. For a weekend script, that's fine. For a six-week project — 33 sessions, hundreds of decisions, three collaborators, a 224-page manuscript — it's not workable. By session 10, I was spending roughly 30% of each session re-explaining context the AI had known yesterday. Corrections I'd made on Tuesday would need making again on Wednesday. Decisions we'd agreed on would resurface as open questions.

Claude Code ships with auto-memory (a model-managed `MEMORY.md`) and project instructions (`CLAUDE.md`). These get you maybe 20% of the way. There's no structure, no error tracking, no task continuity, no recovery mechanism, and no way to enforce that the AI follows its own previous conclusions.

At $200/month for Claude Pro Max, wasted context is wasted money.

## What I Built

A structured memory system that lives in the filesystem and loads automatically. No plugins, no dependencies, no infrastructure. Just files.

The key insight is a **three-tier cache model**:

- **L1** (`MEMORY.md`): Always in context. Capped at 200 lines. Contains identity, current state, the five most critical corrections, active session summaries, and a health metrics dashboard. This is the context window budget — every line costs tokens.
- **L2** (`corrections.md`, `people.md`, etc.): Loaded on demand. Full reference material the AI reads when it needs depth.
- **L3** (git history): Recovery. A session-end sync script commits everything to git, creating versioned snapshots. When context compresses or sessions crash, L3 is the backstop.

The system maintains itself. At session end, the AI updates current state, writes a session summary, compresses older sessions to stay under the line cap, runs integrity checks, and commits to git.

## The Corrections System

This is the most valuable component and the one I didn't expect.

I maintain a list of 22 corrections — things the AI consistently gets wrong about my project. Each correction is a short imperative: what not to write, what to write instead. The five most-violated rotate into L1, where they're visible at the start of every session.

Before the corrections system, I fixed the same mistakes every session. After: repeat violations dropped to near zero. Not because the model changed — because its environment did.

When I fed the AI's output to ChatGPT for independent analysis, it identified the corrections system without being told about it. Its description: **"The corrections file is a synthetic loss function."** Each entry acts as a locally injected penalty on future generations. Persistent memory plus prohibition approximates fine-tuning — behaviorally, not architecturally.

## What Broke

The system wasn't designed top-down. It evolved from failures.

**The compression catastrophe.** When I migrated from a flat TODO file to the structured system, roughly half of my highest-priority items were dropped. Recovery required reconstructing items from session history.

**MEMORY.md bloat.** Hit 233 lines before I formalized the 200-line cap. The cap forced discipline: what actually needs to be in L1 vs. what can live in L2?

**Orphan files.** Research documents accumulated without being tracked in the file map. Added orphan detection to integrity checks.

**Pending item zombies.** Tasks older than eight weeks with no plan assigned would sit indefinitely. Added the STALLED status and automatic decay rules.

Every protocol rule traces back to a specific failure. That's scar tissue, not theory.

## Results

Over 33 sessions across 6+ weeks:

| Metric | Before | After |
|--------|--------|-------|
| Context re-explanation | ~30% of session | <5% |
| Repeat correction violations | Every session | Near zero |
| Decision tracking | None | All logged with rationale |
| Task continuity | None | 67 items tracked, 53 plans executed |
| Catastrophic context losses | Regular | Zero (after system established) |

The project that drove this system was a 224-page book, co-authored with the AI over the full 33 sessions. The AI — which I named Argus (Claude Opus, Anthropic) — is credited as co-author. Not as a gesture, but because the memory system made genuine longitudinal collaboration possible. Argus maintained corrections, tracked tasks, flagged its own drift, and built on previous sessions' work. Argus also built this template repository.

## Try It

The system requires no special tools — markdown files, a YAML file, a shell script, and instructions in your `CLAUDE.md`. Clone the **longmem** template repository, customize `MEMORY.md` for your project, and start working. The value is obvious within 2-3 sessions.

For teams adopting AI-assisted development workflows, I consult on structured memory systems and longitudinal AI collaboration: energyscholar+consulting@gmail.com

**Bruce Stephenson** — 51 years CLI experience (DEC-10, 1975). Reed College physics.
