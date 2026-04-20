# Skill Fixer Patterns — Non-Destructive Refinements

Catalog of safe auto-fixes applied by `/llm-language:refine-skills` and Phase 7 auto-audit.

**Safety principle:** Non-destructive fixes PRESERVE original behavior while improving quality. They never change semantics, remove content, or alter intent.

## Classification

### Safe (auto-apply, log to audit trail)

These fixes are provably behavior-preserving. Apply automatically and note in `refinement-audit.md` per skill.

### Risky (propose-only, require approval)

These could alter behavior in subtle ways. Show diff to user, require explicit approval.

### Forbidden (never auto-apply)

These are too invasive for automation. Only suggest via report.

---

## SAFE Fixes

### F1. Deprecated Thinking Syntax → Effort Parameter

**Trigger:** Skill contains `thinking="ultrathink"` literal in XML templates or instructions.

**Problem:** Returns 400 error on Opus 4.7. Legacy on Opus 4.6 (deprecated).

**Fix:**
```diff
- thinking="ultrathink"
+ effort="xhigh" thinking="adaptive"
```

**In markdown prose:**
```diff
- Set thinking to "ultrathink" for complex tasks
+ Set effort to "xhigh" (use "max" for frontier problems) and thinking to "adaptive"
```

### F2. Strip Deprecated Sampling Params

**Trigger:** Skill references `temperature`, `top_p`, `top_k`, `budget_tokens` in code blocks or prose.

**Problem:** Return 400 on Opus 4.7.

**Fix:** Remove the param entirely OR replace with effort-based guidance.

```diff
- temperature: 0
- top_p: 0.95
- budget_tokens: 32000
+ effort: xhigh  # Controls intelligence/token-spend tradeoff on Opus 4.7
```

### F3. Strip Emphasis Markers

**Trigger:** Skill contains "VERY IMPORTANT", "ABSOLUTELY MUST", "CRITICAL!!", or all-caps repetitions.

**Problem:** Opus 4.7 follows instructions literally; emphasis markers degrade output.

**Fix:** Remove the markers, keep the substantive directive.

```diff
- VERY IMPORTANT: You MUST always validate input. ABSOLUTELY CRITICAL.
+ Validate every input at API boundaries.
```

### F4. De-duplicate Directives

**Trigger:** Same rule stated 3+ times in different phrasings.

**Problem:** Wastes context, doesn't improve adherence on Opus 4.7.

**Fix:** Keep the most specific/actionable version; remove duplicates.

```diff
- Always write tests. Make sure to test your code. Testing is important.
- Please remember to add tests. Test everything you write.
+ Add unit tests alongside implementation; run `npm test` before committing.
```

### F5. Add Missing Frontmatter Fields

**Trigger:** Missing `effort`, `allowed-tools`, or `when_to_use` on heavy skills.

**Fix:**
```diff
 ---
 name: my-skill
 description: Does X
+effort: high
+allowed-tools: Read Grep Glob
+when_to_use: When user asks to analyze Y or explore Z
 ---
```

Infer `effort` from skill complexity (simple→medium, complex→high). Infer `allowed-tools` from actual tool usage in the skill body.

### F6. Truncate Over-Long Description

**Trigger:** `description` > 1536 chars (gets truncated in skill listing anyway).

**Fix:** Keep first 1500 chars; move the rest to skill body as `## Additional Context`.

### F7. Remove Manual CoT Triggers

**Trigger:** Skill prescribes "think step by step" / "let's think" in generated prompts.

**Problem:** On Opus 4.7 with adaptive thinking, this is redundant and can interfere.

**Fix:** Remove the trigger phrase. Adaptive thinking handles CoT automatically.

```diff
- Before answering, think step by step.
- 
- Then provide the answer.
+ Provide the answer.  <!-- adaptive thinking triggers CoT when beneficial -->
```

### F8. Fully-Qualify Skill References

**Trigger:** Skill references another skill by bare name (`test-driven-development`).

**Fix:** Prefix with plugin namespace.
```diff
- Invoke /test-driven-development before writing code
+ Invoke /superpowers:test-driven-development before writing code
```

### F9. Add Missing Anti-Pattern Section

**Trigger:** Skill specifies many "do X" rules but no "avoid Y" section.

**Fix:** Add `## Anti-Patterns` section with inferred antipatterns from the positive rules.

### F10. Fix Common JSON/YAML Syntax Errors

**Trigger:** Frontmatter has quoted types wrong, list not bracketed, etc.

**Fix:** Normalize to valid YAML.
```diff
- allowed-tools: Read, Grep, Glob
+ allowed-tools: Read Grep Glob  # Space-separated string per spec
# OR
+ allowed-tools:
+   - Read
+   - Grep
+   - Glob
```

---

## RISKY Fixes (propose-only)

### R1. Restructure for Progressive Disclosure

**Trigger:** SKILL.md > 500 lines; heavy reference content inline.

**Proposal:** Move lines X-Y to `references/<topic>.md`, replace with `See [references/<topic>.md](...)` link.

**Why risky:** Changes file organization; if user has tooling that expects inline content, could break.

### R2. Rewrite Vague Instructions

**Trigger:** Dimension 2 (Instruction Clarity) scores < 6.

**Proposal:** Rewrite ambiguous directives with concrete examples.

**Why risky:** Could accidentally change intent.

### R3. Add Output Format Specification

**Trigger:** Skill lacks explicit output format.

**Proposal:** Infer format from skill purpose, add `## Output Format` section.

**Why risky:** User may have intentionally left format flexible.

### R4. Split Multi-Purpose Skill

**Trigger:** Skill handles 3+ distinct workflows.

**Proposal:** Split into sub-skills.

**Why risky:** Major architectural change; requires user design decision.

### R5. Update Outdated Citations

**Trigger:** Citations > 3 years old in rapidly-evolving area (LLM prompting).

**Proposal:** Suggest replacement citations (user confirms).

### R6. Consolidate Duplicate Skills

**Trigger:** Multiple skills with high content overlap.

**Proposal:** Merge into one with parameterization.

**Why risky:** Breaks invocation patterns if user depends on separate slash commands.

---

## FORBIDDEN Fixes

### X1. NEVER modify third-party plugin skills

Skills under `~/.claude/plugins/marketplaces/<not-llm-language>/**` are upstream-owned. Report findings but never modify.

### X2. NEVER modify llm-language itself recursively

Audit rules exclude `llm-language/**`. Self-modification loop is a trap.

### X3. NEVER modify Claude Code built-in skills

These are Anthropic-maintained. Report findings via GitHub issue.

### X4. NEVER change skill's core purpose

If `description` says "deploy apps" but body does something else, FLAG to user — do not unilaterally fix either side.

### X5. NEVER remove user content

If skill has user-specific content (API keys, project names, custom rules), preserve exactly.

---

## Audit Trail

Every auto-fix is logged to `~/.claude/projects/<project>/memory/skill-refinement-audit.md`:

```markdown
---
name: skill-refinement-audit
description: Audit trail for all skill auto-refinements by llm-language
type: reference
---

# Skill Refinement Audit Trail

## 2026-04-20T22:30:00Z
**Target:** ~/.claude/skills/solana-dev/SKILL.md
**Scope:** user-owned
**Weighted score before:** 7.2 → **after:** 8.5
**Fixes applied:**
- F1: Replaced `thinking="ultrathink"` → `effort="xhigh"` + `thinking="adaptive"` (3 occurrences)
- F3: Stripped 5 "VERY IMPORTANT" markers
- F5: Added `effort: high` and `when_to_use` to frontmatter
**Proposed (not applied):**
- R1: Suggest moving reference table (lines 230-410) to `references/solana-constants.md`
**Trigger:** Auto-audit during /llm-language invocation
```

## Rollback

If any auto-fix causes regressions, user can:

1. Check audit trail at `~/.claude/projects/<project>/memory/skill-refinement-audit.md`
2. Revert via git if skill is version-controlled
3. Request `/llm-language:refine-skills rollback <skill-name>` (restores from backup)

Before each auto-fix, the skill file is backed up to `<skill-dir>/.backup-<timestamp>.md`. Backups older than 30 days are auto-pruned.
