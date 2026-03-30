---
name: session-limit-recovery
description: Use automatically for any task involving code changes, multi-step implementation, refactoring, debugging across multiple files, or anything that could span more than a few minutes. Also use when resuming after a session limit reset or when a checkpoint file exists.
---

# Session Limit Recovery

## Overview

Claude's usage limit resets on a rolling window (typically every 5 hours for Max/Pro). When the limit is hit mid-task, progress is lost without checkpointing. This skill saves full task state before halting and auto-resumes on the next session.

**Core principle:** Checkpoint early, checkpoint often. Never lose work to a limit reset.

**This skill is ALWAYS-ON.** Do not wait to be asked. Automatically apply it to:
- Any task touching more than one file
- Any task with more than ~3 steps
- Any debugging, refactoring, or implementation session
- Any new session where `~/.claude/recovery/checkpoint.md` exists

---

## When to Use

- **Always** — for any implementation, debugging, or multi-step task (do not wait to be asked)
- Explicitly asked to "continue where you left off" or "resume"
- A checkpoint file exists at `~/.claude/recovery/checkpoint.md`
- Approaching or hitting the session usage limit

---

## The Three Phases

### Phase 1: Initialize Checkpoint (start of long task)

Before beginning work, create `~/.claude/recovery/checkpoint.md`:

```markdown
# Session Recovery Checkpoint
created: <ISO timestamp>
task: <one-line description of the overall goal>
status: in_progress

## Current Position
Step <N> of <total>: <what you are about to do next>

## Completed Steps
(none yet)

## Remaining Steps
- [ ] Step 1: <description>
- [ ] Step 2: <description>
...

## Key Context
<Anything that won't be obvious from reading the code:
 - which approach was chosen and why
 - decisions made along the way
 - known blockers or caveats>

## Files Modified
(none yet)

## Resume Command
To continue: open a new Claude Code session and say "resume from checkpoint"
```

**Update this file after each completed step** — move items from Remaining to Completed and update Current Position.

---

### Phase 2: Graceful Halt (limit is hit)

When Claude Code shows a usage limit message, or you detect you're near the limit:

1. **Finish the current atomic operation** (don't stop mid-function or mid-file)
2. **Update the checkpoint** with current state — remove the "Resume Command" line and update `status: in_progress`
3. **Report to user:**

```
Session limit reached. Checkpoint saved at ~/.claude/recovery/checkpoint.md

Completed this session:
- [x] Step 1: ...
- [x] Step 2: ...

Remaining:
- [ ] Step 3: ...
- [ ] Step 4: ...

Your limit resets at approximately <time shown by Claude Code>.
The next session will resume automatically — no input needed.
```

4. **Stop working.** Do not attempt further steps.

---

### Phase 3: Auto-Resume (new session — fully automatic)

**This is handled by a SessionStart hook.** No user input is required.

When a new session starts, the hook at `~/.claude/skills/session-limit-recovery/hooks/session-start.sh` runs automatically. If `~/.claude/recovery/checkpoint.md` exists with `status: in_progress`, it injects the checkpoint into the session context with a resume instruction.

Claude must:

1. Announce: "Resuming: <task name> — continuing from Step N: <description>"
2. Proceed immediately with the next step — **do not ask for confirmation**
3. Continue until all remaining steps are done or the limit is hit again

When the full task is complete, update the checkpoint:

```bash
sed -i '' 's/status: in_progress/status: completed/' ~/.claude/recovery/checkpoint.md
```

---

## Hook Setup (required for auto-resume)

The SessionStart hook must be registered in `~/.claude/settings.json`:

```json
"hooks": {
  "SessionStart": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "bash ~/.claude/skills/session-limit-recovery/hooks/session-start.sh"
        }
      ]
    }
  ]
}
```

The `install.sh` script does this automatically.

---

## Checkpoint Update Pattern

After every completed step, run this mental checklist:

```
1. Move step from Remaining to Completed
2. Update "Current Position" to the NEXT step
3. Append any new files modified
4. Note any decisions made (Key Context)
```

Keep the file current — a stale checkpoint is worse than none.

---

## Quick Reference

| Situation | Action |
|-----------|--------|
| Starting long task | Create checkpoint immediately |
| Step completed | Update checkpoint (move to Completed) |
| Limit warning shown | Finish current operation, update checkpoint, halt |
| New session with checkpoint | Auto-detect, announce, confirm, resume |
| Task fully done | Mark checkpoint `status: completed` |

---

## Installation on Other Systems

Copy this skill directory to any machine:

```bash
# On source machine
cp -r ~/.claude/skills/session-limit-recovery/ /tmp/

# On target machine
mkdir -p ~/.claude/skills/
cp -r /tmp/session-limit-recovery/ ~/.claude/skills/
```

Or share just the SKILL.md — it's self-contained.

---

## Common Mistakes

**Not checkpointing frequently enough** — update after every step, not just at the end.

**Stopping mid-file** — always finish the current atomic unit before halting. A half-written function is harder to resume than a clean stopping point.

**Forgetting Key Context** — capture WHY decisions were made, not just WHAT. The next session has no memory of the current conversation.

**Resuming without reading the checkpoint** — always read the full checkpoint before continuing. Don't assume you remember the state.
