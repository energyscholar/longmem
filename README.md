# longmem

**Persistent memory for Claude Code.** Markdown files, a YAML task list, and a shell script. No plugins, no framework, no dependencies.

---

## What Is This?

AI coding assistants are stateless. Every conversation starts from zero. For a weekend script, that's fine. For a multi-week project with dozens of sessions, hundreds of decisions, and multiple collaborators — it's not workable.

**longmem** is a structured memory system that lives in your filesystem and loads automatically at session start. It gives Claude Code:

- **Persistent identity** — The AI knows what project it's working on, what matters, and where things are
- **Error tracking** — Corrections you make persist across sessions. Repeat violations drop to near zero.
- **Task continuity** — Stable task IDs, five-tier prioritization, automatic decay for stale items
- **Decision log** — Structural decisions with rationale. Prevents re-litigating settled questions.
- **Self-maintenance** — The AI maintains its own memory: compression, integrity checks, health metrics, git snapshots

The system evolved under pressure over 36 sessions across 16 weeks while co-authoring a 224-page technical manuscript. Every protocol rule traces back to a specific, documented failure.

---

## Quickstart

### Stage 1: Start Here (5 minutes)

1. **Clone or use the template**
```bash
git clone https://github.com/energyscholar/longmem.git my-project-memory
cd my-project-memory
```
Or use GitHub's "Use this template" button.

2. **Edit `memory/MEMORY.md`** — fill in your project name, goal, key people
3. **Run `claude`** from the project directory
4. **That's it.** Claude reads MEMORY.md and starts building context.

### Stage 2: After ~5 Sessions

- Claude will start making mistakes about your project. When it does, say: "Add a correction: [what's wrong] → [what's right]." Claude adds it to `corrections.md` and checks it every session.
- If you're tracking tasks, say "PTL add: [task]." Claude manages `ptl.yaml`.

### Stage 3: After ~10 Sessions

- MEMORY.md approaches 200 lines. Claude reads `protocol.md` and compresses automatically.
- Session-end sync (`scripts/memory-sync.sh`) creates git snapshots for recovery.
- At this point, all files are active. You didn't have to learn them all on Day 1.

---

## Deep Dive

### File Structure

```
longmem/
├── README.md                    # This file
├── CLAUDE.md                    # Drop-in Claude Code directives
├── CONTRIBUTING.md              # Contribution guidelines
├── feedback.md                  # Friction log for user feedback
├── memory/
│   ├── MEMORY.md                # L1 cache (~200 lines, always loaded)
│   ├── protocol.md              # Session lifecycle rules
│   ├── corrections.md           # Error tracking (starts empty)
│   ├── ptl.yaml                 # Prioritized task list (starts empty)
│   ├── decisions.md             # Decision log (starts empty)
│   ├── people.md                # Key contacts in tiers
│   └── session-details.md       # Full session history (starts empty)
├── scripts/
│   └── memory-sync.sh           # Git sync for L3 recovery
├── docs/
│   ├── architecture.md          # Three-tier cache model explained
│   └── case-study.md            # 36 sessions, 128 commits, zero context losses
├── .github/
│   └── ISSUE_TEMPLATE/          # Bug report and setup help templates
├── LICENSE                      # MIT
└── .gitignore                   # Minimal: only OS/editor junk
```

---

## How It Works

**Three-tier cache model:**

- **L1** (`MEMORY.md`): Always in context. Capped at 200 lines. Contains identity, current state, the five most critical corrections, active session summaries, and health metrics.
- **L2** (other files in `memory/`): Loaded on demand when depth is needed. Full reference material.
- **L3** (git history): Recovery mechanism. A session-end sync script commits everything to git, creating versioned snapshots. When context compresses or sessions crash, git is the backstop.

**The corrections system** is the most valuable component. You maintain a list of things the AI consistently gets wrong about your project. Each correction is a short imperative: what not to write, what to write instead. The five most-violated rotate into L1 where they're visible every session. Before corrections: same mistakes every session. After: repeat violations near zero.

**Self-maintenance:** The AI manages its own memory. At session end it updates state, writes a session summary, compresses older sessions to stay under the line cap, runs integrity checks, and commits to git. The system maintains itself.

For full technical detail, see [`docs/architecture.md`](docs/architecture.md).

---

## Talking to Your AI

Once longmem is set up, these commands work in any session:

**Tasks:**
- `PTL` — Show your prioritized task list
- `PTL add: fix the auth bug` — Add a task (Claude will ask for tier/priority)
- `PTL close PTL-003` — Mark a task done

**Corrections:**
- "You keep calling it a REST API — it's GraphQL. Add a correction." → Claude adds it to `corrections.md` and starts enforcing it
- "That correction is outdated, remove it." → Claude updates the file

**People:**
- "Remember that Sarah is my tech lead, prefers Slack over email." → Claude adds to `people.md`

**Memory management:**
- "What's in your memory?" → Claude summarizes what it knows
- "Sync memory" → Runs `memory-sync.sh` (also happens automatically at session end)

---

## What's Included

- **Memory templates** — MEMORY.md, corrections.md, ptl.yaml, decisions.md, session-details.md, people.md
- **Session lifecycle protocol** — Start checklist, end checklist, compression rules, decay timers
- **PTL (Prioritized Task List)** — YAML-based, stable IDs, five tiers, natural language commands
- **Corrections system** — Persistent error tracking with hot-five rotation
- **Health metrics dashboard** — Line count, item count, orphan detection, integrity checks
- **Git sync script** — L3 recovery via automatic commits
- **Full documentation** — Architecture deep-dive, case study, worked examples

---

## What Changes

| Before longmem | After longmem |
|----------------|---------------|
| ~30% of session re-explaining context | <5% |
| Same corrections every session | Near-zero repeat violations |
| Decisions lost between sessions | All decisions logged with rationale |
| No task continuity | Stable task IDs, five-tier prioritization |
| Context window exhaustion | Tiered caching keeps context lean |
| Manual git commits | Automatic session-end sync |

Results from 36 sessions over 16 weeks (128 commits):
- **49 task items tracked, 65 plans executed**
- **22 corrections established, repeat violations near zero**
- **Zero catastrophic context losses** (after system established)
- **Context re-explanation: 30% → <5%**

See [`docs/case-study.md`](docs/case-study.md) for details.

---

### Why is there no setup script?

There is no `setup.sh`. That's intentional. The entire setup is: edit one file (`memory/MEMORY.md`), then run `claude`. Zero dependencies, zero installation, zero configuration. If setup takes more than 5 minutes, something is wrong — [open an issue](https://github.com/energyscholar/longmem/issues/new?template=setup_help.md).

---

## Troubleshooting

**Claude doesn't load MEMORY.md**
- Verify `CLAUDE.md` is in the project root (not a subdirectory)
- Restart Claude Code (`claude` from the project directory)
- Check that `memory/MEMORY.md` exists and is not empty

**memory-sync.sh fails**
- Run `git init` if this is a new project (script requires a git repo)
- On macOS: ensure bash is available (`bash --version`)
- Check file permissions: `chmod +x scripts/memory-sync.sh`

**PTL commands not recognized**
- Claude needs to read `CLAUDE.md` first — start the session from the project root
- Try: "Read CLAUDE.md and then show me the PTL"

**MEMORY.md getting too long**
- Normal: the AI should compress automatically at 180 lines
- If not compressing: say "MEMORY.md is over 180 lines, please compress per protocol.md"

**Requirements:** Claude Code, git, bash. Tested on Ubuntu 22.04+ and macOS 13+. Windows: untested, should work under WSL2.

---

## What longmem is NOT

- **Not a plugin or extension** — It's files. No installation, no dependencies.
- **Not cloud-synced** — Memory lives on your filesystem + git. You own it.
- **Not automatic** — The AI maintains the memory, but you direct the project.
- **Not multi-user** — Each developer has their own memory. Share context via project docs.
- **Not a replacement for documentation** — longmem is project context for the AI, not docs for humans.

---

## Contributing

longmem is deliberately minimal. Additions should:
- Solve a real, documented problem
- Not require infrastructure or dependencies
- Fit the three-tier cache model
- Be maintainable by the AI itself

If you have corrections to documentation, bug fixes, or small improvements, pull requests are welcome.

For major changes, open an issue first to discuss rationale and design.

---

## License

MIT License. See [LICENSE](LICENSE).

---

## Contact

For questions, bug reports, or consulting on structured memory systems for AI-assisted development:

**energyscholar+consulting@gmail.com**

---

[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
