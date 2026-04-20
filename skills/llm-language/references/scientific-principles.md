# Scientific Prompt Engineering Principles

Reference for the llm-language skill. Each principle includes: citation, when to apply, how to embed in XML, and a transformation example.

---

## Category A: Reasoning Enhancement

### A1. Chain-of-Thought (CoT)

**Citation:** Wei et al., "Chain-of-Thought Prompting Elicits Reasoning in Large Language Models," NeurIPS 2022. Kojima et al., "Large Language Models are Zero-Shot Reasoners," NeurIPS 2022.

**When to apply:** Any task requiring multi-step reasoning, mathematical computation, logical inference, causal analysis, or decision-making with dependencies.

**How to embed:**
```xml
<methodology>
  <reasoning-strategy>chain-of-thought</reasoning-strategy>
  <approach>Decompose the problem step by step. For each step, state the sub-goal, execute, verify, then proceed.</approach>
</methodology>
```

**Transformation:** "Solve this math problem" → "Solve this problem by breaking it into steps. Show your reasoning at each stage before arriving at the final answer."

---

### A2. Tree-of-Thought (ToT)

**Citation:** Yao et al., "Tree of Thoughts: Deliberate Problem Solving with Large Language Models," NeurIPS 2023.

**When to apply:** Ambiguous problems with multiple valid approaches, creative tasks, strategic planning, or tasks where the first reasoning path may be suboptimal. Best for complex/critical complexity levels.

**How to embed:**
```xml
<methodology>
  <reasoning-strategy>tree-of-thought</reasoning-strategy>
  <approach>Generate 2-3 distinct reasoning paths. Evaluate each path's promise. Pursue the most promising, backtrack if stuck. Compare conclusions across paths.</approach>
</methodology>
```

**Transformation:** "Design an authentication system" → "Explore 2-3 architectural approaches (session-based, JWT, OAuth). Evaluate each on security, scalability, and complexity. Select and detail the strongest approach."

---

### A3. Self-Consistency

**Citation:** Wang et al., "Self-Consistency Improves Chain of Thought Reasoning in Language Models," ICLR 2023.

**When to apply:** High-stakes reasoning tasks where confidence matters. When a single reasoning chain might be unreliable. Mathematical proofs, code logic, risk assessment.

**How to embed:**
```xml
<methodology>
  <reasoning-strategy>self-consistency</reasoning-strategy>
  <approach>Reason through the problem via multiple independent paths. Compare conclusions. If paths converge, confidence is high. If they diverge, investigate the disagreement.</approach>
</methodology>
```

---

### A4. Least-to-Most Prompting

**Citation:** Zhou et al., "Least-to-Most Prompting Enables Complex Reasoning in Large Language Models," ICLR 2023.

**When to apply:** Complex tasks that can be naturally ordered from simple to hard sub-problems. Tasks where later steps depend on earlier answers.

**How to embed:**
```xml
<task>
  <sub-tasks>
    <sub-task order="1" priority="high">Simplest component first</sub-task>
    <sub-task order="2" priority="high">Build on sub-task 1 result</sub-task>
    <sub-task order="3" priority="medium">Final synthesis using all prior results</sub-task>
  </sub-tasks>
</task>
```

---

### A5. Graph of Thoughts (GoT) & Adaptive GoT (AGoT) — v4.0

**Citation:** Besta et al., "Graph of Thoughts: Solving Elaborate Problems with Large Language Models," AAAI 2024. AGoT: arXiv 2502.05078, 2026.

**When to apply:** Problems with non-linear dependencies (aggregation, backtracking). AGoT adds SELECTIVE expansion of only uncertain nodes — avoids exhaustive tree exploration.

**Key result:** AGoT +46.2% on GPQA, matching RL-heavy gains without training.

**How to embed:**
```xml
<methodology>
  <reasoning-strategy>adaptive-graph-of-thought</reasoning-strategy>
  <approach>Build a DAG of sub-problems. For each node, assess certainty. Expand only LOW-certainty branches. Aggregate results upward.</approach>
</methodology>
```

---

### A6. Atom of Thoughts (AoT) — v4.0

**Citation:** "Atom of Thoughts for Markov LLM Test-Time Scaling," arXiv 2502.12018, 2026.

**When to apply:** Complex reasoning that benefits from convergent decomposition — reducing a problem to indivisible atomic sub-questions. Unlike CoT (which accumulates history), AoT progressively REDUCES test-time complexity.

**Key insight:** Each reasoning state is a DAG of subquestions that contracts into a single answer-equivalent atomic question.

**How to embed:**
```xml
<methodology>
  <reasoning-strategy>atom-of-thought</reasoning-strategy>
  <approach>Decompose the problem into a DAG of subquestions. Contract dependent subquestions until reaching atomic (indivisible) units. Solve atoms first, then reconstruct the original answer.</approach>
</methodology>
```

---

## Category B: Self-Improvement & Reflection

### B1. Self-Refine

**Citation:** Madaan et al., "Self-Refine: Iterative Refinement with Self-Feedback," NeurIPS 2023.

**When to apply:** Any generative task where quality can be improved iteratively. Writing, code generation, design decisions. Core mechanism of the llm-language critique cycle.

**How to embed:** This is the architectural backbone of llm-language. The Generate → Critique → Revise cycle IS Self-Refine applied to prompt engineering.

---

### B2. Reflexion

**Citation:** Shinn et al., "Reflexion: Language Agents with Verbal Reinforcement Learning," NeurIPS 2023.

**When to apply:** When past failures or feedback should inform the current attempt. When the model should learn from its own mistakes within a session.

**How to embed:**
```xml
<context>
  <prior-feedback>In previous attempts, [specific failure]. Avoid this by [correction].</prior-feedback>
</context>
```

---

### B3. Constitutional AI Principles

**Citation:** Bai et al., "Constitutional AI: Harmlessness from AI Feedback," 2022.

**When to apply:** Always — as a self-critique layer. Ensures generated prompts are helpful, harmless, and honest. Embedded in the Critic agent's evaluation.

**How to embed:** The Critic agent evaluates prompts against a rubric (intent preservation, precision, completeness) which functions as a "constitution" for prompt quality.

---

## Category C: Structural Optimization

### C1. XML Structured Prompting

**Citation:** Anthropic, "Use XML tags to structure your prompts," Claude API Docs 2025. Xu et al., "XML Prompting as Grammar-Constrained Interaction," arXiv 2509.08182, 2025.

**When to apply:** Always for Claude models. XML is the native structured format for Anthropic's models, trained extensively on markup structures.

**Benefits:** Reduces hallucination, improves parsing accuracy, enables hierarchical instruction, aligns with Claude's training distribution.

**How to embed:** The entire llm-language output IS an XML-structured prompt. Every section is wrapped in semantic XML tags.

---

### C2. Instruction Hierarchy

**Citation:** Wallace et al., "The Instruction Hierarchy: Training LLMs to Prioritize Privileged Instructions," 2024.

**When to apply:** When prompts contain multiple levels of instruction that might conflict. Establish clear priority ordering.

**How to embed:**
```xml
<task>
  <primary-objective>MUST do this — non-negotiable</primary-objective>
  <secondary-objectives>SHOULD do these if possible</secondary-objectives>
  <preferences>MAY follow these if no conflict with above</preferences>
</task>
```

---

### C3. Few-Shot Exemplars

**Citation:** Brown et al., "Language Models are Few-Shot Learners," NeurIPS 2020. Revisited by Min et al., 2022.

**When to apply:** When the desired output format is non-obvious. When the task type benefits from concrete demonstrations. Less critical for instruction-tuned models but still valuable for format specification.

**How to embed:**
```xml
<output-specification>
  <example>
    <input>Explain recursion</input>
    <output>Recursion is when a function calls itself...</output>
  </example>
</output-specification>
```

**Note:** For Opus 4.6, include thinking traces inside few-shot examples to guide extended thinking patterns (Anthropic recommendation).

---

## Category D: Meta-Techniques

### D1. Meta-Prompting

**Citation:** Fernando et al., "Promptbreeder: Self-Referential Self-Improvement via Prompt Evolution," 2023. Suzgun & Kalai, "Meta-Prompting: Enhancing Language Models with Task-Agnostic Scaffolding," 2024.

**When to apply:** This IS the llm-language skill. Meta-prompting is the use of an LLM to generate/optimize prompts for itself. The entire skill is a meta-prompting system.

**Key insight:** GPT-4 with meta-prompting solved 100% of Game of 24 puzzles with one-pass reasoning, outperforming alternatives by 15-17%.

---

### D2. Automatic Prompt Engineering (APE)

**Citation:** Zhou et al., "Large Language Models Are Human-Level Prompt Engineers," ICLR 2023. Survey: Li et al., "A Systematic Survey of Automatic Prompt Optimization Techniques," EMNLP 2025.

**When to apply:** Systematically optimizing prompt descriptions for triggering accuracy. The APE framework generates prompt candidates, evaluates them, and selects the best performer.

**How to embed:** The skill's description optimization step uses APE principles — generate multiple prompt formulations, evaluate against test cases, select highest-performing.

---

### D3. Decomposed Prompting (DecomP)

**Citation:** Khot et al., "Decomposed Prompting: A Modular Approach for Solving Complex Tasks," ICLR 2023.

**When to apply:** Complex tasks that involve multiple distinct capabilities. Each sub-task is delegated to a specialized handler (which may itself be an LLM with a different prompt or a tool).

**How to embed:**
```xml
<task>
  <sub-tasks>
    <sub-task order="1" handler="research-agent">Gather context</sub-task>
    <sub-task order="2" handler="code-agent">Implement solution</sub-task>
    <sub-task order="3" handler="review-agent">Verify quality</sub-task>
  </sub-tasks>
</task>
```

---

### D4. Buffer of Thoughts (BoT) — v4.0

**Citation:** "Buffer of Thoughts: Thought-Augmented Reasoning with Large Language Models," NeurIPS 2024 Spotlight, arXiv 2406.04271.

**When to apply:** Tasks that recur in shape. BoT maintains a persistent **meta-buffer of thought-templates** distilled from past successful problems. A buffer-manager updates the buffer as new tasks are solved.

**Key results:** +11% Game of 24, +20% Geometric Shapes, +51% Checkmate-in-One at 12% of multi-query cost.

**llm-language mapping:** ROSETTA.md's `thought_templates` section IS the meta-buffer. After each successful optimization, the buffer-manager distills the generalizable template (trigger_pattern, template, hit_count, last_success) and appends to ROSETTA.

**How to embed:**
```xml
<context>
  <memory-context>
    <thought-templates>{if match found in meta-buffer, inject template}</thought-templates>
  </memory-context>
</context>
<methodology>
  <reasoning-strategy>buffer-of-thought</reasoning-strategy>
  <approach>Retrieve matching thought-template from meta-buffer (if hit_count > 3 and last_success recent). Adapt template to current task. If no match, proceed with primary strategy and distill a new template after execution.</approach>
</methodology>
```

---

### D5. Meta-Reasoner Bandit — v4.0

**Citation:** "Meta-Reasoner: Dynamic Guidance for Optimized Inference-time Reasoning in LLMs," arXiv 2502.19918, 2026.

**When to apply:** When strategy selection is non-trivial. Replaces fixed heuristics with a **contextual multi-armed bandit** over reasoning strategies. Each strategy is an arm; the bandit learns Thompson priors per task-class.

**Arms in llm-language:** {single-pass, debate, BoT-retrieve, AoT-decompose, deep-research}

**Update rule:** on success (score ≥ 9.3 + user satisfied): α += 1. On failure: β += 1. Sample via Thompson: posterior ~ Beta(α, β), pull the arm with highest sampled value.

**How to embed:**
```xml
<meta>
  <selected-techniques>D5-MetaReasoner</selected-techniques>
</meta>
<methodology>
  <reasoning-strategy>{arm selected by bandit}</reasoning-strategy>
  <strategy-fallback>If primary strategy hits deadlock, fall back to second-highest posterior arm.</strategy-fallback>
</methodology>
```

---

### D7. Skill-Level Meta-Refinement — v4.1 NEW

**Citation:** Madaan et al. "Self-Refine" (NeurIPS 2023) extended to skill-artifact level. Inspired by PromptWizard (Microsoft 2024, arXiv:2405.18369) generalized from prompt-level to skill-level refinement.

**When to apply:** Continuously, via Phase 7 of the main llm-language pipeline AND on explicit invocation of `/llm-language:refine-skills`. The same Generate→Critique→Refine cycle that improves prompts is now applied to the skills themselves.

**Rationale:** Skills are load-bearing artifacts in the Claude Code ecosystem. Stale skills (using deprecated `thinking="ultrathink"`, emphasis markers, missing `effort` frontmatter) silently degrade output quality across every invocation. Applying self-refine AT the skill level (not just the prompt level) propagates improvements across every future prompt that uses that skill.

**Rubric:** 10 quality dimensions (see `references/skill-quality-rubric.md`). Threshold 8.0 for "working at best".

**Fix classification** (see `references/skill-fixer-patterns.md`):
- SAFE: auto-apply with backup (deprecated syntax, emphasis strip, frontmatter add)
- RISKY: propose with user approval (restructure, rewrite)
- FORBIDDEN: report only (third-party plugins, Claude Code built-ins, llm-language itself)

**Safety guarantees:**
- Backup before every auto-fix (`.backup-<timestamp>.md` sibling)
- Audit trail in auto-memory (`skill-refinement-audit.md`)
- Rollback via `/llm-language:refine-skills rollback <skill>`
- Never modifies upstream-owned skills (marketplace plugins)
- Recursive self-modification blocked (llm-language skills excluded)

**How to embed:**
```xml
<pipeline>
  <!-- Phase 7 runs after main pipeline + memory updates -->
  <phase-7-skill-audit>
    <scope>user-owned-only</scope>
    <rubric>references/skill-quality-rubric.md</rubric>
    <auto-fix>safe-only</auto-fix>
    <log-to>auto-memory/skill-refinement-audit.md</log-to>
  </phase-7-skill-audit>
</pipeline>
```

**Key insight:** Skills are to prompts as libraries are to functions — refining a skill propagates to every prompt that uses it. Meta-refinement has O(skill_count) cost but O(skill_count × invocation_count) benefit.

---

### D6. Error-Taxonomy-Guided Optimization — v4.0

**Citation:** "Error-Taxonomy-Guided Prompt Optimization," arXiv 2602.00997, 2026.

**When to apply:** After observing a failure pattern — classify the failure class (ambiguity, missing context, wrong register, scale mismatch, etc.) and route to a class-specific fixer.

**How to embed:** ROSETTA.md maintains `failure_taxonomy` section with `classes: [...]` and `per_class_fixer: {...}`. When Critic assigns low score on a dimension, look up the failure class and apply the mapped fixer prompt during revision.

---

## Category E: Multi-Agent Techniques

### E1. Multi-Agent Debate (MAD)

**Citation:** Du et al., "Improving Factuality and Reasoning in Language Models through Multiagent Debate," ICML 2024. Smit et al., "Should We Be Going MAD?," ICML 2024.

**When to apply:** When factual accuracy and reasoning quality are critical. When diverse perspectives can catch blind spots.

**Caveat (IMPORTANT):** Recent evaluations show MAD does NOT consistently outperform Self-Consistency on benchmarks. Use the Diverse MAD (DMAD) variant — heterogeneous agent roles (Producer vs Critic) consistently outperform homogeneous debate.

**How to embed:** The llm-language pipeline uses DMAD: Producer (generator role) and Critic (evaluator role) are heterogeneous, not identical debaters.

---

### E2. Diverse Multi-Agent Debate (DMAD)

**Citation:** Liang et al., "Encouraging Divergent Thinking in Large Language Models through Multi-Agent Debate," 2024.

**When to apply:** When standard debate produces groupthink. Assign distinct perspectives/roles to each agent.

**How to embed:** In llm-language, the Producer focuses on *generation quality* while the Critic focuses on *evaluation accuracy*. They have different rubrics and different success criteria.

---

## Category F: Model-Specific (Opus 4.6)

### F1. Adaptive Thinking (Opus 4.7) — v4.0 UPDATED

**Citation:** Anthropic, "Adaptive Thinking," Claude API Docs 2026. Replaces extended thinking with manual `budget_tokens` (removed on Opus 4.7).

**When to apply:** Complex reasoning, architecture design, novel problem-solving, research synthesis. On Opus 4.7, adaptive thinking is the ONLY supported thinking mode; manual `thinking: {type: "enabled", budget_tokens: N}` returns 400.

**Key guidance from Anthropic (2026):**
- Claude dynamically decides when and how much to use extended thinking based on request complexity
- `effort` parameter controls thinking depth (low/medium/high/xhigh/max)
- Automatically enables interleaved thinking (between tool calls)
- Prefer general instructions over prescriptive steps — adaptive thinking exceeds human-designed scaffolding
- At `high` (default) and `max` effort, Claude almost always thinks
- At lower levels, Claude may skip thinking for simpler problems
- `display: "summarized"` or `"omitted"` (default on 4.7) — add `display: "summarized"` for visible reasoning

**How to embed (Opus 4.7):**
```xml
<llm-prompt model="claude-opus-4-7" effort="xhigh" thinking="adaptive">
  <!-- effort signals how deeply to reason -->
</llm-prompt>
```

**Backward-compat (Opus 4.6):**
```xml
<llm-prompt model="claude-opus-4-6" thinking="ultrathink">
  <!-- legacy attribute, still works on 4.6 -->
</llm-prompt>
```

---

### F4. xhigh Effort Level (Opus 4.7 only) — v4.0 NEW

**Citation:** Anthropic, "Effort Parameter," Claude API Docs 2026. Introduced April 16, 2026 with Opus 4.7.

**When to apply:** Coding and agentic work requiring extended exploration (repeated tool calls, detailed web/KB search, long-horizon coding over 30+ minutes). Anthropic-recommended starting point for most complex tasks on Opus 4.7.

**Key insight:** Sits between `high` and `max` — strictly more than high, strictly less than max. Meaningfully higher token usage than high but better cost/quality tradeoff than max for typical workloads.

**How to embed:**
```xml
<llm-prompt model="claude-opus-4-7" effort="xhigh">
  <max-tokens-hint>64000</max-tokens-hint>  <!-- minimum headroom for xhigh -->
</llm-prompt>
```

---

### F5. Max Effort — v4.0 UPDATED

**Citation:** Anthropic, "Effort Parameter," Claude API Docs 2026.

**When to apply:** Genuinely frontier problems where absolute maximum capability is needed. On Opus 4.7, max "adds significant cost for relatively small quality gains on most workloads and on some structured-output tasks can lead to overthinking."

**Guideline:** Use `xhigh` by default. Escalate to `max` only when evals show measurable quality headroom beyond xhigh.

**How to embed:**
```xml
<llm-prompt model="claude-opus-4-7" effort="max">
  <max-tokens-hint>128000</max-tokens-hint>
</llm-prompt>
```

---

### F6. Task Budgets (Beta) — v4.0 NEW

**Citation:** Anthropic, "Task Budgets," Claude API Docs 2026 (beta header `task-budgets-2026-03-13`).

**When to apply:** Multi-turn agentic workflows where Claude makes many tool calls before finalizing. Advisory token budget across full agentic loop (thinking + tools + output). Claude sees a running countdown and paces itself.

**Key properties:**
- Minimum: 20,000 tokens
- Soft hint, NOT hard cap (unlike max_tokens)
- Distinct from max_tokens (per-request vs agentic-loop-wide)
- Too-small budget causes refusal-like behavior (Claude scopes down or declines)
- Not supported on Claude Code at launch — only via Messages API

**How to embed:**
```xml
<meta>
  <task-budget type="tokens" total="200000" />
</meta>
```

---

### F7. Literal Instruction Following (Opus 4.7) — v4.0 NEW

**Citation:** Anthropic, "Migrating to Claude Opus 4.7," Claude API Docs 2026.

**When to apply:** Always, when generating prompts for Opus 4.7. The model interprets instructions literally and will not silently generalize from one item to another.

**Key behaviors:**
- Response length calibrates to perceived task complexity (no fixed verbosity default)
- Fewer tool calls by default — raising effort increases tool usage
- Fewer subagents spawned by default — steer via explicit prompting
- More direct, opinionated tone (less validation-forward than 4.6)
- More regular progress updates in long agentic traces

**Prompt rewriting rules (enforced by Producer v4.0):**
1. De-duplicate: each directive stated ONCE
2. Positive framing: "do Y" > "don't do X"
3. Strip emphasis markers: remove "VERY IMPORTANT", "MUST", repeated caps
4. Concise role: ONE sentence, not paragraph
5. Explicit parallelism: state "dispatch in parallel" when independent
6. Remove manual "let's think step by step" — adaptive thinking handles CoT
7. Output format explicit when length matters

---

### F2. Claude-Specific XML Best Practices

**Citation:** Anthropic, "Prompting Best Practices," Claude API Docs 2025.

**Key rules:**
1. Use consistent tag names throughout prompts
2. Nest tags for hierarchical content
3. Place critical instructions at the beginning and end of the prompt (primacy/recency)
4. Be explicit — Claude 4.x responds to precise instructions
5. Explain WHY, not just WHAT — Claude has strong theory of mind
6. Define output format precisely — show, don't just tell
7. Request "above and beyond" behavior explicitly

---

### F3. Context Window Optimization

**When to apply:** When injecting large amounts of context (skill registries, code, documents).

**Key rules:**
- Place most important context near the beginning and end (primacy/recency effect)
- Use XML tags to separate context sections clearly
- Summarize large contexts rather than including verbatim when possible
- Opus 4.6 has 1M context — use it for comprehensive context, but don't dilute with noise

---

## Category G: Robustness & Calibration

### G1. Adversarial Prompting for Robustness

**When to apply:** When the prompt must handle edge cases and unexpected inputs gracefully.

**How to embed:**
```xml
<edge-cases>
  <case>If the input is ambiguous, ask for clarification rather than assuming</case>
  <case>If the task is impossible, explain why rather than producing garbage</case>
  <case>If multiple valid interpretations exist, address the most likely one first</case>
</edge-cases>
```

---

### G2. Calibration & Confidence

**When to apply:** When the model's confidence level matters for downstream decisions.

**How to embed:**
```xml
<output-specification>
  <quality-bar>
    If uncertain about any claim, flag it explicitly with confidence level.
    Prefer precise, narrow claims over vague, broad ones.
  </quality-bar>
</output-specification>
```

---

## Category H: Adaptive Memory & User Modeling (v2.0)

### H1. Episodic Memory for LLM Agents

**Citation:** Zhang et al., "Memory in Large Language Models: Mechanisms, Evaluation and Evolution," arXiv 2025. Survey: ACM TOIS 2025.

**When to apply:** Always — via ROSETTA.md. Episodic memory is a persistent state written at inference time that systematically influences model outputs.

**How to embed:** ROSETTA.md captures interaction episodes (technique used, score, user response) and feeds them back into subsequent prompts as `<rosetta-context>`.

---

### H2. Preference Learning & Personalization

**Citation:** Hannah et al., "PersonalLLM: Tailoring LLMs to Individual Preferences," ICLR 2025. Survey: "A Survey of Personalized Large Language Models," arXiv 2502.11528, 2025.

**When to apply:** Always — the system accumulates interaction data to provide maximal benefits for this individual user. Preferences are inferred from corrections, satisfaction signals, and explicit feedback.

**Key insight:** A personalized model should adapt to the preferences and needs of a particular user and provide maximal benefits as it accumulates interactions.

---

### H3. Self-Evolving Prompt Optimization

**Citation:** Agarwal et al., "PromptWizard: Task-Aware Agent-driven Prompt Optimization Framework," Microsoft Research, arXiv:2405.18369, 2024.

**When to apply:** Core mechanism of llm-language v2.0. The system iteratively generates, critiques, and refines prompts through feedback-driven synthesis, with learnings persisted across sessions via ROSETTA.md.

**Key insight:** PromptWizard achieved superior performance across 45 tasks through self-evolving feedback loops. Our ROSETTA.md extends this to cross-session persistence.

---

### H4. Human Feedback Integration for Prompt Optimization

**Citation:** Chen et al., "PROMST: PRompt Optimization in Multi-Step Tasks," EMNLP 2024 (Oral, Top 3%).

**When to apply:** When the user provides corrections or feedback that should inform future prompt generation. ROSETTA.md captures these signals.

**Key insight:** Human-designed feedback rules automatically offer direct suggestions for improvement, achieving 10-29% gains over baseline methods.

---

### H5. Cross-Session Personalization

**Citation:** PLUM (ACL 2025): "On the Way to LLM Personalization: Learning to Remember User Conversations."

**When to apply:** Every session — ROSETTA.md IS the cross-session memory. It enables the system to personalize by remembering prior conversation patterns, even across restarts.

---

### H6. Reflective Memory Management

**Citation:** RMM framework, Survey on Memory Mechanisms in LLM-Based Agents, 2025.

**When to apply:** When ROSETTA.md approaches its size limit (300 lines). RMM constructs memory at adaptive granularities and refines retrieval using feedback from response citations. We apply this by consolidating older ROSETTA entries — merging similar patterns, removing outdated ones.

---

### H7. File-System Auto-Memory (Claude Code 2026) — v4.0 NEW

**Citation:** Anthropic, "How Claude remembers your project," Claude Code Docs 2026. Available from Claude Code v2.1.59+.

**When to apply:** Always when running inside Claude Code. Auto-memory complements ROSETTA.md with project-level machine-local learnings at `~/.claude/projects/<project>/memory/`.

**Distinction:**
- **ROSETTA.md** (user-authored, cross-project, version-controllable) — user style, optimization heuristics, BoT templates, bandit state
- **auto-memory** (Claude-authored, per-repo, machine-local) — build commands, debugging insights, architecture decisions, user corrections

**Structure:**
- `MEMORY.md` — concise index (first 200 lines / 25KB auto-loaded per session)
- Topic files — loaded on demand
- Four memory types via frontmatter `type:` field: `user | feedback | project | reference`

**Key rules:**
- MEMORY.md entries ≤ 150 chars (pointers, not content)
- Topic files carry full content
- Survives `/compact` — re-loaded after summarization
- Subagents can maintain own memory (v2.1.33+) via `memory: user|project|local` frontmatter

**How llm-language integrates:**
- Phase 0.B: load auto-memory alongside ROSETTA
- Phase 6c: write typed memories after execution
- PreCompact hook: snapshot ROSETTA session state to auto-memory (write-then-allow, never block)

---

### H8. Memory Tool API (Anthropic 2026) — v4.0 NEW

**Citation:** Anthropic, "Memory Tool," Claude API Docs 2026. Tool type `memory_20250818`.

**When to apply:** For SDK-based agent deployments outside Claude Code. Client-side tool — developer implements storage backend (file/DB/cloud/encrypted). Commands: `view`, `create`, `str_replace`, `insert`, `delete`, `rename`. Path-scoped to `/memories`.

**Key properties:**
- Reported results: +39% on agentic search when combined with context editing; 84% token reduction in 100-turn web search
- Pairs with context editing (client-side) and compaction (server-side)
- ZDR eligible
- Path traversal protection mandatory (validator)

**When not applicable:** Inside Claude Code. Claude Code uses file-system auto-memory (H7) instead.

---

### H9. Agentic Memory (A-MEM, Zettelkasten-inspired) — v4.0 NEW

**Citation:** "A-MEM: Agentic Memory for LLM Agents," NeurIPS 2025, arXiv 2502.12110.

**When to apply:** When memory needs to auto-organize with dynamic linking. Each memory generates its own attributes, auto-links to similar entries, and evolves based on access patterns — a Zettelkasten pattern for LLMs.

**llm-language integration:** Inspiration for the Auto-Dream consolidation pattern (4-phase Orient → Search → Consolidate → Re-index) exposed as `/llm-language:consolidate`.

---

### H10. Memory-R1 (RL-trained memory operations) — v4.0 NEW

**Citation:** "Memory-R1: Reinforcement Learning for Memory Management in LLM Agents," arXiv 2508.19828, 2025.

**When to apply:** When memory store/update/delete should be optimized from feedback. Memory-R1 learns WHICH memories are worth keeping via RL — future direction for llm-language Jarvis autonomous phase.

---

### H11. ACON (Failure-Driven Context Compression) — v4.0 NEW

**Citation:** "ACON: Optimizing Context Compression for Long-running Agentic Workflows," ICLR 2026.

**When to apply:** When token pressure is high and compression is needed. ACON uses failure-driven task-aware compression — identify what historically mattered for this task class, preserve that, compress the rest.

**llm-language mapping:** ROSETTA-300-line-limit consolidation uses ACON principles — preserve high hit_count templates, merge similar, drop stale.

---

## Quick Decision Matrix

| Task Type | Primary Technique | Secondary | Thinking Level |
|---|---|---|---|
| Simple factual | Direct instruction | — | quick/default |
| Multi-step reasoning | CoT | Self-Consistency | extended |
| Ambiguous/creative | ToT | DMAD | ultrathink |
| Code generation | Decomposition | Self-Refine | extended |
| Architecture/design | ToT + Decomposition | Reflexion | ultrathink |
| Analysis/research | CoT + Retrieval-Aug + WebSearch | Calibration | ultrathink |
| Writing/editing | Role + Self-Refine | Few-shot + ROSETTA | high |
| Debugging | Reflexion + CoT | Adversarial | high |
| Complex multi-part | Least-to-Most + DecomP | Meta-Prompting | xhigh |
| Returning user topic | ROSETTA-guided + BoT-retrieve | Prior effective technique | xhigh |
| Novel hard problem (v4.0) | AoT + BoT + Meta-Reasoner | Deep-research | max |
| Agentic multi-hour (v4.0) | DecomP + Task Budget | Agent Teams (if cross-cutting) | xhigh |
| >100k context (v4.0) | CoT + MRCR guard | Quote verification | xhigh |

**v4.0 Opus 4.7 effort mapping:**
- Replace `ultrathink` references with `max` (effort parameter)
- Replace `extended` references with `high` or `xhigh`
- Replace `default` with `medium`
- On Opus 4.6 / Sonnet 4.6, legacy `thinking="ultrathink"` still works

---

## Source Bibliography (125+ papers synthesized — v4.0)

The principles above synthesize findings from the following major works and surveys:

1. Wei et al. (2022) — Chain-of-Thought Prompting, NeurIPS
2. Kojima et al. (2022) — Zero-Shot CoT, NeurIPS
3. Wang et al. (2023) — Self-Consistency, ICLR
4. Yao et al. (2023) — Tree of Thoughts, NeurIPS
5. Zhou et al. (2023a) — Least-to-Most Prompting, ICLR
6. Zhou et al. (2023b) — Large Language Models Are Human-Level Prompt Engineers (APE), ICLR
7. Fernando et al. (2023) — Promptbreeder, arXiv
8. Suzgun & Kalai (2024) — Meta-Prompting, arXiv
9. Bai et al. (2022) — Constitutional AI, arXiv
10. Madaan et al. (2023) — Self-Refine, NeurIPS
11. Shinn et al. (2023) — Reflexion, NeurIPS
12. Khot et al. (2023) — Decomposed Prompting, ICLR
13. Du et al. (2024) — Multiagent Debate, ICML
14. Liang et al. (2024) — Divergent Thinking via Multi-Agent Debate
15. Smit et al. (2024) — Should We Be Going MAD?, ICML
16. Brown et al. (2020) — GPT-3 Few-Shot Learning, NeurIPS
17. Min et al. (2022) — Rethinking Few-Shot Exemplars
18. Wallace et al. (2024) — Instruction Hierarchy
19. White et al. (2023) — Prompt Pattern Catalog, arXiv
20. Xu et al. (2025) — XML Prompting Fixed-Point Semantics, arXiv
21. Li et al. (2025) — Survey of Automatic Prompt Optimization, EMNLP
22. Schulhoff et al. (2024) — Prompt Engineering Survey (50+ techniques)
23. Anthropic (2025-2026) — Claude Prompting Best Practices, Extended Thinking Tips
24. Reynolds & McDonell (2021) — Prompt Programming for LLMs
25. Meincke et al. (2025) — Persuasion Principles for LLM Alignment
26. SwarmPrompt (2025) — Swarm Intelligence for Prompt Optimization
27. CFPO (2025) — Content-Format Integrated Prompt Optimization
28. GAAPO (2025) — Genetic Algorithm Applied to Prompt Optimization
29. Hannah et al. (2025) — PersonalLLM: Tailoring LLMs to Individual Preferences, ICLR
30. Agarwal et al. (2024) — PromptWizard: Task-Aware Prompt Optimization, Microsoft Research
31. Chen et al. (2024) — PROMST: PRompt Optimization in Multi-Step Tasks, EMNLP (Oral, Top 3%)
32. PLUM (2025) — Cross-Session Personalization via Conversation Memory, ACL
33. Zhang et al. (2025) — Memory in LLMs: Mechanisms, Evaluation and Evolution, arXiv
34. RMM (2025) — Reflective Memory Management for LLM Agents
35. Nemori (2025) — Self-Organizing Episodic Memory with Prediction-Calibration Loops
36. Survey on Memory Mechanisms in LLM-Based Agents (2025) — ACM TOIS

Plus 72+ additional papers referenced in the surveys by Schulhoff et al. (2024), Li et al. (2025), and the TechRxiv comprehensive survey (2025), covering: retrieval-augmented prompting, active prompting, directional stimulus prompting, program-aided language models, graph-of-thought, skeleton-of-thought, analogical prompting, emotion prompting, rephrase-and-respond, step-back prompting, contrastive CoT, thread-of-thought, and more.

---

## v4.0 Additions (2026 papers + Anthropic docs)

37. Besta et al. (2024) — Graph of Thoughts, AAAI
38. Atom of Thoughts (2026) — Markov LLM Test-Time Scaling, arXiv 2502.12018
39. Buffer of Thoughts (2024) — Thought-Augmented Reasoning, NeurIPS Spotlight, arXiv 2406.04271
40. Adaptive Graph of Thoughts (2026) — Selective Expansion, arXiv 2502.05078
41. Meta-Reasoner (2026) — Dynamic Guidance via Contextual Bandit, arXiv 2502.19918
42. Error-Taxonomy-Guided Prompt Optimization (2026) — arXiv 2602.00997
43. Prompt Optimization Is a Coin Flip (2026) — arXiv 2604.14585 (cautionary: 9% adoption, high variance)
44. Decreasing Value of CoT (2025) — Prompting Science Report 2, arXiv 2506.07142
45. DST Domain-Specialized ToT (2026) — arXiv 2603.20267
46. DSPy 2026 — Declarative Signatures, arXiv 2604.04869
47. A-RAG (2026) — Agentic Retrieval with Tool Granularity, arXiv 2602.03442
48. Adaptive RAG 2026 — arXiv 2604.15621
49. DynaDebate + Debating Truth (2025-2026) — arXiv 2507.19090
50. A-MEM (NeurIPS 2025) — Agentic Memory for LLM Agents, arXiv 2502.12110
51. Memory-R1 (2025) — RL for Memory Operations, arXiv 2508.19828
52. ACON (ICLR 2026) — Context Compression
53. Memory in the Age of AI Agents (2025) — arXiv 2512.13564
54. MemoryAgentBench / MemBench / MemoryArena (2026) — arXiv 2603.07670
55. Anthropic (2026) — Claude Opus 4.7 Launch Announcement
56. Anthropic (2026) — What's New in Claude Opus 4.7, Claude API Docs
57. Anthropic (2026) — Effort Parameter, Claude API Docs
58. Anthropic (2026) — Adaptive Thinking, Claude API Docs
59. Anthropic (2026) — Task Budgets (beta), Claude API Docs
60. Anthropic (2026) — Memory Tool, Claude API Docs (memory_20250818)
61. Anthropic (2026) — How Claude Remembers Your Project, Claude Code Docs
62. Anthropic (2026) — Migrating to Claude Opus 4.7, Claude API Docs
63. Anthropic (2026) — Effective Harnesses for Long-Running Agents, Engineering Blog
64. Anthropic (2026) — Effective Context Engineering for AI Agents, Engineering Blog
65. Claude Code Changelog (2026) — v2.1.69–v2.1.111 (PreCompact hook, monitors, Agent Teams, /ultrareview)
66. Simon Willison (2026) — System Prompt Changes Between Opus 4.6 and 4.7
67. OpenAI Agents SDK (2025-2026) — Handoff + Guardrails + Responses API
68. Google ADK + A2A Protocol (2026) — Vendor-neutral inter-agent protocol
69. Microsoft Agent Framework (2026) — AutoGen/AG2 + Semantic Kernel merge, GA Q1 2026
70. CrewAI (2026) — Role+Goal+Backstory scaffold
71. LangGraph (2026) — State Machine with Checkpointed Memory

**Total: ~125 primary references + 72+ surveyed = 197+ papers/sources**
