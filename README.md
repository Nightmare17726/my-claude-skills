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
| [session-limit-recovery](./skills/session-limit-recovery/SKILL.md) | Checkpoints task state before hitting the session usage limit and **fully auto-resumes** the next session without user input | Yes — any multi-step or multi-file task | `SessionStart` |
| [token-budget-guardian](./skills/token-budget-guardian/SKILL.md) | Enforces token-efficient patterns on every task: batch reads, grep before cat, parallel tool calls, no re-reads | Yes — every task | — |
| [secure-by-default](./skills/secure-by-default/SKILL.md) | Runs an OWASP-aligned security checklist before any feature is marked complete: input validation, injection prevention, auth, secrets, XSS, CSRF, data exposure | Yes — any task touching user input, APIs, auth, or data storage | — |
| [design-system-first](./skills/design-system-first/SKILL.md) | Establishes a design tokens file (colors, spacing, typography, shadows) before writing any frontend component, ensuring visual consistency from day one | Yes — any frontend or UI task | — |
| [progressive-complexity](./skills/progressive-complexity/SKILL.md) | Enforces Make It Work → Make It Right → Make It Flexible — prevents over-engineered first implementations | Yes — every implementation task | — |

---

## How Auto-Resume Works

1. Claude creates `~/.claude/recovery/checkpoint.md` at the start of any long task and updates it after every step.
2. When the session limit is hit, Claude finishes its current operation and halts cleanly.
3. When a new session opens, a `SessionStart` hook injects the checkpoint into context — Claude resumes **automatically**, no prompt needed.

---

## Adding a New Skill

1. Create `skills/<skill-name>/SKILL.md`
2. Optionally add `skills/<skill-name>/hooks/session-start.sh` for a SessionStart hook
3. Add the skill name to `ALL_SKILLS` in `install.sh`
4. Add a row to the table above
5. Push

Skills follow the [agentskills.io specification](https://agentskills.io/specification) — a YAML frontmatter block (`name`, `description`) followed by Markdown content.
