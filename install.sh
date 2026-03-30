#!/usr/bin/env bash
# Install skills from Nightmare17726/my-claude-skills for Claude Code
# Usage:
#   Install one skill:  curl -fsSL https://raw.githubusercontent.com/Nightmare17726/my-claude-skills/main/install.sh | bash -s session-limit-recovery
#   Install all skills: curl -fsSL https://raw.githubusercontent.com/Nightmare17726/my-claude-skills/main/install.sh | bash

set -e

REPO="Nightmare17726/my-claude-skills"
RAW="https://raw.githubusercontent.com/$REPO/main"
SKILLS_DIR="$HOME/.claude/skills"
SETTINGS="$HOME/.claude/settings.json"

install_skill() {
  local skill="$1"
  local dest="$SKILLS_DIR/$skill"
  echo "Installing $skill..."
  mkdir -p "$dest"
  curl -fsSL "$RAW/skills/$skill/SKILL.md" -o "$dest/SKILL.md"
  echo "  -> $dest/SKILL.md"

  # Install hook script if present
  local hook_url="$RAW/skills/$skill/hooks/session-start.sh"
  if curl -fsSL --head "$hook_url" 2>/dev/null | grep -q "200"; then
    mkdir -p "$dest/hooks"
    curl -fsSL "$hook_url" -o "$dest/hooks/session-start.sh"
    chmod +x "$dest/hooks/session-start.sh"
    echo "  -> $dest/hooks/session-start.sh"
  fi
}

register_hooks() {
  echo "Registering SessionStart hook..."
  [ ! -f "$SETTINGS" ] && echo '{}' > "$SETTINGS"

  python3 - <<'PYEOF'
import json, os

settings_path = os.path.expanduser("~/.claude/settings.json")
hook_command = "bash ~/.claude/skills/session-limit-recovery/hooks/session-start.sh"

with open(settings_path) as f:
    s = json.load(f)

hooks = s.setdefault("hooks", {})
session_start = hooks.setdefault("SessionStart", [])

already = any(
    h.get("type") == "command" and h.get("command") == hook_command
    for entry in session_start
    for h in entry.get("hooks", [])
)

if not already:
    session_start.append({"hooks": [{"type": "command", "command": hook_command}]})
    with open(settings_path, "w") as f:
        json.dump(s, f, indent=2)
    print("  -> Hook registered")
else:
    print("  -> Hook already registered, skipping")
PYEOF
}

ALL_SKILLS=(
  session-limit-recovery
  token-budget-guardian
  secure-by-default
  design-system-first
  progressive-complexity
)

if [ -n "$1" ]; then
  install_skill "$1"
else
  for skill in "${ALL_SKILLS[@]}"; do
    install_skill "$skill"
  done
fi

register_hooks

echo ""
echo "Done. Skills installed to: $SKILLS_DIR"
echo "Open a new Claude Code session to activate."
