# Layer 1: Memory System

## Overview

The memory system gives your AI coding assistant persistence across sessions. It's a set of markdown files and a YAML task list that the AI reads at session start and updates at session end.

## The L1/L2/L3 Cache Model

Your AI has a limited context window. Not everything can be loaded every session. The cache model solves this:

- **L1 (MEMORY.md):** Always in context. ~200 lines max. Contains: identity, current state, hot corrections (top 5), active session summaries, health metrics. This is what the AI sees first, every time.

- **L2 (other memory files):** Loaded on demand. corrections.md (full list), decisions.md, people.md, or whatever your project needs. The AI reads these when relevant — not every session.

- **L3 (git history):** Recovery. If memory files get corrupted or accidentally overwritten, `git log` has every prior version. Commit memory files at session end.

## Why 200 Lines?

Every line in MEMORY.md costs tokens. Tokens cost money (or quota). A bloated MEMORY.md means:
- Slower session starts
- Less room for actual work in the context window
- Higher cost per session

200 lines is the sweet spot — enough to carry critical context, small enough to leave room for work. The compression and decay rules enforce this automatically.

## Corrections: The Most Valuable Component

Every project has things the AI gets wrong. Maybe it uses the wrong API version. Maybe it misunderstands your architecture. Maybe it keeps suggesting a pattern you've explicitly rejected.

Without persistence, you correct the same mistake every session. With corrections.md, you correct it once. The AI reads the correction at session start and doesn't repeat the error.

The top 5 most-violated corrections are promoted to L1 (MEMORY.md) where they're always visible. This is the highest-value part of the entire system.

## Session Tracking

Every session gets a summary in MEMORY.md, flagged as:
- **PARADIGM:** Changed your approach, revealed a new insight, corrected a fundamental assumption.
- **ROUTINE:** Normal work. Important but not perspective-shifting.

This matters for compression. When MEMORY.md gets too long, ROUTINE sessions get compressed first. PARADIGM sessions are preserved — they contain the insights you can't afford to lose.

## PTL (Prioritized Task List)

A YAML file with stable IDs (PTL-001, PTL-002, ...) that persists across sessions. Features:
- Natural language commands: "PTL add: Set up CI pipeline"
- Tier-based organization (This Week / Active / Backlog / Someday)
- Automatic decay: untouched items get flagged as STALE
- Status tracking: READY, ACTIVE, BLOCKED, DONE, DROPPED

The AI maintains it. You steer it with commands. No external tools needed.

## Getting Started

1. Copy the `memory/` directory and `CLAUDE.md` into your project
2. Edit `memory/MEMORY.md` — replace the template sections with your project's identity and current state
3. Start a Claude Code session. The AI will read CLAUDE.md and find the memory files.
4. At the end of your first session, the AI will update MEMORY.md with a session summary.
5. Next session: the AI remembers.

That's it. The system bootstraps itself from the first session.
