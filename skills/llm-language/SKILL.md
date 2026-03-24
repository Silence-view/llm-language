---
name: llm-language
version: "1.0"
description: >
  Use when receiving ANY user message, task, or prompt that requires
  execution. Invoke BEFORE any other action to re-engineer the prompt
  through multi-agent debate with scientific optimization. Triggers on:
  code requests, analysis, research, creative tasks, debugging, design,
  refactoring, writing. Also triggers on "llm-language", "optimize
  prompt", "re-engineer prompt", "massima precisione", "maximum quality".
  Skip only for greetings or when user says "skip llm-language".
  Opus 4.6 + ultrathink.
---

# llm-language

## Overview

A prompt meta-compiler that intercepts user messages, re-engineers them through a multi-agent debate process grounded in scientific prompt engineering literature (100+ papers), and produces an optimized XML-structured prompt specialized for Claude Opus 4.6 with ultrathink. The generated prompt is ephemeral — never saved to disk, used only for immediate execution.

**Core cycle:** Generate → Critique → Revise → Final Critique → Execute

## When to Use

**ALWAYS.** This skill applies to every user message. The only exceptions are:
- Messages that are purely conversational greetings ("hello", "thanks")
- Messages that explicitly say "skip llm-language" or "raw mode"

For everything else — code, analysis, writing, research, debugging, design — run the full pipeline.

## Pipeline Execution

Execute these 5 phases IN ORDER. Do not skip phases. Do not save the generated prompt to any file.

### Phase 1: INTAKE (inline, no subagent)

Perform these steps directly — no subagent needed:

**1.1 Capture Raw Input**

Store the user's exact message verbatim. This is IMMUTABLE — never modify it.

**1.2 Discover Available Skills**

Run `Glob` on `~/.claude/skills/*/SKILL.md` and `~/.claude/agents/*.md` to enumerate all available skills and agents. For each, extract the `name` and `description` from the YAML frontmatter (first 5 lines). Build a compact registry:

```
Skills: [name1: description1, name2: description2, ...]
Agents: [name1: description1, name2: description2, ...]
```

**CRITICAL: Exclude `llm-language` from the registry.** Never include this skill in the discovered list to prevent recursive self-invocation.

**1.3 Classify Complexity**

Analyze the user's message and classify:
- **simple** → single-step, clear output, no ambiguity (e.g., "what does this function do?")
- **moderate** → multi-step, clear dependencies (e.g., "add a new endpoint for user auth")
- **complex** → multiple approaches possible, architecture decisions (e.g., "refactor the payment module")
- **critical** → high-stakes, irreversible, requires maximum depth (e.g., "migrate the database schema")

**1.4 Select Scientific Principles**

Based on complexity and task type, select applicable principles from `references/scientific-principles.md` using the Quick Decision Matrix at the bottom of that file. Reference principles by ID (e.g., A1-CoT, A2-ToT, B1-SelfRefine).

**1.5 Read XML Template**

Read `references/xml-prompt-template.md` for the Producer agent.

### Phase 2: GENERATE (Producer Subagent)

Dispatch a **general-purpose Agent** (model=opus) with this prompt structure:

```
You are an expert prompt engineer specializing in Claude Opus 4.6 optimization.
Your task: transform the user's raw input into a maximally optimized XML prompt.

RAW USER INPUT:
<raw-input>
{user's exact message}
</raw-input>

AVAILABLE SKILLS AND AGENTS:
<skill-registry>
{skill/agent registry from Phase 1}
</skill-registry>

COMPLEXITY LEVEL: {classified complexity}

SELECTED SCIENTIFIC PRINCIPLES:
<principles>
{selected principle IDs and brief descriptions}
</principles>

XML TEMPLATE TO FOLLOW:
<template>
{content of references/xml-prompt-template.md}
</template>

INSTRUCTIONS:
1. Analyze the raw input to extract the user's TRUE intent (not just surface request)
2. Fill every section of the XML template with specific, precise content
3. Apply the selected scientific principles to the methodology section
4. Match skills/agents from the registry that are relevant to this task
5. Set thinking="ultrathink" in the root element
6. Ensure the <role> field assigns a specific expert persona matched to the domain
7. Decompose into sub-tasks ordered by dependency (least-to-most when applicable)
8. Add edge cases specific to this task
9. Define concrete acceptance criteria
10. Specify anti-patterns to avoid

OUTPUT: Return ONLY the complete XML prompt. No commentary, no explanations, just the XML.

CRITICAL RULES:
- Preserve the user's original intent EXACTLY
- Be SPECIFIC — every instruction must be unambiguous
- Favor GENERAL instructions over prescriptive steps in the methodology
  (Anthropic research shows Claude's extended thinking exceeds hand-written step plans)
- Include available skills in <tools-and-skills> only if genuinely relevant
- The XML prompt must be immediately executable — no placeholders or TODOs
```

Collect the Producer's output: the generated XML prompt.

### Phase 3: CRITIQUE (Critic Subagent)

Dispatch a **separate general-purpose Agent** (model=opus) with this prompt:

```
You are an independent prompt quality critic. Your role is to evaluate
an optimized XML prompt against a rigorous scoring rubric.

ORIGINAL USER MESSAGE:
<raw-input>
{user's exact message}
</raw-input>

GENERATED XML PROMPT:
<generated-prompt>
{Producer's output from Phase 2}
</generated-prompt>

SCORING RUBRIC:
<rubric>
{content of references/scoring-rubric.md}
</rubric>

INSTRUCTIONS:
1. Score each of the 6 dimensions (1-10) using the anchored scale in the rubric
2. For each score, cite SPECIFIC evidence from the generated prompt
3. For any score < 8, explain the specific issue and suggest a concrete fix
4. Calculate the weighted score
5. Set verdict to "accept" if weighted score >= 8.5, "revise" otherwise

OUTPUT: Return the evaluation in the exact XML format specified in the rubric's
"Critic Output Format" section. Include all 6 dimension scores, weighted score,
verdict, and prioritized suggestions.

ANTI-INFLATION RULES:
- Start at 7 and adjust up/down based on evidence
- EVERY score must cite specific content from the prompt
- Missing required sections = automatic 4 or below for structure
- Check if scientific techniques match the task type
- Be genuinely critical — your job is to find weaknesses
```

Collect the Critic's output: structured evaluation with scores and suggestions.

### Phase 4: REVISE + FINAL CRITIQUE

**Parse the Critic's output:**
- Extract the `<weighted-score>` value
- Extract the `<verdict>` (accept/revise)

**If verdict is "accept" (score >= 8.5):** Skip to Phase 5.

**If verdict is "revise" (score < 8.5):**

Dispatch the Producer Agent again with the REVISED prompt:

```
You are an expert prompt engineer. You previously generated an XML prompt
that received a score of {weighted_score}/10.

ORIGINAL USER MESSAGE:
<raw-input>
{user's exact message}
</raw-input>

YOUR PREVIOUS XML PROMPT:
<previous-prompt>
{the generated XML from Phase 2}
</previous-prompt>

CRITIC FEEDBACK:
<feedback>
{Critic's full evaluation output from Phase 3}
</feedback>

INSTRUCTIONS:
1. Address EVERY suggestion marked as priority "high"
2. Improve ALL dimensions that scored below 8
3. Preserve everything that scored 8 or above
4. Return the REVISED complete XML prompt
5. Do NOT explain your changes — just output the revised XML

OUTPUT: Return ONLY the revised XML prompt.
```

After revision, dispatch the Critic Agent one more time for final scoring.

**Convergence rules:**
- Maximum 2 revision rounds total
- Stop if weighted score >= 8.5
- Stop if score improvement < 0.3 between rounds (diminishing returns)

### Phase 5: EXECUTE

**5.1 Summary Banner**

Before executing, output a brief summary to give the user transparency:

```
`★ llm-language ──────────────────────────────`
Applied: {techniques used, e.g., "CoT + ToT + Self-Refine"}
Role: {persona, e.g., "Senior Systems Architect"}
Complexity: {level} | Sub-tasks: {N} | Thinking: ultrathink
Score: {final weighted score}/10 | Rounds: {N}
Skills matched: {relevant skills, or "none"}
`──────────────────────────────────────────────────`
```

**5.2 Execute the Prompt**

Take the final XML prompt and execute it as your working instructions. The XML prompt defines:
- Your role (from `<role>`)
- The task decomposition (from `<task>`)
- The reasoning strategy (from `<methodology>`)
- The output format (from `<output-specification>`)
- Edge cases to handle (from `<edge-cases>`)

Follow the XML prompt as your execution blueprint. Use ultrathink thinking mode.

**5.3 Ephemeral — Do NOT Save**

The XML prompt exists ONLY in the conversation context. Do NOT:
- Write it to any file
- Save it to memory
- Store it anywhere on disk

It is used for this execution only and then discarded.

## Optimization for Simple Tasks

For tasks classified as **simple** in Phase 1.3, use a lightweight pipeline:
- Skip Phase 3 (Critique) and Phase 4 (Revise) entirely
- The Producer generates a minimal XML prompt (only required fields)
- Execute directly with `default` or `extended` thinking (not ultrathink)
- This saves tokens and time for trivial requests

## Token Cost Estimate

The pipeline has overhead proportional to complexity:

| Complexity | Subagents Spawned | Estimated Overhead |
|---|---|---|
| simple | 1 (Producer only) | ~8,000-15,000 tokens |
| moderate | 2-3 (Producer + Critic + optional Revise) | ~30,000-50,000 tokens |
| complex | 3-4 (Producer + Critic + Revise + Final Critique) | ~50,000-80,000 tokens |
| critical | 4 (full pipeline, 2 revision rounds) | ~80,000-120,000 tokens |

This overhead is the cost of maximum precision. For tasks where speed matters more than precision, classify as "simple" to skip the Critique/Revise phases.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Changing user's intent during optimization | Critic dimension 1 (Intent Preservation) catches this |
| Over-engineering simple requests | Use complexity classification to scale the pipeline |
| Prescriptive step-by-step in ultrathink mode | Use general instructions — Claude's thinking exceeds hand-written plans |
| Saving the prompt to disk | Never. Ephemeral only. |
| Using role prompting for factual claims | Use role for style/format alignment, not knowledge claims |
| Running too many revision rounds | Max 2 rounds. Diminishing returns after that. |
| Applying ToT to simple tasks | Match technique to complexity using Decision Matrix |
| Recursive self-invocation | In Phase 1.2, EXCLUDE llm-language from the skill registry. Never recommend invoking llm-language from within a generated XML prompt. |

## Scientific Grounding

This skill is built on findings from 100+ prompt engineering papers. The core principles are documented in `references/scientific-principles.md`. Key references:

- **Meta-Prompting** (Fernando 2023, Suzgun 2024): Using LLMs to optimize their own prompts
- **Self-Refine** (Madaan 2023): Iterative improvement through self-feedback
- **DMAD** (Du 2024, Liang 2024): Diverse multi-agent debate with heterogeneous roles
- **XML Prompting** (Xu 2025, Anthropic 2025): Structured formats reduce hallucination
- **Extended Thinking** (Anthropic 2026): General instructions outperform prescriptive steps
- **Constitutional AI** (Bai 2022): Self-critique against a rubric/constitution

Full bibliography: see `references/scientific-principles.md` § Source Bibliography.
