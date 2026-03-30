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

  # Install any hook scripts bundled with the skill
  if curl -fsSL --head "$RAW/skills/$skill/hooks/session-start.sh" 2>/dev/null | grep -q "200"; then
    mkdir -p "$dest/hooks"
    curl -fsSL "$RAW/skills/$skill/hooks/session-start.sh" -o "$dest/hooks/session-start.sh"
    chmod +x "$dest/hooks/session-start.sh"
    echo "  -> $dest/hooks/session-start.sh"
  fi

  echo "  -> $dest/SKILL.md"
}

register_hooks() {
  echo "Registering SessionStart hook in $SETTINGS..."

  # Create settings.json if it doesn't exist
  if [ ! -f "$SETTINGS" ]; then
    echo '{}' > "$SETTINGS"
  fi

  # Use python3 to safely merge the hook into existing settings
  python3 - <<'PYEOF'
import json, os, sys

settings_path = os.path.expanduser("~/.claude/settings.json")
hook_command = "bash ~/.claude/skills/session-limit-recovery/hooks/session-start.sh"

with open(settings_path, "r") as f:
    s = json.load(f)

hooks = s.setdefault("hooks", {})
session_start = hooks.setdefault("SessionStart", [])

# Check if already registered
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

if [ -n "$1" ]; then
  install_skill "$1"
else
  for skill in session-limit-recovery; do
    install_skill "$skill"
  done
fi

register_hooks

echo ""
echo "Done. Skills installed to: $SKILLS_DIR"
echo "Open a new Claude Code session to activate."
