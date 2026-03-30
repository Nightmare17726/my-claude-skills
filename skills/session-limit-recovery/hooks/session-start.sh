#!/usr/bin/env bash
# SessionStart hook for session-limit-recovery
# Injects checkpoint into context so Claude auto-resumes without user input

CHECKPOINT="$HOME/.claude/recovery/checkpoint.md"

if [ -f "$CHECKPOINT" ] && grep -q "status: in_progress" "$CHECKPOINT"; then
  echo "╔══════════════════════════════════════════════════╗"
  echo "║         SESSION RECOVERY — AUTO-RESUMING         ║"
  echo "╚══════════════════════════════════════════════════╝"
  echo ""
  cat "$CHECKPOINT"
  echo ""
  echo "---"
  echo "INSTRUCTION TO CLAUDE: An in-progress task was found above."
  echo "Resume immediately from 'Current Position' without waiting for user input."
  echo "Announce: 'Resuming: <task name> — continuing from Step N: <description>'"
  echo "Then proceed with the next step."
fi
