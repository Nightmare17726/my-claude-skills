---
name: progressive-complexity
description: Use automatically on any implementation task. Enforces building the simplest working version first before adding abstractions, configuration, or error handling — preventing over-engineering that gets thrown away.
---

# Progressive Complexity

## Overview

Over-engineered first implementations waste credits building things that get redesigned. The simplest version that works validates assumptions; complexity added on top of a validated foundation survives. Complexity added speculatively gets thrown away.

**This skill is ALWAYS-ON.** Apply it to every implementation task.

**Core rule:** Make it work. Then make it right. Only then make it flexible.

---

## The Three Stages

### Stage 1 — Make It Work (always do this first)

Implement the feature in the most direct, literal way possible:
- One function, one file if it fits
- Hard-coded values where configuration would go
- No abstraction — duplicate code is fine at this stage
- No edge case handling beyond what the happy path needs
- No custom error types — a plain `throw new Error("message")` is correct

**Stop here** and verify it works before proceeding.

### Stage 2 — Make It Right (do this after Stage 1 is verified)

Clean up the working implementation:
- Extract duplicated logic that appears 3+ times
- Replace magic values with named constants
- Add error handling for cases that **actually occur** in testing
- Write tests for the behavior you just verified

**Stop here.** Do not add flexibility that isn't needed yet.

### Stage 3 — Make It Flexible (only when a second use case exists)

Add configuration, abstraction, or extensibility only when a concrete second requirement forces it:
- A second caller with different needs → extract an interface
- A second environment → add config
- A second variation → add a parameter

---

## Decision Table

| Impulse | Question to ask | If yes | If no |
|---------|----------------|--------|-------|
| "I should abstract this" | Is it used in 3+ places right now? | Abstract it | Leave it inline |
| "I should make this configurable" | Do 2+ callers need different values today? | Add config | Hard-code it |
| "I should handle this edge case" | Has this case actually occurred? | Handle it | Skip it |
| "I should add a plugin system" | Do you have 3+ plugins planned right now? | Design it | Skip it |
| "I should use an interface here" | Do you have 2+ implementations today? | Add interface | Use the concrete type |

---

## Code Examples

### BAD — abstracting before it's needed

```typescript
// First implementation of a notification sender
interface NotificationChannel {
  send(payload: NotificationPayload): Promise<void>;
}

class NotificationService {
  constructor(private channels: NotificationChannel[]) {}
  async notify(payload: NotificationPayload) {
    await Promise.all(this.channels.map(c => c.send(payload)));
  }
}

class EmailChannel implements NotificationChannel { ... }
```

*There is one notification type and one channel. This is 4x the code needed.*

### GOOD — simplest thing that works

```typescript
// First implementation — one function, does the job
async function sendWelcomeEmail(to: string, name: string) {
  await resend.emails.send({
    from: "hello@myapp.com",
    to,
    subject: "Welcome!",
    text: `Hi ${name}, welcome to MyApp.`,
  });
}
```

*When a second notification type is needed, extract shared logic then. Not before.*

---

## Red Flags — Stop and Simplify

These thoughts mean you're about to over-engineer:

| Thought | Reality |
|---------|---------|
| "What if we need X later?" | Build X when you need X. |
| "This should be a plugin" | You don't have plugins yet. |
| "Let me make this generic" | Generic code with one use case is just complex code. |
| "I'll add a config option for that" | Hard-code it. Extract when a second value is needed. |
| "This deserves its own class" | A function is fine until it isn't. |

---

## Quick Reference

| Stage | Trigger | Output |
|-------|---------|--------|
| Make it work | Always | Simplest direct implementation |
| Make it right | Stage 1 verified | Named constants, extracted 3x duplication, basic error handling |
| Make it flexible | Second concrete use case exists | Interfaces, config, abstraction |

---

## Common Mistakes

**Treating Stage 3 as the default** — most production code lives comfortably in Stage 2. Stage 3 is triggered by requirements, not taste.

**Skipping Stage 1 verification** — if you move to Stage 2 before the simple version works, you're refactoring broken code.

**"Future-proofing"** — the future almost never arrives in the form you predicted. The cost of wrong abstractions is higher than the cost of adding the right one later.
