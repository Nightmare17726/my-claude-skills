---
name: token-budget-guardian
description: Use automatically before every task. Enforces token-efficient patterns to minimize credit usage: batch reads, grep before cat, plan before execute, parallel tool calls, never re-read files already in context.
---

# Token Budget Guardian

## Overview

Every redundant file read, sequential tool call, and unplanned execution burns credits. This skill enforces habits that consistently cut token usage by 40–70% on typical tasks.

**This skill is ALWAYS-ON.** Apply it to every task without being asked.

---

## The Rules (non-negotiable)

### 1. Plan before touching anything

Before any tool call, write a 3-line mental plan:
- What files are involved?
- What is the minimal set of reads needed?
- What can run in parallel?

Never open a file speculatively.

### 2. Grep/Glob before Read

Never `Read` a file to find something. Find it first, then read only what you need.

```
# BAD — reads entire file to find one function
Read: src/auth/middleware.ts

# GOOD — locate it first, read only that section
Grep: "function verifyToken" → line 47
Read: src/auth/middleware.ts (offset: 44, limit: 30)
```

Use `Grep` with `output_mode: "content"` and tight `head_limit` values. Use `offset` + `limit` on `Read` when you know the location.

### 3. Batch all independent operations in one message

Every message that contains tool calls is a round-trip. Collapse independent operations.

```
# BAD — 3 round-trips
Read: package.json
Read: tsconfig.json
Read: src/index.ts

# GOOD — 1 round-trip
Read: package.json  ┐
Read: tsconfig.json ├─ parallel
Read: src/index.ts  ┘
```

If tool calls don't depend on each other's output, they go in the same message.

### 4. Never re-read a file already in context

Track what has been read in the current session. If a file was read earlier in the conversation, use that content — do not read it again.

### 5. Prefer Edit over Write

`Edit` sends only the diff. `Write` sends the full file. Use `Write` only for new files or complete rewrites.

### 6. Use dedicated tools, not Bash

| Task | Use | Not |
|------|-----|-----|
| Find files | `Glob` | `find` / `ls` |
| Search content | `Grep` | `grep` / `rg` in Bash |
| Read files | `Read` | `cat` / `head` / `tail` |
| Edit files | `Edit` | `sed` / `awk` |

Bash spawns a subshell for every call. Dedicated tools are direct.

### 7. Scope Grep tightly

```
# BAD — searches entire repo
Grep: pattern="useState"

# GOOD — scoped to relevant directory and type
Grep: pattern="useState", path="src/components", type="tsx", head_limit=20
```

### 8. Read with limits

When you only need a section of a file:
```
Read: file_path, offset=100, limit=50   # lines 100-150 only
```

---

## Pre-Task Checklist

Before starting, answer:

1. Which files do I **know** I need? → batch-read them now
2. Which files do I **think** I might need? → grep for the specific thing first
3. Which operations have no dependencies? → run them in parallel
4. Have I read any of these files earlier in this session? → use that context, don't re-read

---

## Quick Reference

| Habit | Saves |
|-------|-------|
| Batch parallel reads | 1 round-trip per file → 1 total |
| Grep before Read | Full file read → targeted section |
| Edit vs Write | Full file resend → diff only |
| Scoped Grep | Whole-repo scan → targeted result |
| No re-reads | Duplicate tokens → zero |
| Plan first | Dead-end exploration → direct path |

---

## Common Mistakes

**Reading files to explore** — use Glob + Grep to explore, Read only to implement.

**Sequential tool calls that could be parallel** — if you catch yourself writing one Read after another with no dependency between them, merge them into one message.

**Forgetting `offset`/`limit`** — for files over 200 lines where you only need a section, always bound your reads.
