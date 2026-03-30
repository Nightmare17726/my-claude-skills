# my-claude-skills

A personal collection of reusable skills for [Claude Code](https://claude.ai/code) — installed in `~/.claude/skills/` and automatically applied during coding sessions.

---

## Install

**One skill:**
```bash
curl -fsSL https://raw.githubusercontent.com/Nightmare17726/my-claude-skills/main/install.sh | bash -s <skill-name>
```

**All skills:**
```bash
curl -fsSL https://raw.githubusercontent.com/Nightmare17726/my-claude-skills/main/install.sh | bash
```

The installer also auto-registers any required hooks into `~/.claude/settings.json`.

---

## Skills

| Skill | Description | Auto-triggers? | Hooks |
|-------|-------------|----------------|-------|
| [session-limit-recovery](./skills/session-limit-recovery/SKILL.md) | Checkpoints task state before hitting the session usage limit and **fully auto-resumes** in the next session without any user input | Yes — any multi-step or multi-file task | `SessionStart` |

---

## How Auto-Resume Works

1. Claude creates `~/.claude/recovery/checkpoint.md` at the start of any long task and updates it after every step.
2. When the session limit is hit, Claude finishes its current operation and halts cleanly.
3. When a new session opens, a `SessionStart` hook injects the checkpoint into context — Claude resumes **automatically**, no prompt needed.

---

## Adding a New Skill

1. Create `skills/<skill-name>/SKILL.md`
2. Optionally add `skills/<skill-name>/hooks/session-start.sh` for a SessionStart hook
3. Add the skill name to the `for skill in ...` list in `install.sh`
4. Add a row to the table above
5. Push

Skills follow the [agentskills.io specification](https://agentskills.io/specification) — a YAML frontmatter block (`name`, `description`) followed by Markdown content.
