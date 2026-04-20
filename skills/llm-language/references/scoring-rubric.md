# Scoring Rubric — llm-language Critic Agent (v4.0)

## Overview

The Critic agent evaluates generated XML prompts on **10 dimensions** (v4.0 added Dim 9 Effort Calibration + Dim 10 Memory Integration). Each dimension is scored 1-10 using the anchored scale. The weighted score determines whether revision is needed.

## Convergence Criteria (v4.0)

- **Pass threshold:** weighted score >= **9.3/10** (was 9.2 in v3.x; 8.5 in v2.0)
- **Max revision rounds:** 4 (was 2 in v2.0)
- **Delta convergence:** stop if improvement < 0.2 between rounds
- **If score >= 9.3 on first pass:** skip directly to execution
- **Opus 4.7 compliance auto-fail:** if prompt contains `temperature`, `top_p`, `top_k`, `budget_tokens` for Opus 4.7 target → Dim 4 = 3, forced revision

## Scoring Dimensions

### 1. Intent Preservation (Weight: 0.25)

Does the optimized prompt preserve the user's original intent completely?

| Score | Anchor |
|---|---|
| 2 | Core intent changed or distorted. User would not recognize their request. |
| 4 | Intent partially preserved but important aspects missing or altered. |
| 6 | Intent preserved but some implicit needs not captured. |
| 8 | Intent preserved exactly, including implicit requirements inferred from context. |
| 10 | Intent + all implicit needs + edge cases anticipated. User's "ideal request" articulated better than they could. |

**Red flags:** Adding objectives the user didn't request. Changing the scope (narrowing or expanding without justification). Interpreting ambiguity without flagging the assumption.

---

### 2. Precision (Weight: 0.20)

Is every instruction specific and unambiguous?

| Score | Anchor |
|---|---|
| 2 | Vague, abstract instructions. "Make it good." Multiple interpretations possible. |
| 4 | Some specific instructions mixed with vague ones. |
| 6 | Most instructions are specific. 1-2 ambiguous areas remain. |
| 8 | All instructions are specific and unambiguous. Every word carries meaning. |
| 10 | Every instruction is load-bearing. Zero ambiguity. Constraints are tight but not over-constrained. |

**Red flags:** Adjectives without concrete definition ("clean code", "good performance"). Instructions that could be interpreted multiple ways. Missing output format specification.

---

### 3. Completeness (Weight: 0.20)

Are all sub-tasks addressed? Are edge cases covered?

| Score | Anchor |
|---|---|
| 2 | Major components of the task missing. Only surface-level coverage. |
| 4 | Core task addressed but no sub-task decomposition. No edge cases. |
| 6 | Sub-tasks identified and addressed. 1-2 edge cases noted. |
| 8 | All sub-tasks decomposed and sequenced. Key edge cases covered. Acceptance criteria defined. |
| 10 | Comprehensive decomposition with dependencies. Edge cases + anti-patterns + acceptance criteria + verification strategy. |

**Red flags:** Missing acceptance criteria for complex tasks. No edge case consideration for critical tasks. Sub-tasks not ordered by dependency.

---

### 4. Structure (Weight: 0.15)

Is the XML well-formed? Is the hierarchy clear and semantic?

| Score | Anchor |
|---|---|
| 2 | Malformed XML. Flat structure without meaningful hierarchy. |
| 4 | Valid XML but poor tag naming or flat organization. |
| 6 | Well-formed XML with correct section structure. Some tags could be more semantic. |
| 8 | Clean XML with semantic tags, proper nesting, and clear hierarchy. Follows the template exactly. |
| 10 | Optimal XML structure. Perfect use of attributes. Content placement exploits primacy/recency effects. Easy to parse and modify. |

**Red flags:** Missing required sections (meta, role, task, methodology). Incorrect nesting. Non-semantic tag names. Content in wrong section.

---

### 5. Opus 4.7 Optimization (Weight: 0.10) — v4.0 UPDATED

Does the prompt leverage Opus 4.7's specific capabilities (adaptive thinking, effort parameter, task budgets, literal instruction following)?

| Score | Anchor |
|---|---|
| 2 | Generic prompt that would work on any model. No model-specific optimization. Uses deprecated params (temperature/top_p/top_k/budget_tokens). |
| 4 | Thinking/effort level set but not matched to complexity. Legacy `thinking="ultrathink"` used instead of `effort="xhigh\|max"` + `thinking="adaptive"`. |
| 6 | Correct effort level + adaptive thinking. Some tool awareness. |
| 8 | Effort matched to complexity (simple→medium, moderate→high, complex→xhigh, critical→max). Adaptive thinking. Tool guidance included. Extended context exploited. General instructions over prescriptive steps. Explicit parallelism hint when independent sub-tasks. `max_tokens` ≥ 64k for xhigh/max. |
| 10 | Full Opus 4.7 optimization: effort + adaptive thinking + task budgets (for agentic loops) + MRCR guard (if >100k context) + high-res image support (if vision task) + literal instruction style (de-duped, positive framing, concise role). All Opus 4.7 idiosyncrasies respected. |

**Red flags:**
- `effort="max"` for simple tasks (wastes tokens, causes overthinking on structured output)
- Prescriptive step-by-step for xhigh/max effort (limits Claude's adaptive thinking)
- Missing tool guidance when tools are relevant
- Missing explicit parallelism directive (Opus 4.7 spawns fewer subagents by default)
- Using legacy `thinking="ultrathink"` for Opus 4.7 target (returns 400)
- Emitting deprecated params `temperature`/`top_p`/`top_k`/`budget_tokens` (returns 400)
- Verbose role persona (one sentence is sweet spot for 4.7)
- `max_tokens < 64000` for xhigh/max effort (insufficient headroom)

---

### 6. Scientific Grounding (Weight: 0.10)

Are appropriate prompt engineering techniques applied to the task type?

| Score | Anchor |
|---|---|
| 2 | No techniques applied. Raw instruction dump. |
| 4 | CoT added generically regardless of task type. |
| 6 | 1-2 appropriate techniques selected and applied. |
| 8 | Techniques matched to task type using the Decision Matrix. Multiple complementary techniques combined. |
| 10 | Optimal technique selection. Techniques interact synergistically. Novel technique combination justified by task requirements. |

**Red flags:** ToT for simple tasks (overkill). Missing CoT for multi-step reasoning. Self-Consistency not used for high-stakes decisions. Role prompting for factual accuracy (doesn't work — use for style/format only).

---

### 7. User-Fit Alignment (Weight: 0.10) — NEW in v2.0

Does the prompt leverage ROSETTA.md insights to align with this specific user's preferences?

| Score | Anchor |
|---|---|
| 2 | ROSETTA.md context completely ignored. Generic prompt with no personalization. |
| 4 | ROSETTA.md was referenced but insights not applied. |
| 6 | Some ROSETTA patterns applied. User preferences partially reflected. |
| 8 | Key ROSETTA patterns applied. Output format, style, and approach match known user preferences. Prior effective techniques reused where applicable. |
| 10 | Deep ROSETTA integration. Preferences, anti-patterns, domain context, and prior effective techniques all reflected. Prompt anticipates user needs based on accumulated history. |

**Red flags:** Using techniques ROSETTA lists as anti-patterns. Ignoring known output format preferences. Not leveraging domain context from ROSETTA when the topic matches. If ROSETTA.md is empty (new user), score 7 by default — no penalty for lack of history.

**Special case:** If ROSETTA.md does not exist or has zero interactions, default score is 7 (neutral). The dimension becomes meaningful after 3+ interactions.

---

### 8. Codebase Grounding (Weight: 0.10) — v3.0, UPDATED WEIGHT in v4.0

Does the prompt reference the ACTUAL project state, not an imagined one?

| Score | Anchor |
|---|---|
| 2 | Prompt ignores the codebase entirely. Recommends technologies/scale incompatible with the project. |
| 4 | Prompt mentions the project domain but does not reference specific files, invariants, or conventions. |
| 6 | Some codebase references present but superficial. Scale mostly appropriate but with mismatches. |
| 8 | Prompt references real files, real invariants, real conventions. Scale matches actual team/budget/tech. Existing content detected and acknowledged. |
| 10 | Deep codebase integration. Every recommendation grounded in actual project state. Context mismatches flagged. Existing work acknowledged and built upon. Technology choices match exactly what's installed/used. |

**Red flags:** Recommending technologies not in the project's stack. Ignoring existing implementations. Treating a working system as greenfield. Over-engineering beyond the project's actual scale. Not detecting that target content already exists.

**Special case:** If no codebase context is available (no CLAUDE.md, no git repo), default score is 6 (neutral). The dimension becomes meaningful when a project context exists.

---

### 9. Effort Calibration (Weight: 0.06) — NEW in v4.0

Does the prompt select the right `effort` level for the task complexity?

| Score | Anchor |
|---|---|
| 2 | No `effort` attribute set on root element. Or effort clearly wrong (e.g., `max` for a trivial factual lookup, `low` for architecture design). |
| 4 | Effort set but poorly matched to complexity. `max` used where `xhigh` would suffice (overthinking risk). |
| 6 | Effort roughly matches complexity but lacks justification in `<effort-justification>`. |
| 8 | Effort matches complexity per the mapping (simple→medium, moderate→high, complex→xhigh, critical→max). `<effort-justification>` present and sound. `max_tokens` appropriate for effort level. |
| 10 | Perfect effort calibration. `<effort-justification>` explains WHY this level vs. adjacent levels. `max_tokens`, `task_budget` (if applicable) all aligned. User's "massima precisione" signal detected and mapped to max if signaled. |

**Red flags:**
- `effort="max"` for structured output tasks (causes overthinking)
- `effort="low"` or `"medium"` for complex architecture decisions
- Missing `effort` attribute entirely
- `max_tokens` doesn't match effort level (e.g., max_tokens=4000 with effort=max)
- No `<effort-justification>` present when complexity > moderate

**Special case:** For Sonnet 4.6 target, map complexity down one level (complex→high instead of xhigh). Sonnet defaults to high but medium is often better for speed-sensitive workloads.

---

### 10. Memory Integration (Weight: 0.05) — NEW in v4.0

Does the prompt leverage dual-layer memory (ROSETTA + auto-memory) and emit persistence directives?

| Score | Anchor |
|---|---|
| 2 | No `<memory-context>` section. No reference to ROSETTA patterns or auto-memory entries. No `<persistence>` directives. |
| 4 | `<memory-context>` present but contains generic "no relevant memory" placeholder despite relevant memory existing. |
| 6 | Some ROSETTA patterns referenced, but auto-memory ignored. Or `<persistence>` section present but vague. |
| 8 | Both ROSETTA (user-level) and auto-memory (project-level) surveyed and relevant entries injected. `<persistence>` directives specify what to write post-execution. BoT templates retrieved if matching task pattern. |
| 10 | Deep memory integration: ROSETTA patterns + auto-memory entries + BoT template (if hit) + strategy-prior from Meta-Reasoner bandit. `<persistence>` specifies concrete post-execution writes to ROSETTA + typed auto-memory entries (user/feedback/project/reference). MRCR guard injected if context >100k. |

**Red flags:**
- Empty `<memory-context>` when relevant memory exists
- No `<persistence>` directives when execution will produce learnings
- Ignoring user-feedback memory that matches the current task type
- Not retrieving matching BoT template when hit_count > 3
- Not injecting MRCR guard for >100k context tasks

**Special case:** If ROSETTA.md doesn't exist AND auto-memory is empty (brand-new user, empty project), default score is 7 (neutral). Dimension becomes meaningful after 3+ interactions OR when project has accumulated auto-memory content.

---

## Weighted Score Calculation (v4.0 — 10 dimensions)

```
weighted_score = (intent * 0.16)
               + (precision * 0.14)
               + (completeness * 0.14)
               + (structure * 0.10)
               + (opus_47_optimization * 0.10)
               + (scientific_grounding * 0.07)
               + (user_fit * 0.08)
               + (codebase_grounding * 0.10)
               + (effort_calibration * 0.06)
               + (memory_integration * 0.05)
```

**Weight rebalancing rationale (v3.x → v4.0):**
- Intent 0.18 → 0.16, Precision 0.16 → 0.14, Completeness 0.16 → 0.14, Structure 0.12 → 0.10
- Opus Opt 0.08 → 0.10 (now 4.7-specific; encodes breaking change compliance)
- Scientific 0.08 → 0.07, User Fit 0.10 → 0.08, Codebase 0.12 → 0.10
- Effort Calibration 0.06 (NEW) — measured +1.3 points avg impact in v4.0 pilot evals
- Memory Integration 0.05 (NEW) — measured +0.9 points avg impact

**Total: 1.00** ✓

**Pass threshold: 9.3/10** (raised from 9.2 in v3.x, based on 10-dim evaluation showing Dim 9+10 add useful signal that should be reflected in threshold).

## Critic Output Format

The Critic agent MUST output its evaluation in this exact structure:

```xml
<critique>
  <scores>
    <dimension name="intent-preservation" score="8" weight="0.25">
      Evidence: [specific evidence from the prompt]
      Issue: [if score < 8, what's wrong]
    </dimension>
    <dimension name="precision" score="7" weight="0.20">
      Evidence: [...]
      Issue: [...]
    </dimension>
    <dimension name="completeness" score="9" weight="0.20">
      Evidence: [...]
    </dimension>
    <dimension name="structure" score="8" weight="0.15">
      Evidence: [...]
    </dimension>
    <dimension name="opus-optimization" score="7" weight="0.10">
      Evidence: [...]
      Issue: [...]
    </dimension>
    <dimension name="scientific-grounding" score="8" weight="0.10">
      Evidence: [...]
    </dimension>
    <dimension name="user-fit-alignment" score="7" weight="0.10">
      Evidence: [ROSETTA patterns applied or not]
      Issue: [if score < 8, what ROSETTA insights were missed]
    </dimension>
    <dimension name="codebase-grounding" score="8" weight="0.10">
      Evidence: [real files referenced, invariants preserved, scale match, existing content detected]
      Issue: [if score < 8, what codebase context was missed or misrepresented]
    </dimension>
    <dimension name="effort-calibration" score="8" weight="0.06">
      Evidence: [effort level matches complexity, justification present, max_tokens aligned]
      Issue: [if score < 8, what effort mismatch or missing justification]
    </dimension>
    <dimension name="memory-integration" score="8" weight="0.05">
      Evidence: [ROSETTA patterns applied, auto-memory consulted, persistence directives present, BoT template retrieved if matching]
      Issue: [if score < 8, what memory layer was underused]
    </dimension>
  </scores>

  <needs-clarification>
    <!-- Only if a CRITICAL ambiguity exists that neither prompt nor memory resolves -->
  </needs-clarification>

  <opus-47-compliance>
    <!-- v4.0 NEW: auto-check for deprecated params on Opus 4.7 target -->
    <has-deprecated-params>true|false</has-deprecated-params>
    <uses-adaptive-thinking>true|false</uses-adaptive-thinking>
    <effort-attribute-set>true|false</effort-attribute-set>
    <max-tokens-adequate>true|false</max-tokens-adequate>
  </opus-47-compliance>

  <weighted-score>7.85</weighted-score>
  <verdict>revise|accept</verdict>

  <suggestions priority="high">
    <suggestion dimension="precision">
      [Specific, actionable suggestion for improvement]
    </suggestion>
    <suggestion dimension="opus-47-optimization">
      [Specific, actionable suggestion for improvement]
    </suggestion>
  </suggestions>
</critique>
```

## Anti-Inflation Rules (v4.0 — STRICT)

To prevent score inflation (empirical finding: v2.0 self-assessment inflated by 2.51 points):

1. **Start at 5, justify UPWARD:** Do NOT start at 7. 5 is mediocre. Justify every point above 5.
2. **Anchor to examples:** Always compare against the rubric anchors, not gut feeling
3. **Require evidence:** Every score must cite specific content from the prompt
4. **Penalize missing sections:** Absent required sections = automatic 4 or below for structure
5. **Check Decision Matrix:** If techniques don't match the task type from the Quick Decision Matrix in scientific-principles.md, score scientific-grounding accordingly
6. **Cross-check codebase:** If the prompt recommends X but the project uses Y, score codebase-grounding accordingly. Over-engineering beyond actual project scale = automatic 5 or below.
7. **"Adequate" = 6, "Good" = 7:** Reserve 8+ for genuinely strong work. 9 = near-perfect. 10 = cannot find a single improvement.
8. **Pass threshold is 9.3:** This is deliberately hard to reach. Most prompts should require 1-2 revision rounds.
9. **v4.0 NEW — Opus 4.7 auto-fail checks:** If target is claude-opus-4-7 and prompt contains `temperature`/`top_p`/`top_k`/`budget_tokens` literal → Dim 4 (Structure) = 3, forced revision regardless of other scores. These params return 400 on 4.7.
10. **v4.0 NEW — Effort mismatch penalty:** `max` for simple/moderate tasks → Dim 9 ≤ 4 (overthinking cost). Missing `effort` attribute entirely → Dim 9 = 2.
11. **v4.0 NEW — Memory underuse penalty:** ROSETTA/auto-memory has relevant entries but `<memory-context>` is empty → Dim 10 ≤ 3.
