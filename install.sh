#!/usr/bin/env bash
# Install session-limit-recovery skill for Claude Code
# Usage: curl -fsSL https://raw.githubusercontent.com/Nightmare17726/session-limit-recovery/main/install.sh | bash

set -e

REPO="Nightmare17726/session-limit-recovery"
SKILL_DIR="$HOME/.claude/skills/session-limit-recovery"
RAW="https://raw.githubusercontent.com/$REPO/main"

echo "Installing session-limit-recovery skill..."

mkdir -p "$SKILL_DIR"

curl -fsSL "$RAW/skills/session-limit-recovery/SKILL.md" -o "$SKILL_DIR/SKILL.md"

echo "Done. Skill installed to: $SKILL_DIR"
echo ""
echo "Usage:"
echo "  - Claude will apply it automatically to any multi-step task"
echo "  - To resume after a limit reset: start a new session and say 'resume from checkpoint'"
echo "  - Checkpoints are saved to: ~/.claude/recovery/checkpoint.md"
