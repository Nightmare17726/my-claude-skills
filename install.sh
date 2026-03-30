#!/usr/bin/env bash
# Install a skill from Nightmare17726/my-claude-skills for Claude Code
# Usage:
#   Install one skill:  curl -fsSL https://raw.githubusercontent.com/Nightmare17726/my-claude-skills/main/install.sh | bash -s session-limit-recovery
#   Install all skills: curl -fsSL https://raw.githubusercontent.com/Nightmare17726/my-claude-skills/main/install.sh | bash

set -e

REPO="Nightmare17726/my-claude-skills"
RAW="https://raw.githubusercontent.com/$REPO/main"
SKILLS_DIR="$HOME/.claude/skills"

# If a skill name is passed as argument, install just that one.
# Otherwise, install all skills listed in skills/
install_skill() {
  local skill="$1"
  local dest="$SKILLS_DIR/$skill"
  echo "Installing $skill..."
  mkdir -p "$dest"
  curl -fsSL "$RAW/skills/$skill/SKILL.md" -o "$dest/SKILL.md"
  echo "  -> $dest/SKILL.md"
}

if [ -n "$1" ]; then
  install_skill "$1"
else
  # Install all known skills
  for skill in session-limit-recovery; do
    install_skill "$skill"
  done
fi

echo ""
echo "Done. Skills installed to: $SKILLS_DIR"
