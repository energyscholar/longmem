# Structural Decisions

> **Optional.** Activate when you need to track structural decisions. Most projects start needing this around session 5-10.

*Key decisions with rationale. Prevents re-litigating settled questions.*

---

## Format

```markdown
### Decision: [Short title]
**Date:** YYYY-MM-DD
**Decision:** [What was decided]
**Rationale:** [Why this choice over alternatives]
**Status:** Active | Superseded | Reversed
```

---

### Decision: Use REST API (not GraphQL)
**Date:** 2026-03-09
**Decision:** REST endpoints for all public APIs
**Rationale:** Team has REST experience; GraphQL adds complexity without clear benefit at current scale. Revisit if frontend needs change.
**Status:** Active

---

*Add decisions as they're made. Update status if they change. Reference this file when similar questions arise.*
