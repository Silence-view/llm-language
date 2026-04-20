#!/usr/bin/env bash
# Stop hook for llm-language v4.1
#
# Purpose: At end of each turn, consolidate the signal buffer into ROSETTA
#          passively. Runs WITHOUT explicit llm-language invocation — this is
#          what makes ROSETTA updates truly automatic.
#
# Cheap: only processes new signals since last update, uses jq for aggregation.

set -euo pipefail

BUFFER="${HOME}/.claude/.rosetta-signal-buffer.jsonl"
ROSETTA="${HOME}/.claude/ROSETTA.md"
LAST_CONSOLIDATED="${HOME}/.claude/.rosetta-last-consolidated.ts"

# Skip if no buffer or ROSETTA doesn't exist
if [[ ! -f "$BUFFER" || ! -f "$ROSETTA" ]]; then
    exit 0
fi

# Only consolidate at most once per 10 minutes (don't thrash on every turn)
NOW_TS=$(date -u +"%s")
if [[ -f "$LAST_CONSOLIDATED" ]]; then
    LAST_TS=$(cat "$LAST_CONSOLIDATED" 2>/dev/null || echo 0)
    SINCE=$((NOW_TS - LAST_TS))
    if [[ "$SINCE" -lt 600 ]]; then
        exit 0
    fi
fi

# Read buffer, aggregate signals
LANG_DOMINANT=$(jq -r '.lang' "$BUFFER" 2>/dev/null | sort | uniq -c | sort -rn | head -1 | awk '{print $2}')
VERBOSITY_DOMINANT=$(jq -r '.verbosity' "$BUFFER" 2>/dev/null | sort | uniq -c | sort -rn | head -1 | awk '{print $2}')
DOMAIN_TOP3=$(jq -r '.domain' "$BUFFER" 2>/dev/null | grep -v unknown | sort | uniq -c | sort -rn | head -3 | awk '{print $2}' | tr '\n' ',' | sed 's/,$//')
MAX_EFFORT_SIGNALS=$(jq -r '.triggers[]?' "$BUFFER" 2>/dev/null | grep -c "max-effort-signal" || echo 0)

# Append a passive-observation entry to ROSETTA's Evolution Log
# (idempotent — only add if not already captured in last hour)
TODAY=$(date -u +"%Y-%m-%d")
LAST_LINE=$(tail -5 "$ROSETTA" 2>/dev/null | grep -c "passive-observation.*${TODAY}" || echo 0)

if [[ "$LAST_LINE" -eq 0 ]]; then
    # Ensure Evolution Log section exists
    if ! grep -q "^## Evolution Log" "$ROSETTA"; then
        printf '\n## Evolution Log\n\n| Date | Change | Trigger |\n|---|---|---|\n' >> "$ROSETTA"
    fi

    # Append passive observation
    ENTRY="| ${TODAY} | passive-observation: lang=${LANG_DOMINANT}, verbosity=${VERBOSITY_DOMINANT}, top-domains=${DOMAIN_TOP3}, max-effort-signals=${MAX_EFFORT_SIGNALS} | Stop hook auto-update |"
    echo "$ENTRY" >> "$ROSETTA"
fi

# Mark consolidation timestamp
echo "$NOW_TS" > "$LAST_CONSOLIDATED"

# Don't clear the buffer — llm-language main skill does deep consolidation on explicit invocation

exit 0
