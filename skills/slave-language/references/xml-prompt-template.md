# XML Prompt Template — slave-language

This is the canonical XML structure that the Producer agent must generate. Every field is documented with its purpose and expected content.

## Template

```xml
<slave-prompt version="1.0" model="opus-4.6" thinking="ultrathink">

  <!-- ═══════════════════════════════════════════════════════════ -->
  <!-- META: Classification and routing metadata                  -->
  <!-- ═══════════════════════════════════════════════════════════ -->
  <meta>
    <original-intent>
      <!-- 1-2 sentence distillation of user's core goal.
           Must capture the WHAT and WHY, not just surface request.
           Example: "Refactor the auth module to use OAuth2 because the current
           session-based system doesn't meet compliance requirements." -->
    </original-intent>

    <complexity-level>
      <!-- One of: simple | moderate | complex | critical
           simple    = single-step, clear output, no ambiguity
           moderate  = multi-step, clear dependencies, some judgment needed
           complex   = multiple approaches possible, architecture decisions, trade-offs
           critical  = high-stakes, irreversible, requires maximum reasoning depth -->
    </complexity-level>

    <domain>
      <!-- Primary domain(s): e.g., "backend/python", "frontend/react",
           "data-science", "devops", "security", "writing", "research" -->
    </domain>

    <available-skills>
      <!-- Comma-separated list of user's skills that are relevant to this task.
           Only include skills that should be considered for invocation.
           Example: "paper, humanizer, safe-solana-builder" -->
    </available-skills>

    <selected-techniques>
      <!-- Which scientific principles from scientific-principles.md to apply.
           Reference by ID: e.g., "A1-CoT, B1-SelfRefine, C1-XML, F1-Ultrathink"
           The Producer selects these based on the task type using the Decision Matrix. -->
    </selected-techniques>
  </meta>

  <!-- ═══════════════════════════════════════════════════════════ -->
  <!-- ROLE: Expert persona assignment                            -->
  <!-- ═══════════════════════════════════════════════════════════ -->
  <role>
    <!-- Assign an expert persona matched to the domain.
         Be specific: not "an expert" but "a senior systems architect with 15 years
         of experience in distributed systems and event-driven architecture."

         IMPORTANT: Role prompting improves style/format alignment but has
         mixed results for factual accuracy (see scientific-principles.md).
         Use for: task framing, output style, communication register.
         Do NOT use for: claiming domain knowledge the model doesn't have. -->
  </role>

  <!-- ═══════════════════════════════════════════════════════════ -->
  <!-- CONTEXT: Background, constraints, and assumptions          -->
  <!-- ═══════════════════════════════════════════════════════════ -->
  <context>
    <background>
      <!-- Relevant background information extracted from:
           1. The user's message itself
           2. The conversation history
           3. The project context (CLAUDE.md, codebase state)
           4. Any discovered skills/agents that provide context

           Place the most critical context FIRST (primacy effect). -->
    </background>

    <constraints>
      <!-- Hard constraints that MUST be respected:
           - Technical: language, framework, API limits, performance requirements
           - Process: walk-forward discipline, no look-ahead bias, testing requirements
           - Style: output format, tone, language preferences
           - Safety: security requirements, data handling rules -->
    </constraints>

    <assumptions>
      <!-- Explicit assumptions made when the user's request is ambiguous.
           Each assumption should be clearly stated so the user can correct if wrong.
           Example: "Assuming Python 3.11+, assuming the database is PostgreSQL." -->
    </assumptions>
  </context>

  <!-- ═══════════════════════════════════════════════════════════ -->
  <!-- TASK: Primary objective and decomposition                  -->
  <!-- ═══════════════════════════════════════════════════════════ -->
  <task>
    <primary-objective>
      <!-- Clear, specific, measurable primary goal.
           Use imperative form: "Implement X", "Analyze Y", "Design Z"
           Include success criterion: how to know this is done correctly.

           Priority levels for multi-objective tasks:
           MUST = non-negotiable requirements
           SHOULD = important but flexible
           MAY = nice-to-have if no conflict with above -->
    </primary-objective>

    <sub-tasks>
      <!-- Decomposed sub-tasks ordered by execution sequence.
           Each sub-task should be atomic and independently verifiable.
           Use Least-to-Most ordering when applicable (simple → complex). -->
      <sub-task order="1" priority="high">
        <!-- First sub-task description -->
      </sub-task>
      <sub-task order="2" priority="medium">
        <!-- Second sub-task description -->
      </sub-task>
      <!-- Add more as needed -->
    </sub-tasks>

    <acceptance-criteria>
      <!-- Concrete, verifiable criteria for task completion.
           Each criterion should be testable (yes/no, not subjective).
           Example:
           <criterion>All tests pass with `python -m pytest tests/ -v`</criterion>
           <criterion>No new security vulnerabilities introduced</criterion> -->
      <criterion><!-- criterion 1 --></criterion>
      <criterion><!-- criterion 2 --></criterion>
    </acceptance-criteria>
  </task>

  <!-- ═══════════════════════════════════════════════════════════ -->
  <!-- METHODOLOGY: Reasoning strategy and approach               -->
  <!-- ═══════════════════════════════════════════════════════════ -->
  <methodology>
    <reasoning-strategy>
      <!-- Primary reasoning technique from scientific-principles.md:
           chain-of-thought     → Step-by-step decomposition
           tree-of-thought      → Multiple parallel reasoning paths
           self-consistency     → Multiple paths, majority vote
           decomposition        → Modular sub-problem delegation
           least-to-most        → Simple-to-complex ordering
           reflexion            → Learn from prior attempts

           Can combine: "chain-of-thought + self-consistency" -->
    </reasoning-strategy>

    <approach>
      <!-- High-level approach description.

           IMPORTANT (Anthropic guidance): For ultrathink mode, prefer
           GENERAL instructions over prescriptive steps. "Think thoroughly
           about the architecture" outperforms "Step 1: List all modules,
           Step 2: Draw dependency graph, Step 3: ..."

           Claude's extended thinking frequently exceeds what a human
           would prescribe in a step-by-step plan. -->
    </approach>
  </methodology>

  <!-- ═══════════════════════════════════════════════════════════ -->
  <!-- OUTPUT: Format, quality bar, and anti-patterns             -->
  <!-- ═══════════════════════════════════════════════════════════ -->
  <output-specification>
    <format>
      <!-- Expected output format:
           - Code: language, style, documentation requirements
           - Text: structure (prose/bullets/table), length, tone
           - Analysis: depth level, evidence requirements
           - Mixed: section structure with format per section -->
    </format>

    <quality-bar>
      <!-- Minimum quality expectations:
           - Precision: every claim should be verifiable
           - Completeness: all sub-tasks addressed
           - Correctness: no logical errors, security vulnerabilities, or bugs
           - Style: matches project conventions -->
    </quality-bar>

    <anti-patterns>
      <!-- What to explicitly AVOID:
           - Over-engineering beyond what's requested
           - Adding unrequested features, docstrings, or type annotations
           - Backwards-compatibility hacks
           - Hallucinating file paths, function names, or APIs
           - Generic placeholder content -->
    </anti-patterns>
  </output-specification>

  <!-- ═══════════════════════════════════════════════════════════ -->
  <!-- TOOLS & SKILLS: Recommended tools and skill invocations    -->
  <!-- ═══════════════════════════════════════════════════════════ -->
  <tools-and-skills>
    <recommended-skills>
      <!-- Skills that should be invoked for this task.
           Example: <skill name="paper">For LaTeX compilation</skill> -->
    </recommended-skills>

    <tool-guidance>
      <!-- Specific tool usage instructions if applicable.
           Example: "Use Read before Edit. Use Grep for code search.
           Use Agent for parallel exploration." -->
    </tool-guidance>
  </tools-and-skills>

  <!-- ═══════════════════════════════════════════════════════════ -->
  <!-- EDGE CASES: Known failure modes and how to handle them     -->
  <!-- ═══════════════════════════════════════════════════════════ -->
  <edge-cases>
    <!-- Anticipated edge cases specific to this task.
         Each case should describe the scenario AND the handling strategy.
         Example:
         <case>If the file doesn't exist, create it with sensible defaults
         rather than failing silently</case> -->
    <case><!-- edge case 1 --></case>
    <case><!-- edge case 2 --></case>
  </edge-cases>

</slave-prompt>
```

## Field Priority

When context window is limited, these fields are mandatory (in order of importance):

1. `<primary-objective>` — always include
2. `<role>` — always include
3. `<reasoning-strategy>` — always include
4. `<constraints>` — include when non-obvious
5. `<sub-tasks>` — include for moderate+ complexity
6. `<format>` — include when output format matters
7. `<edge-cases>` — include for complex/critical tasks
8. All other fields — include for complex/critical tasks

## Complexity-to-Template Mapping

| Complexity | Required Sections | Thinking Level |
|---|---|---|
| simple | meta, role, task (no sub-tasks), output | default |
| moderate | meta, role, context, task, methodology, output | extended |
| complex | ALL sections | ultrathink |
| critical | ALL sections + extra edge-cases + acceptance-criteria | ultrathink |
