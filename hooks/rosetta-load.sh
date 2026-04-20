#!/usr/bin/env bash
# SessionStart hook for llm-language v4.1
#
# Purpose: Auto-load ROSETTA.md at session start, check freshness, and emit
#          Jarvis awareness card if patterns exist.
#
# Runs on: SessionStart event (startup, resume, clear)
# Non-blocking: never fails; missing ROSETTA just logs a note
#
# Install: plugin-level hooks.json manifest auto-registers this

set -euo pipefail

ROSETTA="${HOME}/.claude/ROSETTA.md"

# Read hook input
HOOK_INPUT=$(cat)
TRIGGER=$(echo "$HOOK_INPUT" | jq -r '.trigger // "startup"')

# If ROSETTA doesn't exist, skip silently (bootstrap happens at first llm-language invocation)
if [[ ! -f "$ROSETTA" ]]; then
    exit 0
fi

# Check staleness (warn if > 30 days)
if [[ $(find "$ROSETTA" -mtime +30 -print 2>/dev/null) ]]; then
    echo "[llm-language] ROSETTA is stale (>30 days). Consider /llm-language:consolidate to refresh." >&2
fi

# Check size (warn if > 300 lines — consolidation target)
LINE_COUNT=$(wc -l < "$ROSETTA" | tr -d ' ')
if [[ "$LINE_COUNT" -gt 300 ]]; then
    echo "[llm-language] ROSETTA is ${LINE_COUNT} lines (>300 target). Run /llm-language:consolidate to compress via RMM." >&2
fi

# Jarvis awareness card (if Jarvis is enabled via ROSETTA flag)
# Extract jarvis patterns with confidence ≥60% and hit_count ≥2
if grep -q "jarvis_enabled: true" "$ROSETTA" 2>/dev/null; then
    # This is a best-effort extraction — actual pattern parsing happens in llm-language skill
    PATTERN_COUNT=$(grep -c "^| .* | .* | .* | 100% \|^| .* | .* | .* | [6-9][0-9]%" "$ROSETTA" 2>/dev/null || echo "0")
    if [[ "$PATTERN_COUNT" -gt 0 ]]; then
        echo "[llm-language] Jarvis has ${PATTERN_COUNT} high-confidence patterns. Invoke /llm-language:jarvis status for details." >&2
    fi
fi

# Exit 0 — hook completes, session proceeds normally
exit 0
