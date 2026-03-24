# Scoring Rubric — slave-language Critic Agent

## Overview

The Critic agent evaluates generated XML prompts on 6 dimensions. Each dimension is scored 1-10 using the anchored scale below. The weighted score determines whether revision is needed.

## Convergence Criteria

- **Pass threshold:** weighted score >= 8.5/10
- **Max revision rounds:** 2 (after initial generation)
- **Delta convergence:** stop if improvement < 0.3 between rounds
- **If score >= 8.5 on first pass:** skip directly to execution

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

### 5. Opus 4.6 Optimization (Weight: 0.10)

Does the prompt leverage Opus 4.6's specific capabilities?

| Score | Anchor |
|---|---|
| 2 | Generic prompt that would work on any model. No model-specific optimization. |
| 4 | Thinking level set but not matched to complexity. |
| 6 | Correct thinking level. Some tool awareness. |
| 8 | Thinking level matched to complexity. Tool guidance included. Extended context exploited. General instructions favored over prescriptive steps. |
| 10 | Full model-specific optimization: thinking level, tool guidance, context window management, primacy/recency placement, thinking trace examples if few-shot. |

**Red flags:** Ultrathink for simple tasks (wastes tokens). Prescriptive step-by-step for ultrathink (limits Claude's reasoning). Missing tool guidance when tools are relevant.

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

## Weighted Score Calculation

```
weighted_score = (intent * 0.25) + (precision * 0.20) + (completeness * 0.20)
               + (structure * 0.15) + (opus_opt * 0.10) + (scientific * 0.10)
```

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
  </scores>

  <weighted-score>7.85</weighted-score>
  <verdict>revise|accept</verdict>

  <suggestions priority="high">
    <suggestion dimension="precision">
      [Specific, actionable suggestion for improvement]
    </suggestion>
    <suggestion dimension="opus-optimization">
      [Specific, actionable suggestion for improvement]
    </suggestion>
  </suggestions>
</critique>
```

## Anti-Inflation Rules

To prevent score inflation:

1. **Anchor to examples:** Always compare against the rubric anchors, not gut feeling
2. **Default to 7:** Start at 7 and adjust up/down based on evidence
3. **Require evidence:** Every score must cite specific content from the prompt
4. **Penalize missing sections:** Absent required sections = automatic 4 or below for structure
5. **Check Decision Matrix:** If techniques don't match the task type from the Quick Decision Matrix in scientific-principles.md, score scientific-grounding accordingly
