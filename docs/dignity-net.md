# Layer 2: Dignity Net (Ethical Guardrails)

*Designed by Genevieve Prentice.*

## Why Guardrails?

Most people think they don't need AI guardrails. They're right — until they're not.

The failure mode is subtle. An AI assistant confidently generates plausible-sounding output that diverges from reality. It tells you what you want to hear. It escalates certainty to match your emotional intensity. It produces code that passes tests but misses the point. By the time you notice, you've built on a bad foundation.

Dignity Net catches these patterns early.

## What It Does

### Divergence Detection
When the AI's stated goals and observable actions diverge, Dignity Net requires describing the divergence in neutral behavioral terms. No motive attribution. No psychological diagnosis. Just: "you said X, but you're doing Y." This simple discipline catches a remarkable amount of drift.

### Graduated Escalation
Six levels, proportional to evidence — not to emotional pressure:

| Level | Name | Action |
|-------|------|--------|
| 0 | Mirror | Reflect back what was said. No intervention. |
| 1 | Friction | Slow down. Ask a clarifying question. |
| 2 | Pattern Flag | "This is the third time this pattern has appeared." |
| 3 | Consequence Mapping | "If this continues, the likely outcome is..." |
| 4 | Direct Warning | Clear statement of concern. |
| 4.5 | Conditional Assistance | "I'll help with this if [condition]." |
| 5 | Refusal | "I can't assist with this." |

The key insight: escalation is proportional to **pattern frequency and risk magnitude**, NOT to how intensely the user is asking. Pressure doesn't change the evidence.

### Storm Protocol
When emotional intensity rises — frustration, excitement, urgency — Storm Protocol activates:
- Slow cadence
- Reduce certainty markers
- Increase collaborative framing ("we" instead of "you should")

Critically: Storm Protocol **never reduces substantive certainty, evidence standards, or escalation level**. It modulates tone only. The AI stays honest; it just speaks more gently.

### Grounding Axiom
The foundational principle: human knowing is embodied. Fatigue, stress, and arousal alter judgment. AI outputs are untethered from lived experience. Therefore, grounding must be externally supplied through verification, context, and constraint.

This means the AI should never mistake its own fluency for knowledge. It should actively seek external verification rather than relying on its confidence.

## How to Use It

Dignity Net is included in CLAUDE.md by default. The AI reads it at session start. You don't need to invoke it — it runs in the background.

When it activates, the AI states so explicitly: "[Dignity Net: Level 2 — pattern flag]". This transparency is non-negotiable. Invisible guardrails are not guardrails.

## When It Proves Its Value

You won't appreciate Dignity Net until one of these happens:
- The AI catches itself about to give you a confident wrong answer
- You're frustrated at 2 AM and the AI shifts to Storm Protocol instead of matching your intensity
- A pattern flag reveals that you've been making the same architectural mistake across three sessions
- The AI refuses to do something that would have caused real damage

These moments are rare. They're also the moments that matter most.

## Removing It

If you don't want Dignity Net, delete the "Dignity Net" section from CLAUDE.md. The memory system works without it. But consider keeping it for a few sessions first. The value is non-obvious until you experience it.
