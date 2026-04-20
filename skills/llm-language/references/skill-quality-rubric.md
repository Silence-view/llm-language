# Skill Quality Rubric — llm-language Skill Auditor

## Overview

This rubric is used by `/llm-language:refine-skills` (deep audit) and the Phase 7 auto-audit (light-touch) inside the main llm-language pipeline. It scores third-party skills on 10 dimensions to identify refinement candidates.

**Pass threshold:** weighted score ≥ 8.0
**Refinement triggered:** weighted score < 8.0 OR any dim < 5

## Audit Scope (what CAN be refined)

| Source | Refine? | Rationale |
|---|:---:|---|
| `~/.claude/skills/<name>/SKILL.md` | ✅ YES | User-owned personal skills |
| `<project>/.claude/skills/<name>/SKILL.md` | ✅ YES (with caution) | Project-level, may be team-shared — prompt for confirmation |
| `~/.claude/plugins/marketplaces/<marketplace>/skills/**/SKILL.md` | ⚠️ REPORT ONLY | Upstream-owned; suggest refinement to maintainer via PR |
| `~/.claude/plugins/cache/**/SKILL.md` | ❌ NEVER | Cache, overwritten on update |
| Claude Code built-in skills | ❌ NEVER | Anthropic-maintained |
| **llm-language itself** | ❌ **NEVER** | Recursive self-modification trap |

## Scoring Dimensions

### 1. Triggering Precision (Weight: 0.20)

Does the `description` field make Claude invoke this skill at the right times — not too often, not too rarely?

| Score | Anchor |
|---|---|
| 2 | Description is vague ("helps with code") — Claude can't reliably match user intent |
| 4 | Description mentions domain but lacks trigger phrases / example requests |
| 6 | Description identifies WHEN to use but misses common trigger variations |
| 8 | Description clearly states WHAT + WHEN + trigger phrases. Claude rarely misfires. |
| 10 | Description is surgical: front-loads key use case, includes trigger phrases, when_to_use field set, examples specific. Zero false positives/negatives in practice. |

**Red flags:**
- Description < 50 chars (too terse)
- Description > 1536 chars (truncated in skill listing)
- No trigger phrases / example requests
- Description doesn't reflect actual skill behavior
- Missing `when_to_use` for complex skills

### 2. Instruction Clarity (Weight: 0.15)

Is the skill body unambiguous? Can a fresh Claude instance follow it without improvisation?

| Score | Anchor |
|---|---|
| 2 | Vague directives ("make it good"). Multiple interpretations possible per paragraph. |
| 4 | Some specific instructions mixed with vague ones. Requires guessing. |
| 6 | Most instructions specific. 1-2 ambiguous sections remain. |
| 8 | All instructions specific and unambiguous. Steps clearly ordered. |
| 10 | Every word load-bearing. Checklists where applicable. Zero ambiguity. Includes success criteria per step. |

**Red flags:**
- Adjectives without concrete definition ("clean", "good", "nice")
- Undefined references ("as before", "the usual way")
- Missing output format specification
- Steps not ordered by dependency

### 3. Context Efficiency (Weight: 0.15)

Does the skill respect context budget? <500 lines? Progressive disclosure?

| Score | Anchor |
|---|---|
| 2 | >1500 lines, all content in SKILL.md. Massive context waste when loaded. |
| 4 | 800-1500 lines. Examples/reference should be externalized. |
| 6 | 500-800 lines. Some candidates for progressive disclosure. |
| 8 | ≤500 lines. Heavy content in sibling files. Clear navigation. |
| 10 | ≤300 lines. Token-efficient. References load on demand. Survives auto-compaction. |

**Red flags:**
- Inline code examples > 50 lines each (should be sibling files)
- Reference docs inside SKILL.md (should be separate .md)
- Verbose headers / boilerplate
- Duplicated content across skills

### 4. Frontmatter Completeness (Weight: 0.10)

Are all relevant YAML frontmatter fields set correctly?

| Score | Anchor |
|---|---|
| 2 | Missing `description`. No effective trigger. |
| 4 | Has `description` but missing other relevant fields (effort, allowed-tools, model). |
| 6 | Most fields set but some mismatched (e.g., `model` set but incompatible with skill scope). |
| 8 | All relevant fields set: `name`, `description`, `allowed-tools`, `effort` (if heavy). |
| 10 | Complete frontmatter: `name`, `description`, `when_to_use`, `effort`, `allowed-tools`, `model` (if specific), `disable-model-invocation` / `user-invocable` (where appropriate), `paths` (if file-scoped). |

**Red flags:**
- Missing `description`
- Missing `effort` on heavy-reasoning skills (defaults inherited, may be too low)
- Missing `allowed-tools` when using dangerous tools (Bash, Write)
- Wrong `context` field (`fork` for non-isolated work)

### 5. Model Compatibility (Weight: 0.10)

Does the skill work correctly on the current target model (Opus 4.7+)?

| Score | Anchor |
|---|---|
| 2 | Contains `temperature`, `top_p`, `top_k`, `budget_tokens` — will 400 on Opus 4.7 |
| 4 | Uses legacy `thinking="ultrathink"` literal — doesn't leverage new `effort` parameter |
| 6 | No deprecated params but also no effort-aware design |
| 8 | Uses `effort` appropriately OR agnostic about model (works on 4.6/4.7/Sonnet) |
| 10 | Model-aware: uses `effort` + adaptive thinking; has model-specific branches where helpful; tokenizer-aware in max_tokens hints. |

**Red flags:**
- Any occurrence of `temperature:` / `top_p:` / `top_k:` / `budget_tokens:`
- `thinking="ultrathink"` literal in XML templates
- Hard-coded max_tokens < 64000 for complex work
- Missing `display: "summarized"` when reasoning visibility needed

### 6. Anti-Pattern Avoidance (Weight: 0.10)

Does the skill follow Opus 4.7 writing rules (literal instruction following)?

| Score | Anchor |
|---|---|
| 2 | Heavy use of "VERY IMPORTANT", repeated caps, emphasis markers. Negative framing throughout. |
| 4 | Some redundancy / emphasis markers. Mix of positive and negative directives. |
| 6 | Mostly clean but a few emphasis markers remain. |
| 8 | No emphasis markers, positive framing, de-duplicated directives. |
| 10 | Surgical prose. Every directive stated exactly once. Positive throughout. Reads naturally. |

**Red flags:**
- "VERY IMPORTANT", "ABSOLUTELY MUST", "NEVER" repeated 3+ times
- Long lists of "don't do X" (should be "do Y")
- Redundant imperatives ("do X. Make sure to do X. Remember to do X.")
- Excessive bold/italic/caps

### 7. Scientific Grounding (Weight: 0.05)

Are claims backed by citations or Anthropic docs where appropriate?

| Score | Anchor |
|---|---|
| 2 | Unsourced technical claims ("research shows X") with no citation |
| 6 | Some citations for major claims |
| 8 | Major technical claims cited (arXiv, Anthropic docs, peer-reviewed) |
| 10 | Every technical assertion cited. Citations are current (< 2 years for LLM field). |

**Red flags:**
- "Best practices say..." with no source
- Outdated citations (>3 years for rapidly-evolving areas)
- Citations to vendor marketing copy

### 8. Progressive Disclosure (Weight: 0.05)

Are heavy reference materials in sibling files loaded on demand?

| Score | Anchor |
|---|---|
| 2 | Everything inline. No sibling files. |
| 6 | Some sibling files but main SKILL.md still >500 lines |
| 8 | Sibling files for rubrics, templates, bibliographies. SKILL.md focused. |
| 10 | Canonical pattern: SKILL.md is navigation + high-level; `references/` holds details; `scripts/` holds executables. |

### 9. Skill Lifecycle Handling (Weight: 0.05)

Does the skill handle its lifecycle correctly (context forks, hooks, subagents)?

| Score | Anchor |
|---|---|
| 2 | No lifecycle awareness. Would break when used in subagent. |
| 6 | Works as inline skill but not designed for fork contexts. |
| 8 | Handles both inline and fork modes; hooks scoped correctly. |
| 10 | Full lifecycle: inline, forked, invoked by subagents, post-compaction recovery. |

### 10. Outcome Verifiability (Weight: 0.05)

Does the skill define success criteria? Examples? Verification steps?

| Score | Anchor |
|---|---|
| 2 | No success criteria. User can't tell if skill worked. |
| 6 | Some examples but no testable criteria. |
| 8 | Examples + success criteria for main use case. |
| 10 | Examples + testable criteria + verification commands + anti-example (what NOT to produce). |

---

## Weighted Score Calculation

```
weighted_score = (triggering_precision * 0.20)
               + (instruction_clarity * 0.15)
               + (context_efficiency * 0.15)
               + (frontmatter_completeness * 0.10)
               + (model_compatibility * 0.10)
               + (anti_pattern_avoidance * 0.10)
               + (scientific_grounding * 0.05)
               + (progressive_disclosure * 0.05)
               + (skill_lifecycle * 0.05)
               + (outcome_verifiability * 0.05)
```

**Total: 1.00** ✓

## Refinement Priority

| Weighted Score | Action |
|---|---|
| ≥ 9.0 | ✅ Excellent. No action. |
| 8.0–8.9 | ⚠️ Good. Consider minor polish. |
| 7.0–7.9 | 🔧 Candidate for refinement. Propose non-destructive fixes. |
| 5.0–6.9 | 🛠️ Significant issues. Destructive rewrites may help. |
| < 5.0 | 🚨 Broken/dangerous. Flag to user before any auto-fix. |

Any dimension < 5 → flag that specific dim for targeted repair, even if overall score is OK.

## Output Format

```xml
<skill-audit>
  <target path="{file-path}" />
  <scope>user | project | plugin-readonly</scope>
  <scores>
    <dim name="triggering-precision" score="7" weight="0.20">
      Evidence: Description is 82 chars; lacks trigger phrases.
      Issue: No `when_to_use` field; Claude may miss invocation opportunities.
      Fix: Add `when_to_use: "When user says X, Y, Z"` to frontmatter.
    </dim>
    <!-- ... for each dim ... -->
  </scores>
  <weighted-score>7.65</weighted-score>
  <verdict>refine | ok | broken</verdict>
  <auto-fixes>
    <!-- Non-destructive fixes safe to apply without approval -->
    <fix type="replace-deprecated-thinking">old: thinking="ultrathink" → new: effort="xhigh" + thinking="adaptive"</fix>
    <fix type="strip-emphasis">Remove 3 "VERY IMPORTANT" markers</fix>
    <fix type="add-frontmatter" field="effort">Add `effort: xhigh` to frontmatter</fix>
  </auto-fixes>
  <destructive-fixes>
    <!-- Requires user approval -->
    <fix type="restructure" dim="context-efficiency">
      Proposal: Move lines 150-400 (reference tables) to `references/lookup-tables.md`
    </fix>
  </destructive-fixes>
</skill-audit>
```
