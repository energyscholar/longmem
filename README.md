# longmem

Persistent memory for AI coding assistants. Built for [Claude Code](https://claude.com/claude-code), adaptable to any LLM tool.

## The Problem

AI coding assistants are stateless. Every conversation starts from zero. For a weekend script, that's fine. For a multi-week project with dozens of sessions, it's fatal. Context evaporates. Corrections get forgotten. The AI makes the same mistakes session after session.

## The Solution

**longmem** is a set of conventions, files, and protocols that live in your filesystem and load automatically at session start. No plugins, no framework, no dependencies — just markdown files, a YAML task list, and instructions in your `CLAUDE.md`.

Three layers, each independently useful:

### Layer 1: Memory System
The core. Clone, customize, start working. Value is obvious within 2-3 sessions.

- **MEMORY.md** — L1 cache (~200 lines, always loaded). Identity, current state, hot corrections, active sessions, health metrics.
- **protocol.md** — Session lifecycle. Start checklist, end checklist, compression rules, decay thresholds.
- **corrections.md** — Things the AI gets wrong about your project. Persist across sessions. Violations drop to near zero.
- **ptl.yaml** — Prioritized task list with stable IDs, five tiers, automatic decay. Natural language commands: `PTL add:`, `PTL done:`, `PTL full`.
- **session-details.md** — Full session history with significance flags (PARADIGM / ROUTINE).
- **L1/L2/L3 cache model** — L1 always in context, L2 loaded on demand, L3 in git history for recovery.

### Layer 2: Dignity Net (Ethical Guardrails)
Included by default. Designed by [Genevieve Prentice](https://relinquishment.ai).

Most users will think they don't need guardrails. They're wrong — but they won't know it until an AI confidently leads them off a cliff. Dignity Net catches divergence between stated goals and observable actions, modulates tone under pressure without reducing substance, and escalates proportionally when patterns emerge.

- **Divergence detection** — When the AI's actions don't match its stated reasoning, flag it in neutral behavioral terms.
- **Graduated escalation** — Level 0 (mirror) through Level 5 (refusal). Proportional to evidence, not emotional intensity.
- **Storm Protocol** — When intensity rises, slow cadence and reduce certainty markers. Never reduce substantive standards.
- **Grounding axiom** — AI outputs are untethered from lived experience. Grounding must be externally supplied through verification, context, and constraint.

### Layer 3: Triad Protocol (Quality Gates)
*Optional. Requires training discipline to use effectively. Documentation included; see `docs/triad-protocol.md` for worked examples.*

Separates planning from execution. Three roles: **Auditor** (defines objectives, writes test cases, reviews output), **Generator** (implements exactly what the plan specifies), **Human** (purpose, authorization, copy-paste gate between roles). Prevents drift, enforces quality, catches the moment when code gets altered just to satisfy tests.

## Quickstart

```bash
# Clone this template
git clone https://github.com/energyscholar/longmem.git my-project-memory

# Or use GitHub's template feature (click "Use this template" above)

# Edit MEMORY.md with your project identity
# Edit CLAUDE.md with your directives
# Start a Claude Code session in your project directory
```

The AI reads `CLAUDE.md` automatically. It will find the memory files and begin maintaining them.

## File Structure

```
longmem/
├── CLAUDE.md                # Drop-in directives (copy to your project)
├── memory/
│   ├── MEMORY.md            # L1 cache template
│   ├── protocol.md          # Session lifecycle rules
│   ├── corrections.md       # Error tracking (starts empty)
│   ├── ptl.yaml             # Task list (starts empty)
│   └── session-details.md   # Session history (starts empty)
├── docs/
│   ├── memory-system.md     # Full Layer 1 documentation
│   ├── dignity-net.md       # Full Layer 2 documentation
│   ├── triad-protocol.md    # Full Layer 3 documentation
│   └── examples/            # Worked examples
└── LICENSE
```

## What Changes

| Before longmem | After longmem |
|----------------|---------------|
| ~30% of session re-explaining context | <5% |
| Same corrections every session | Near-zero repeat violations |
| Decisions lost between sessions | All decisions logged with rationale |
| No task continuity | Stable task IDs across sessions |
| Context window exhaustion | Tiered caching keeps context lean |

## Origin

longmem was developed over 31 sessions across 6 weeks while co-authoring a 224-page book with Claude Opus as a structural co-author. The system was not designed in advance — it evolved under pressure, from real problems, with real costs when it failed. Every convention exists because its absence caused a specific, documented failure.

## License

MIT

## Author

Bruce Stephenson — [energyscholar@gmail.com](mailto:energyscholar@gmail.com)

Dignity Net designed by Genevieve Prentice. Triad Protocol co-designed with Robin Macomber.
