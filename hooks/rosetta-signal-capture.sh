#!/usr/bin/env bash
# UserPromptSubmit hook for llm-language v4.1
#
# Purpose: Detect user style signals from each prompt and capture them to
#          ROSETTA's passive update buffer. Runs on EVERY user message, so
#          ROSETTA learns even when llm-language main skill is not explicitly
#          invoked.
#
# Captures:
#   - Language preference (Italian / English / mixed)
#   - Verbosity signal (terse vs detailed prompts)
#   - Trigger phrases (massima precisione, ultrathink, etc.)
#   - Domain hints from keywords
#
# Non-blocking: uses a buffer file, main llm-language skill consolidates on next
#               invocation. Zero user-visible overhead.

set -uo pipefail

# Note: intentionally NOT using `set -e` — grep returns 1 on no matches, which is
# expected for this script and should not cause exit. All critical ops are guarded.

BUFFER="${HOME}/.claude/.rosetta-signal-buffer.jsonl"
mkdir -p "$(dirname "$BUFFER")"

# Read hook input
HOOK_INPUT=$(cat)
PROMPT=$(echo "$HOOK_INPUT" | jq -r '.prompt // .user_message // ""' 2>/dev/null)

# Skip if empty or jq failed
if [[ -z "${PROMPT:-}" ]]; then
    exit 0
fi

# Signal detection (lightweight — grep failures on no-match are expected)
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# 1. Language detection — count matches via grep -c (returns 0 on no match, not 1)
# Note: use `cat <<<` to avoid pipefail issues with grep returning 1
ITALIAN_WORDS=$(grep -ciE '\b(il|la|le|lo|gli|è|una|uno|che|per|con|dove|sono|hai|fai|metti|aggiungi|aggiorna|modifica|voglio|vorrei|massima|precisione)\b' <<< "$PROMPT" 2>/dev/null)
ENGLISH_WORDS=$(grep -ciE '\b(the|and|is|are|you|have|add|update|modify|want|would|maximum|precision|please|make)\b' <<< "$PROMPT" 2>/dev/null)
# Default to 0 if grep returned nothing parseable
ITALIAN_WORDS="${ITALIAN_WORDS:-0}"
ENGLISH_WORDS="${ENGLISH_WORDS:-0}"

if [[ "$ITALIAN_WORDS" -gt "$ENGLISH_WORDS" ]]; then
    LANG="it"
elif [[ "$ENGLISH_WORDS" -gt "$ITALIAN_WORDS" ]]; then
    LANG="en"
else
    LANG="mixed"
fi

# 2. Verbosity signal
CHAR_COUNT=${#PROMPT}
if [[ "$CHAR_COUNT" -lt 50 ]]; then
    VERBOSITY="terse"
elif [[ "$CHAR_COUNT" -lt 300 ]]; then
    VERBOSITY="balanced"
else
    VERBOSITY="detailed"
fi

# 3. Trigger phrase detection (guard exit codes)
TRIGGERS="[]"
if echo "$PROMPT" | grep -qiE "(massima precisione|maximum quality|ultrathink|massimo effort|effort max)" 2>/dev/null; then
    TRIGGERS='["max-effort-signal"]'
fi

# 4. Domain keyword hints (only first match; guard exit codes)
DOMAIN="unknown"
if echo "$PROMPT" | grep -qiE "(python|pandas|numpy|scipy)" 2>/dev/null; then DOMAIN="python-data"
elif echo "$PROMPT" | grep -qiE "(solana|anchor|rust|blockchain)" 2>/dev/null; then DOMAIN="solana"
elif echo "$PROMPT" | grep -qiE "(latex|paper|bibtex|citation)" 2>/dev/null; then DOMAIN="academic"
elif echo "$PROMPT" | grep -qiE "(react|typescript|node|javascript)" 2>/dev/null; then DOMAIN="web"
elif echo "$PROMPT" | grep -qiE "(statistic|regression|anova|hypothesis)" 2>/dev/null; then DOMAIN="stats"
fi

# Write to buffer (JSONL, one line per signal)
printf '{"ts":"%s","lang":"%s","verbosity":"%s","domain":"%s","triggers":%s,"char_count":%d}\n' \
    "$TS" "$LANG" "$VERBOSITY" "$DOMAIN" "$TRIGGERS" "$CHAR_COUNT" >> "$BUFFER"

# Cap buffer at 1000 lines (FIFO trim)
if [[ $(wc -l < "$BUFFER") -gt 1000 ]]; then
    tail -n 1000 "$BUFFER" > "${BUFFER}.tmp" && mv "${BUFFER}.tmp" "$BUFFER"
fi

# Non-blocking — always allow prompt through
exit 0
