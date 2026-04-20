#!/usr/bin/env bash
# PreCompact hook for llm-language v4.0
#
# Purpose: Snapshot active ROSETTA context to auto-memory BEFORE compaction,
#          so long optimization sessions don't lose state when Claude Code
#          compacts the conversation.
#
# Pattern: write-then-allow (exit 0). NEVER use `decision: "block"` — known
#          Claude Code bug where block CANCELS compaction rather than defers.
#          See: https://github.com/MemPalace/mempalace/issues/856
#
# Install: add to .claude/settings.json:
# {
#   "hooks": {
#     "PreCompact": [
#       {
#         "matcher": "*",
#         "hooks": [{
#           "type": "command",
#           "command": "${CLAUDE_PLUGIN_ROOT}/hooks/precompact-rosetta-snapshot.sh"
#         }]
#       }
#     ]
#   }
# }

set -euo pipefail

# Read hook input from stdin (JSON)
HOOK_INPUT=$(cat)

# Extract useful fields (trigger=manual|auto, custom_instructions)
TRIGGER=$(echo "$HOOK_INPUT" | jq -r '.trigger // "unknown"')
SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // "unknown"')

# Determine target auto-memory directory
# Fallback if not running inside a project: skip snapshot
if [[ -z "${CLAUDE_PROJECT_DIR:-}" ]]; then
    # Not in a project context, nothing to snapshot
    exit 0
fi

# Auto-memory directory for this project
MEMORY_DIR="${HOME}/.claude/projects"
# Derive <project> identifier from git repo if possible
if git -C "$CLAUDE_PROJECT_DIR" rev-parse --show-toplevel >/dev/null 2>&1; then
    PROJECT_ROOT=$(git -C "$CLAUDE_PROJECT_DIR" rev-parse --show-toplevel)
    PROJECT_SLUG=$(echo "$PROJECT_ROOT" | sed 's|/|-|g' | sed 's|^-||')
else
    PROJECT_SLUG=$(echo "$CLAUDE_PROJECT_DIR" | sed 's|/|-|g' | sed 's|^-||')
fi

TARGET_MEMORY="${MEMORY_DIR}/${PROJECT_SLUG}/memory"
mkdir -p "$TARGET_MEMORY"

# Timestamp
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SNAPSHOT_FILE="${TARGET_MEMORY}/rosetta-session-${SESSION_ID}.md"

# Read current ROSETTA.md if it exists
ROSETTA_PATH="${HOME}/.claude/ROSETTA.md"
if [[ -f "$ROSETTA_PATH" ]]; then
    # Write snapshot with frontmatter compatible with auto-memory type system
    cat > "$SNAPSHOT_FILE" <<EOF
---
name: rosetta-session-${SESSION_ID}
description: ROSETTA snapshot before compaction (trigger=${TRIGGER}, ts=${TS})
type: reference
---

# ROSETTA Session Snapshot

**Captured:** ${TS}
**Session:** ${SESSION_ID}
**Trigger:** ${TRIGGER}

This is a snapshot of the user's ROSETTA.md taken before compaction to preserve
session-specific context that would otherwise be lost.

---

$(cat "$ROSETTA_PATH")
EOF

    # Update MEMORY.md index (idempotent — only add if not already listed)
    MEMORY_INDEX="${TARGET_MEMORY}/MEMORY.md"
    if [[ ! -f "$MEMORY_INDEX" ]]; then
        cat > "$MEMORY_INDEX" <<EOF
# MEMORY Index

Auto-memory index for this project. Each entry points to a topic file with detailed content.

## Session Snapshots
EOF
    fi

    # Only add pointer if not already present
    POINTER="- [rosetta-session-${SESSION_ID}](rosetta-session-${SESSION_ID}.md) — ROSETTA snapshot at ${TS}"
    if ! grep -qF "rosetta-session-${SESSION_ID}" "$MEMORY_INDEX" 2>/dev/null; then
        # Append under Session Snapshots section
        if grep -q "## Session Snapshots" "$MEMORY_INDEX"; then
            # Add after the header
            awk -v p="$POINTER" '
                /^## Session Snapshots/ { print; print p; next }
                { print }
            ' "$MEMORY_INDEX" > "${MEMORY_INDEX}.tmp" && mv "${MEMORY_INDEX}.tmp" "$MEMORY_INDEX"
        else
            # Append section at the end
            printf '\n## Session Snapshots\n%s\n' "$POINTER" >> "$MEMORY_INDEX"
        fi
    fi
fi

# Write-then-allow: exit 0 to permit compaction to proceed
# NEVER emit {"decision":"block"} — it CANCELS rather than defers (known bug)
exit 0
