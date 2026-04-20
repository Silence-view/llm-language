---
name: refine-skills
version: "1.0"
user-invocable: true
effort: xhigh
description: >
  Deep audit and refinement of third-party skills in the user's Claude Code
  ecosystem. Scores each skill on 10 quality dimensions, proposes non-destructive
  fixes (deprecated params, emphasis markers, missing frontmatter), applies safe
  fixes automatically, and reports risky changes for user approval. Scoped to
  user-owned skills ONLY (never modifies marketplace plugins or Claude Code
  built-ins). Use when: "/llm-language:refine-skills", "audit my skills",
  "fix my skills", "improve skill quality", "check skills against Opus 4.7".
---

# llm-language:refine-skills — Skill Auditor & Refiner

## Overview

A meta-skill that applies llm-language's self-refine methodology at the skill level. Scans user-owned skills, scores them on 10 quality dimensions (see `references/skill-quality-rubric.md`), and applies non-destructive fixes (catalog in `references/skill-fixer-patterns.md`).

**Core pattern:** Generate → Critique → Refine, but for skills instead of prompts.

**Complements** the Phase 7 light-touch auto-audit in the main llm-language pipeline. Phase 7 detects candidates during any `/llm-language` invocation; this skill runs the full deep audit on demand.

## When to Use

Explicitly invoke via `/llm-language:refine-skills` when:
- You want a full audit of all your personal skills
- You've been using skills designed for Opus 4.6 and want Opus 4.7 migration
- Phase 7 auto-audit flagged multiple refinement candidates
- You're adopting a new skill pattern (e.g., effort parameter, adaptive thinking) and want to backport

Optional arguments:
- `/llm-language:refine-skills` — audit all user-owned skills
- `/llm-language:refine-skills <skill-name>` — audit a specific skill
- `/llm-language:refine-skills --scope=user` — only user-level
- `/llm-language:refine-skills --scope=project` — only project-level
- `/llm-language:refine-skills rollback <skill-name>` — restore from backup

## Safety Guarantees

1. **Scoped to user-owned skills** — never touches marketplace-owned plugins or Claude Code built-ins
2. **Never modifies llm-language itself** — recursive self-modification loop is blocked
3. **Backup before every auto-fix** — `.backup-<timestamp>.md` sibling file, kept 30 days
4. **Audit trail** — every fix logged to `~/.claude/projects/<project>/memory/skill-refinement-audit.md`
5. **Dry-run mode** — `--dry-run` flag shows what WOULD change without writing
6. **Approval gate** — risky fixes (restructure, rewrite) require explicit user approval
7. **Git-awareness** — if skill is in a git repo with uncommitted changes, prompts to stash first

## Pipeline

### Phase 1: Discovery

1. Glob user-owned skills:
   - `~/.claude/skills/*/SKILL.md` (user-level)
   - `./.claude/skills/*/SKILL.md` (current project)
   - `./packages/**/.claude/skills/*/SKILL.md` (monorepo)
2. Exclude:
   - `~/.claude/plugins/marketplaces/**` unless repo is owned by user (detect via git remote)
   - `~/.claude/plugins/cache/**` (always)
   - llm-language's own skills
   - Claude Code bundled skills
3. Build audit targets list with scope classification

### Phase 2: Quick Scan (parallel)

For each target, run cheap checks (regex-based, <500 tokens per skill):
- File line count
- Description length
- Presence of deprecated patterns (temperature/top_p/top_k/budget_tokens)
- Presence of ultrathink literal
- Emphasis marker count
- Frontmatter completeness check

Output: preliminary quality estimate (0-10 scale) + flagged issues.

### Phase 3: Deep Audit (selective)

For skills scoring < 8.5 in quick scan, OR user-requested deep audit:
- Read full content
- Apply the 10-dimension rubric from `references/skill-quality-rubric.md`
- Use WebSearch if needed to verify technical claims
- Generate weighted score + per-dim evidence + fix proposals

Runs in **parallel via Agent dispatches** (batch of 3-5 skills per round) to keep total time bounded.

### Phase 4: Fix Categorization

For each issue found:
1. Classify fix type: SAFE / RISKY / FORBIDDEN (see `references/skill-fixer-patterns.md`)
2. Estimate impact: quality delta per dimension
3. Estimate risk: could this break existing behavior?

### Phase 5: Application

**Auto-apply SAFE fixes:**
1. Create backup: `<skill-dir>/.backup-<timestamp>.md`
2. Apply fix via Edit tool
3. Validate: re-read file, confirm diff is as expected
4. Log to `skill-refinement-audit.md`

**Propose RISKY fixes to user:**
1. Show diff
2. Ask via AskUserQuestion
3. If approved: apply with backup + log
4. If rejected: log "proposed but declined"

**Never touch FORBIDDEN patterns** — only report in summary.

### Phase 6: Report

Generate a summary:

```
★ refine-skills — Audit Report ──────────────────
Scanned: {N} skills
Refinement candidates: {N with score < 8.0}
Auto-fixes applied: {N}
Risky fixes proposed: {N}
Read-only findings (marketplace): {N}
Time: {duration}
Audit trail: ~/.claude/projects/<project>/memory/skill-refinement-audit.md
──────────────────────────────────────────────────

## Per-Skill Summary

### ✅ {skill-name} — 9.2/10 (no action needed)

### 🔧 {skill-name} — 7.4/10 → 8.7/10 (auto-refined)
Fixes applied:
- F1: Replaced ultrathink literal with effort=xhigh
- F3: Stripped 5 emphasis markers
- F5: Added effort+allowed-tools frontmatter

### 🛠️ {skill-name} — 6.8/10 (risky fixes proposed — awaiting approval)
Proposed:
- R1: Move lines 180-420 to references/lookup.md (progressive disclosure)
- R2: Rewrite ambiguous section 3 with concrete examples

### 📢 {skill-name} — 5.2/10 (marketplace-owned, read-only)
Flagged issues (report upstream):
- F1: Uses ultrathink literal (3 occurrences)
- F2: Uses budget_tokens (2 occurrences)
Consider opening PR to: {upstream-url}
```

### Phase 7: ROSETTA + Auto-Memory Writeback

1. Update ROSETTA with:
   - Skills user OWNS and their quality trajectory
   - Anti-patterns observed across user's skills (if a fix repeats 3+ times, note as pattern)
2. Write audit trail to auto-memory (`type: reference`)
3. Update Meta-Reasoner bandit if audit improved outcomes

## Fix Catalog (summary)

See `references/skill-fixer-patterns.md` for full catalog. Quick reference:

**SAFE (auto-apply):**
- F1: deprecated thinking → effort
- F2: strip deprecated sampling params
- F3: strip emphasis markers
- F4: de-duplicate directives
- F5: add missing frontmatter
- F6: truncate over-long description
- F7: remove manual CoT triggers
- F8: fully-qualify skill refs
- F9: add missing anti-pattern section
- F10: fix YAML syntax

**RISKY (propose-only):**
- R1: restructure for progressive disclosure
- R2: rewrite vague instructions
- R3: add output format spec
- R4: split multi-purpose skill
- R5: update outdated citations
- R6: consolidate duplicate skills

**FORBIDDEN:**
- X1: third-party plugin modification
- X2: self-modification
- X3: Claude Code built-in modification
- X4: change skill's core purpose
- X5: remove user-specific content

## Invocation Examples

### Full audit (all user-owned)
```
/llm-language:refine-skills
```

### Audit single skill
```
/llm-language:refine-skills solana-dev
```

### Dry-run (see what would change, no writes)
```
/llm-language:refine-skills --dry-run
```

### Rollback a previous fix
```
/llm-language:refine-skills rollback solana-dev
```
Restores from the most recent `.backup-<timestamp>.md` (or user-specified timestamp).

### Audit focused on Opus 4.7 migration
```
/llm-language:refine-skills --filter=opus-4-7-incompatible
```
Only shows skills with deprecated param issues or model-compat problems.

## Integration with Main Pipeline

The main llm-language skill runs a **lightweight Phase 7 Skill Audit** during every `/llm-language` invocation:
- Only evaluates skills that are RELEVANT to the current task (from Phase 1 registry)
- Applies only F1, F2, F3 (deprecated syntax, emphasis strip) if issues found
- Flags other issues to Summary Banner as refinement candidates
- Logs to ROSETTA patterns

To run the **full deep audit** on all skills, invoke this sub-skill explicitly.

## Token Cost Estimate

| Audit Type | Skills Scanned | Deep Dives | Est. Tokens |
|---|---|---|---|
| Quick-scan only | all (~10-50) | 0 | ~5K-10K |
| Light audit | all | 2-5 | ~15K-30K |
| Deep audit | all | all with issues | ~40K-80K |
| Full refactor pass | all | all | ~80K-200K |

Use `effort: xhigh` by default (Opus 4.7 guidance for agentic work).

## Anti-Patterns

| Anti-Pattern | Prevention |
|---|---|
| Modifying marketplace plugins | Scope check excludes `plugins/marketplaces/` by default |
| Recursive self-modification | Hard-coded exclusion of llm-language itself |
| Silent breaking changes | Every auto-fix creates backup + audit log |
| Over-eager auto-apply | Only SAFE fixes auto; RISKY always proposes |
| Fixing third-party intent | X4 rule: never change skill's core purpose without flagging |
| Running on corrupt skill | Pre-flight YAML validity check before any fix |
| Ignoring git state | Check for uncommitted changes, offer to stash |

## Failure Modes

If a fix application fails:
1. Restore from backup (created pre-fix)
2. Log failure to audit trail with error details
3. Skip that skill, continue with others
4. Report failures in final summary
5. Exit non-zero (so harness knows something went wrong)

## References

- `references/skill-quality-rubric.md` — 10-dimension scoring rubric
- `references/skill-fixer-patterns.md` — full catalog of safe/risky/forbidden fixes
- Main SKILL: `llm-language/skills/llm-language/SKILL.md` — Phase 7 description
- Main rubric: `llm-language/skills/llm-language/references/scoring-rubric.md`
