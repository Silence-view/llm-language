# llm-language hooks

Claude Code hooks shipped with the llm-language plugin.

## Available hooks

### `precompact-rosetta-snapshot.sh` — PreCompact

Snapshots the user's active `~/.claude/ROSETTA.md` to project auto-memory before Claude Code compacts the conversation. Uses the **write-then-allow** pattern (exit 0) — NEVER blocks compaction.

**Why:** Long optimization sessions can hit compaction, which loses session-specific context. This hook ensures ROSETTA state is preserved in auto-memory.

**Bug avoided:** Claude Code's `decision: "block"` on PreCompact cancels rather than defers (known bug, issue #856). We use exit 0 instead.

## Installation

Add to your project's `.claude/settings.json`:

```json
{
  "hooks": {
    "PreCompact": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/precompact-rosetta-snapshot.sh"
          }
        ]
      }
    ]
  }
}
```

Or use user-level `~/.claude/settings.json` for cross-project installation.

## Dependencies

- `bash` (macOS/Linux shipped)
- `jq` (install via `brew install jq` or `apt install jq`)
- `git` (optional — used to derive project slug; falls back to path-based slug)

## What gets written

- `~/.claude/projects/<project>/memory/rosetta-session-<id>.md` — full ROSETTA snapshot
- Updates `~/.claude/projects/<project>/memory/MEMORY.md` — adds pointer to snapshot

## Verification

After installation, trigger a manual compaction with `/compact` in a long session. Check:

```bash
ls -la ~/.claude/projects/<your-project-slug>/memory/rosetta-session-*.md
```

You should see a snapshot file with frontmatter `type: reference`.
