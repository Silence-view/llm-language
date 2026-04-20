#!/usr/bin/env bash
# TaskCompleted hook for llm-language v4.1
#
# Purpose: When a task completes (via TaskUpdate status=completed), log the
#          pattern to ROSETTA Jarvis Patterns section for anticipation learning.
#
# Captures: task description, duration, tool uses, tokens spent.

set -euo pipefail

ROSETTA="${HOME}/.claude/ROSETTA.md"
[[ ! -f "$ROSETTA" ]] && exit 0

HOOK_INPUT=$(cat)

TASK_ID=$(echo "$HOOK_INPUT" | jq -r '.task_id // ""')
TASK_SUBJECT=$(echo "$HOOK_INPUT" | jq -r '.task.subject // ""')
STATUS=$(echo "$HOOK_INPUT" | jq -r '.task.status // ""')

# Only log completed tasks
if [[ "$STATUS" != "completed" ]]; then
    exit 0
fi

# Skip if empty
if [[ -z "$TASK_SUBJECT" ]]; then
    exit 0
fi

# Append to Jarvis Patterns table if section exists
if grep -q "^## Jarvis Patterns" "$ROSETTA"; then
    TODAY=$(date -u +"%Y-%m-%d")
    # Truncate subject to 60 chars for table width
    SHORT_SUBJECT=$(echo "$TASK_SUBJECT" | cut -c 1-60)
    ENTRY="| ${TODAY} | ${SHORT_SUBJECT} | — | — | task-completed |"
    echo "$ENTRY" >> "$ROSETTA"
fi

exit 0
