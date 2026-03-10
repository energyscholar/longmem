# Disaster Recovery

*Adapt this for your project. The tiers below cover common failure modes.*

## Tier 1: Session Crash

Context lost mid-session. Check MEMORY.md for session summary. Check git log for mid-session checkpoint. Reconstruct from last known state.

## Tier 2: File Corruption

YAML parse error or broken MEMORY.md. Run `.longmem/scripts/memory-sync.sh` — it creates git snapshots. Restore from last good commit: `git show HEAD~1:.longmem/memory/ptl.yaml > .longmem/memory/ptl.yaml`

## Tier 3: Total Loss

Clone from git. All memory files are committed. First session after restore: read MEMORY.md, verify file refs, run integrity checks (protocol.md Section 7).

## Prevention

- Run memory-sync.sh at every session end
- Mid-session checkpoints after major deliverables
- Don't force-push your repo
- Review `.longmem/` changes in PRs with same scrutiny as code changes
