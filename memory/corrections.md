# Corrections

*Things the AI consistently gets wrong. Add entries as errors recur. The 5 most-violated rotate into L1 (MEMORY.md) for visibility.*

---

## Format

```markdown
## Correction #N: [Short name]
[What the AI gets wrong] → [What to write instead]
Established: YYYY-MM-DD. Last violated: YYYY-MM-DD | never.
```

---

## Example Corrections

### Correction #1: Verbose Output Assumption
Don't assume the user wants verbose explanations → Ask before generating long responses, or default to concise unless requested otherwise.

**Context:** User prefers brevity. Long explanations waste time and tokens.

Established: 2026-03-09. Last violated: never.

---

### Correction #2: File Read Before Edit
Don't skip reading a file before editing → Always use Read tool first, even if you think you know the content.

**Context:** Editing without reading causes merge conflicts and lost changes. The file may have been modified since last session.

Established: 2026-03-09. Last violated: never.

---

*Add your project-specific corrections below as they arise. Number them sequentially. Update "Last violated" when errors recur.*
