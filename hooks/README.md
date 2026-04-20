# llm-language hooks

Claude Code hooks shipped with the llm-language plugin. v4.1 auto-arms all hooks via the plugin-level `hooks.json` manifest — no manual `.claude/settings.json` editing required.

## Shipped hooks

### `precompact-rosetta-snapshot.sh` — PreCompact

Snapshots `~/.claude/ROSETTA.md` to project auto-memory before Claude Code compacts the conversation. Uses **write-then-allow** pattern (exit 0) — NEVER blocks.

### `rosetta-load.sh` — SessionStart (v4.1 NEW)

Loads ROSETTA at session start, checks freshness (>30 days = warning), checks size (>300 lines = suggest consolidation), emits Jarvis awareness cards if patterns exist.

### `rosetta-signal-capture.sh` — UserPromptSubmit (v4.1 NEW)

Captures user style signals from EVERY prompt:
- Language (Italian / English / mixed)
- Verbosity (terse / balanced / detailed)
- Domain (python-data / solana / academic / web / stats)
- Trigger phrases ("massima precisione", "ultrathink", etc.)

Writes to `~/.claude/.rosetta-signal-buffer.jsonl` (capped 1000 lines FIFO).

### `rosetta-session-summary.sh` — Stop (v4.1 NEW)

At end of each turn, aggregates the signal buffer and appends a passive-observation entry to ROSETTA's Evolution Log. Throttled to max 1 update per 10 minutes (avoids thrashing).

**This is what makes ROSETTA updates truly automatic on EVERY session, not just when `/llm-language` is explicitly invoked.**

### `rosetta-task-pattern.sh` — TaskCompleted (v4.1 NEW)

When a task completes (TaskUpdate → status: completed), appends an entry to ROSETTA's Jarvis Patterns table for anticipation learning.

## Auto-installation

All hooks auto-arm via the `hooks.json` manifest at plugin install. No manual configuration needed.

**To verify hooks are active:**
```bash
# In Claude Code:
/memory             # should show plugin hooks listed
```

**To disable a specific hook:**
Add to your `~/.claude/settings.json`:
```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "llm-language",
        "disabled": true
      }
    ]
  }
}
```

## Dependencies

All hooks use:
- `bash` (macOS/Linux shipped)
- `jq` (`brew install jq` or `apt install jq`)
- Standard POSIX tools (`grep`, `awk`, `find`, `date`)

`rosetta-task-pattern.sh` also requires Claude Code v2.1.100+ for the `TaskCompleted` hook event.

## File layout after install

```
~/.claude/
├── ROSETTA.md                          # user-level cross-project memory
├── .rosetta-signal-buffer.jsonl        # ephemeral signal capture (capped 1000 lines)
├── .rosetta-last-consolidated.ts       # throttle timestamp
└── projects/<project>/memory/
    ├── MEMORY.md                       # project-level index
    ├── rosetta-session-<id>.md         # PreCompact snapshots
    └── skill-refinement-audit.md       # Phase 7 audit trail
```

## Safety

- `precompact-rosetta-snapshot.sh`: exit 0 always (never blocks compaction)
- `rosetta-signal-capture.sh`: exit 0 always (never blocks prompts)
- `rosetta-session-summary.sh`: exit 0 always, self-throttling
- `rosetta-task-pattern.sh`: exit 0 always
- `rosetta-load.sh`: emits warnings to stderr, never blocks startup

Every hook is non-blocking by design — a hook failure never prevents Claude Code from proceeding.

## Verification

Test each hook manually:

```bash
# SessionStart
echo '{"trigger":"startup"}' | ~/.claude/plugins/marketplaces/llm-language/hooks/rosetta-load.sh

# UserPromptSubmit
echo '{"prompt":"aggiungi max precisione al codice"}' | ~/.claude/plugins/marketplaces/llm-language/hooks/rosetta-signal-capture.sh

# Verify signal was captured
tail -1 ~/.claude/.rosetta-signal-buffer.jsonl
```

## Uninstallation

To disable all llm-language hooks:
```bash
claude plugins disable llm-language
```

Or selectively:
```json
# ~/.claude/settings.json
{
  "hooks": {
    "UserPromptSubmit": [{"matcher": "llm-language", "disabled": true}],
    "Stop": [{"matcher": "llm-language", "disabled": true}]
  }
}
```
