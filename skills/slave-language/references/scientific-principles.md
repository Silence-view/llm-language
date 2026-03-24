# Scientific Prompt Engineering Principles

Reference for the slave-language skill. Each principle includes: citation, when to apply, how to embed in XML, and a transformation example.

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

## Category B: Self-Improvement & Reflection

### B1. Self-Refine

**Citation:** Madaan et al., "Self-Refine: Iterative Refinement with Self-Feedback," NeurIPS 2023.

**When to apply:** Any generative task where quality can be improved iteratively. Writing, code generation, design decisions. Core mechanism of the slave-language critique cycle.

**How to embed:** This is the architectural backbone of slave-language. The Generate → Critique → Revise cycle IS Self-Refine applied to prompt engineering.

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

**How to embed:** The entire slave-language output IS an XML-structured prompt. Every section is wrapped in semantic XML tags.

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

**When to apply:** This IS the slave-language skill. Meta-prompting is the use of an LLM to generate/optimize prompts for itself. The entire skill is a meta-prompting system.

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

## Category E: Multi-Agent Techniques

### E1. Multi-Agent Debate (MAD)

**Citation:** Du et al., "Improving Factuality and Reasoning in Language Models through Multiagent Debate," ICML 2024. Smit et al., "Should We Be Going MAD?," ICML 2024.

**When to apply:** When factual accuracy and reasoning quality are critical. When diverse perspectives can catch blind spots.

**Caveat (IMPORTANT):** Recent evaluations show MAD does NOT consistently outperform Self-Consistency on benchmarks. Use the Diverse MAD (DMAD) variant — heterogeneous agent roles (Producer vs Critic) consistently outperform homogeneous debate.

**How to embed:** The slave-language pipeline uses DMAD: Producer (generator role) and Critic (evaluator role) are heterogeneous, not identical debaters.

---

### E2. Diverse Multi-Agent Debate (DMAD)

**Citation:** Liang et al., "Encouraging Divergent Thinking in Large Language Models through Multi-Agent Debate," 2024.

**When to apply:** When standard debate produces groupthink. Assign distinct perspectives/roles to each agent.

**How to embed:** In slave-language, the Producer focuses on *generation quality* while the Critic focuses on *evaluation accuracy*. They have different rubrics and different success criteria.

---

## Category F: Model-Specific (Opus 4.6)

### F1. Extended Thinking / Ultrathink

**Citation:** Anthropic, "Building with Extended Thinking," Claude API Docs 2025-2026.

**When to apply:** Complex reasoning, architecture design, novel problem-solving, research synthesis. Opus 4.6 allocates ~32,000 thinking tokens in ultrathink mode.

**Key guidance from Anthropic:**
- Prefer general instructions over prescriptive steps — "think thoroughly" outperforms hand-written step-by-step plans
- Use thinking traces in few-shot examples to guide reasoning patterns
- Not every task benefits — simple tasks just take longer without quality improvement
- Match thinking level to complexity: quick → default → extended → ultrathink

**How to embed:**
```xml
<slave-prompt thinking="ultrathink">
  <!-- The thinking attribute signals maximum reasoning depth -->
</slave-prompt>
```

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

## Quick Decision Matrix

| Task Type | Primary Technique | Secondary | Thinking Level |
|---|---|---|---|
| Simple factual | Direct instruction | — | quick/default |
| Multi-step reasoning | CoT | Self-Consistency | extended |
| Ambiguous/creative | ToT | DMAD | ultrathink |
| Code generation | Decomposition | Self-Refine | extended |
| Architecture/design | ToT + Decomposition | Reflexion | ultrathink |
| Analysis/research | CoT + Retrieval-Aug | Calibration | ultrathink |
| Writing/editing | Role + Self-Refine | Few-shot | extended |
| Debugging | Reflexion + CoT | Adversarial | extended |
| Complex multi-part | Least-to-Most + DecomP | Meta-Prompting | ultrathink |

---

## Source Bibliography (100+ papers synthesized)

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

Plus 72+ additional papers referenced in the surveys by Schulhoff et al. (2024), Li et al. (2025), and the TechRxiv comprehensive survey (2025), covering: retrieval-augmented prompting, active prompting, directional stimulus prompting, program-aided language models, graph-of-thought, skeleton-of-thought, analogical prompting, emotion prompting, rephrase-and-respond, step-back prompting, contrastive CoT, thread-of-thought, and more.
