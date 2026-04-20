# Opus 4.7 Migration Guide — llm-language v4.0

**Target audience:** llm-language users upgrading from v3.x (Opus 4.6) to v4.0 (Opus 4.7).

**Release date:** Claude Opus 4.7 launched April 16, 2026. llm-language v4.0 released April 20, 2026.

---

## 1. Breaking Changes (Opus 4.7)

### 1.1 Sampling parameters removed
`temperature`, `top_p`, `top_k` return **400 error** on Opus 4.7. Omit them entirely.

```python
# v3.x (Opus 4.6) — WORKED
response = client.messages.create(
    model="claude-opus-4-6",
    temperature=0,
    top_p=0.95,
    ...
)

# v4.0 (Opus 4.7) — WILL 400
# Migration: remove these params, use `effort` for control
response = client.messages.create(
    model="claude-opus-4-7",
    output_config={"effort": "xhigh"},  # replaces temperature/top_p
    ...
)
```

### 1.2 Manual thinking budget removed
`thinking.type: "enabled"` with `budget_tokens` returns **400 error** on Opus 4.7. Use adaptive thinking.

```python
# v3.x — WORKED
thinking = {"type": "enabled", "budget_tokens": 32000}

# v4.0 — 400 error on Opus 4.7
# Migration: switch to adaptive mode
thinking = {"type": "adaptive"}
output_config = {"effort": "xhigh"}  # guides thinking depth
```

### 1.3 Thinking content omitted by default
On Opus 4.7, `thinking.display` defaults to `"omitted"`. To see summarized reasoning:

```python
thinking = {
    "type": "adaptive",
    "display": "summarized"  # opt back in
}
```

### 1.4 New tokenizer
Opus 4.7 uses a new tokenizer. Same text = 1.0–1.35× more tokens than Opus 4.6. Migration:

- Bump `max_tokens` to give headroom (+35% safety margin)
- Re-tune compaction triggers
- Budget estimates should scale by 1.2× on average

---

## 2. Complexity → Effort Mapping (v4.0)

| Complexity | Effort (new) | Max Tokens | Task Budget | Notes |
|---|---|---|---|---|
| simple | `medium` | 4k | omit | Adaptive may skip thinking |
| moderate | `high` | 16k | omit | Default, always thinks |
| complex | `xhigh` | 64k | 200k | **Anthropic-recommended for coding/agentic** |
| critical | `max` | 128k | 400-800k | Frontier problems only; can overthink |

**Important:** `max` effort on Opus 4.7 adds significant cost for small gains. Use `xhigh` unless evals show measurable headroom at max.

---

## 3. Prompt Rewriting Rules (v4.0 Producer enforced)

Opus 4.7 follows instructions more literally than 4.6. These transforms prevent quality regressions:

### 3.1 De-duplicate
State each directive exactly ONCE. 4.7 doesn't need emphasis.

```xml
<!-- v3.x -->
<constraints>
  The code MUST be secure. VERY IMPORTANT: secure code!
  Remember security is critical. Never write insecure code.
</constraints>

<!-- v4.0 -->
<constraints>
  Use parameterized queries; reject unsanitized input at API boundary.
</constraints>
```

### 3.2 Positive framing
Rewrite negations to affirmatives where semantically equivalent.

```xml
<!-- v3.x -->
<constraints>Don't use any global state. Don't modify arguments.</constraints>

<!-- v4.0 -->
<constraints>Use pure functions with immutable inputs.</constraints>
```

### 3.3 Strip emphasis markers
Remove "VERY IMPORTANT", "MUST", all-caps repetitions. Opus 4.7 obeys without them.

### 3.4 Concise role
One sentence. Verbose personas degrade 4.7 output.

```xml
<!-- v3.x -->
<role>
  You are a senior distributed-systems architect with 15 years of experience
  in event-driven architecture, microservices, Kafka, Kubernetes, and cloud-native
  design patterns. You have deep knowledge of CAP theorem, consistency models, ...
</role>

<!-- v4.0 -->
<role>Senior distributed-systems architect.</role>
```

### 3.5 Explicit parallelism
Opus 4.7 spawns fewer subagents by default. State parallelism explicitly:

```xml
<task>
  <parallelization-hint>
    Execute sub-tasks 1-3 in parallel via separate Agent dispatches with
    subagent_type=general-purpose. Wait for all three before proceeding to sub-task 4.
  </parallelization-hint>
</task>
```

### 3.6 No manual CoT trigger
Remove "let's think step by step" — adaptive thinking handles CoT automatically.

### 3.7 Fully-qualified skills
Use `plugin:skill-name`, not bare `skill-name`.

```xml
<!-- v3.x -->
<skill name="test-driven-development">...</skill>

<!-- v4.0 -->
<skill name="superpowers:test-driven-development">...</skill>
```

### 3.8 MRCR guard for >100k context
Opus 4.7 has measured MRCR (Multi-Request Context Recall) regression. Inject:

```xml
<long-context-guard>
  Before citing any quote or file content, verify by searching the original
  context — do not rely solely on recalled memory.
</long-context-guard>
```

### 3.9 Output format explicit
Opus 4.7 calibrates response length to perceived complexity. Specify if length matters.

---

## 4. Memory System Migration

### 4.1 Keep ROSETTA.md in place
`~/.claude/ROSETTA.md` stays as the user-level meta-prompt. DO NOT migrate to auto-memory.

**Rationale:**
- ROSETTA is user-authored, cross-machine portable, version-controllable
- Auto-memory is Claude-authored, per-repo, machine-local

### 4.2 Add auto-memory integration
llm-language v4.0 reads `~/.claude/projects/<project>/memory/MEMORY.md` alongside ROSETTA.

After each invocation, Phase 6c writes typed memories to project auto-memory:
- `type: user` — user preferences specific to this project
- `type: feedback` — corrections received during execution
- `type: project` — architectural decisions, invariants
- `type: reference` — external systems referenced

### 4.3 PreCompact hook
Install the provided PreCompact hook (see `hooks/precompact-rosetta-snapshot.sh`):
- Snapshots current ROSETTA context to auto-memory BEFORE compaction
- Uses write-then-allow pattern (exit 0), NEVER `decision: "block"` (known Claude Code bug)

---

## 5. Scoring Rubric Changes

| Dimension | v3.x Weight | v4.0 Weight | Change |
|---|---|---|---|
| Intent Preservation | 0.18 | 0.16 | −0.02 |
| Precision | 0.16 | 0.14 | −0.02 |
| Completeness | 0.16 | 0.14 | −0.02 |
| Structure | 0.12 | 0.10 | −0.02 |
| Opus Optimization | 0.08 | 0.10 | +0.02 (now 4.7-specific) |
| Scientific Grounding | 0.08 | 0.07 | −0.01 |
| User-Fit Alignment | 0.10 | 0.08 | −0.02 |
| Codebase Grounding | 0.12 | 0.10 | −0.02 |
| **Effort Calibration (NEW)** | — | **0.06** | +0.06 |
| **Memory Integration (NEW)** | — | **0.05** | +0.05 |
| **Total** | 1.00 | 1.00 | ✓ |

**Pass threshold:** 9.2 → **9.3**

---

## 6. Backward Compatibility

llm-language v4.0 still supports Opus 4.6 and Sonnet 4.6 targets:

- If target is `claude-opus-4-6`: uses legacy `thinking="ultrathink"` attribute
- If target is `claude-sonnet-4-6`: uses legacy attributes with Sonnet-specific effort recommendations (defaults to `medium`)
- The Producer detects the target model from user request or ROSETTA preference

**To force legacy mode:** add to ROSETTA.md:
```markdown
## User Profile
- Preferred target: claude-opus-4-6
```

---

## 7. Migration Checklist

- [ ] Update `plugin.json` version to 4.0.0
- [ ] Update `marketplace.json` to reference v4.0.0
- [ ] Re-install plugin: `claude plugins reinstall llm-language`
- [ ] Verify ROSETTA.md has new sections (thought_templates, strategy_bandit, failure_taxonomy)
  - If missing, re-run bootstrap: delete ROSETTA.md, invoke `/llm-language` (will recreate)
- [ ] Install PreCompact hook: add to `.claude/settings.json`
- [ ] Update any custom prompts that used `temperature`/`top_p`/`top_k`/`budget_tokens`
- [ ] Retest on representative task suite — verify threshold 9.3 is reachable
- [ ] Monitor token usage — expect +20% average due to new tokenizer + higher effort defaults

---

## 8. Common Migration Issues

### Issue: "400 error on Opus 4.7"
**Cause:** Deprecated params in generated XML. Check for `temperature`, `top_p`, `top_k`, `budget_tokens`.
**Fix:** Re-run Producer — v4.0 strips these automatically.

### Issue: "Output is too terse" on Opus 4.7
**Cause:** Response length calibrates to perceived complexity. Model perceives task as simpler than intended.
**Fix:** Specify length in `<output-specification><format>` explicitly.

### Issue: "No parallel subagents spawned"
**Cause:** Opus 4.7 spawns fewer by default.
**Fix:** Add explicit `<parallelization-hint>` directive.

### Issue: "Hallucinated quotes in long-context task"
**Cause:** Opus 4.7 MRCR regression on >100k contexts.
**Fix:** Producer auto-adds `<long-context-guard>` for >100k — verify it's present.

### Issue: "Thinking content empty"
**Cause:** `display` defaults to "omitted" on Opus 4.7.
**Fix:** Set `display: "summarized"` in thinking config if you need visible reasoning.

### Issue: "Ultrathink downgrade bug"
**Cause:** Known Claude Code bug: ultrathink keyword sets effort to "high" even when session is at xhigh/max.
**Fix:** Use `/effort max` explicitly instead of typing "ultrathink".

---

## References

- [Anthropic: Introducing Claude Opus 4.7](https://www.anthropic.com/news/claude-opus-4-7)
- [What's new in Claude Opus 4.7](https://platform.claude.com/docs/en/about-claude/models/whats-new-claude-4-7)
- [Effort Parameter docs](https://platform.claude.com/docs/en/build-with-claude/effort)
- [Adaptive Thinking docs](https://platform.claude.com/docs/en/build-with-claude/adaptive-thinking)
- [Task Budgets docs](https://platform.claude.com/docs/en/build-with-claude/task-budgets)
- [Auto-Memory docs](https://code.claude.com/docs/en/memory)
- [Memory Tool docs](https://platform.claude.com/docs/en/agents-and-tools/tool-use/memory-tool)
- [Migrating to Claude Opus 4.7](https://platform.claude.com/docs/en/about-claude/models/migration-guide#migrating-to-claude-opus-4-7)
