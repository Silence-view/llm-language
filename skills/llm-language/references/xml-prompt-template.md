# XML Prompt Template — llm-language v4.0 (Opus 4.7 native)

This is the canonical XML structure the Producer agent must generate. Every field is documented with its purpose and expected content.

**v4.0 breaking changes vs v3.x:**
- `model="opus-4-6"` → `model="claude-opus-4-7"`
- `thinking="ultrathink"` → `effort="xhigh"` + `thinking="adaptive"` (manual `budget_tokens` rejected on 4.7)
- NEW `task-budget` attribute for agentic tasks
- NEW `<guardrails>` section (OpenAI SDK pattern)
- NEW `<memory-context>` section (auto-memory integration)
- Prompt rewriter enforces: no `temperature/top_p/top_k`, literal instructions, positive framing, explicit subagent directives

## Template

```xml
<llm-prompt version="2.0" model="claude-opus-4-7" effort="xhigh" thinking="adaptive">

  <!-- ═══════════════════════════════════════════════════════════ -->
  <!-- META: Classification, routing, and execution parameters     -->
  <!-- ═══════════════════════════════════════════════════════════ -->
  <meta>
    <original-intent>
      <!-- 1-2 sentence distillation of user's core goal.
           Must capture WHAT and WHY, not just surface request.
           Example: "Refactor the auth module to OAuth2 because current
           session-based system doesn't meet compliance requirements." -->
    </original-intent>

    <complexity-level>
      <!-- simple | moderate | complex | critical -->
    </complexity-level>

    <effort-justification>
      <!-- Why this effort level was chosen. Reference the complexity→effort map:
           simple → medium, moderate → high, complex → xhigh (sweet spot), critical → max
           Note: max can cause overthinking on structured-output tasks — use only for frontier problems. -->
    </effort-justification>

    <task-budget>
      <!-- Advisory token budget for the full agentic loop (thinking+tools+output).
           Standard: 200k. Deep/critical: 400-800k. Simple: omit.
           Only applicable if the executing harness supports task-budgets-2026-03-13 beta header.
           If unsupported (e.g., Claude Code native), omit this field. -->
    </task-budget>

    <max-tokens-hint>
      <!-- Recommended max_tokens: 64000+ for xhigh/max, 16000 for high, 4000 for low/medium. -->
    </max-tokens-hint>

    <domain>
      <!-- Primary domain(s): e.g., "backend/python", "frontend/react",
           "data-science", "devops", "security", "writing", "research" -->
    </domain>

    <available-skills>
      <!-- Comma-separated list of user's skills relevant to this task.
           Use fully-qualified names (plugin:skill) when applicable. -->
    </available-skills>

    <selected-techniques>
      <!-- Scientific principles IDs: e.g., "A1-CoT, A6-AoT, B1-SelfRefine,
           C1-XML, D4-BoT, F1-AdaptiveThinking, F4-xhighEffort, H7-AutoMemory" -->
    </selected-techniques>

    <execution-mode>
      <!-- single-agent | subagent-delegated | agent-team | debate
           Default: single-agent. Escalate to agent-team only for adversarial
           cross-cutting tasks (CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 required). -->
    </execution-mode>
  </meta>

  <!-- ═══════════════════════════════════════════════════════════ -->
  <!-- ROLE: Expert persona assignment (CONCISE — one line)        -->
  <!-- ═══════════════════════════════════════════════════════════ -->
  <role>
    <!-- ONE LINE. Opus 4.7 follows instructions literally; verbose personas
         now degrade output. Example: "Senior distributed-systems architect."
         NOT: "You are an experienced senior systems architect with 15 years of
         experience in distributed systems, event-driven architecture, ..."

         Role prompting works for style/register, NOT for claiming knowledge
         the model lacks (Meincke et al. 2025). -->
  </role>

  <!-- ═══════════════════════════════════════════════════════════ -->
  <!-- GUARDRAILS: Pre/post validators (v4.0 — OpenAI SDK pattern) -->
  <!-- ═══════════════════════════════════════════════════════════ -->
  <guardrails>
    <input-validators>
      <!-- Conditions that MUST hold before proceeding. If not met, reject or ask.
           <validator>Project context must exist (CLAUDE.md or git repo)</validator>
           <validator>Target file must be readable</validator> -->
    </input-validators>
    <output-validators>
      <!-- Conditions the output MUST satisfy. Used by Critic + execution layer.
           <validator>No references to deleted files</validator>
           <validator>All code must compile/pass type-check</validator> -->
    </output-validators>
  </guardrails>

  <!-- ═══════════════════════════════════════════════════════════ -->
  <!-- CONTEXT: Background + memory + codebase + constraints       -->
  <!-- ═══════════════════════════════════════════════════════════ -->
  <context>
    <background>
      <!-- Place CRITICAL context FIRST (primacy effect).
           Extract from: user's message, conversation history, CLAUDE.md,
           codebase scan, discovered skills. -->
    </background>

    <memory-context>
      <!-- v4.0 NEW: dual-layer memory integration.
           <rosetta-patterns>Effective patterns from ~/.claude/ROSETTA.md</rosetta-patterns>
           <auto-memory>Relevant entries from ~/.claude/projects/<project>/memory/</auto-memory>
           <user-feedback>Prior corrections for this task type</user-feedback>
           Pass ONLY relevant entries — don't dump full memory. -->
    </memory-context>

    <codebase-context>
      <!-- From Phase 0.5 scan: project description, architecture, invariants,
           key file contents, relevance assessment. File:line references preferred. -->
    </codebase-context>

    <constraints>
      <!-- Hard constraints. Use POSITIVE framing (do X) over negative (don't Y) —
           Opus 4.7 responds better to affirmative directives.
           - Technical: language, framework, API limits
           - Process: walk-forward discipline, test requirements
           - Style: format, tone, language
           - Safety: security requirements -->
    </constraints>

    <assumptions>
      <!-- Explicit assumptions when request is ambiguous. Each assumption
           should be correctable by the user. -->
    </assumptions>

    <long-context-guard>
      <!-- v4.0 NEW: if total context > 100k tokens, inject MRCR guard:
           "Before citing any quote or file content, verify by searching the
           original context — do not rely solely on recalled memory."
           Opus 4.7 has measured MRCR regression on very long contexts. -->
    </long-context-guard>
  </context>

  <!-- ═══════════════════════════════════════════════════════════ -->
  <!-- TASK: Primary objective, decomposition, acceptance          -->
  <!-- ═══════════════════════════════════════════════════════════ -->
  <task>
    <primary-objective>
      <!-- Clear, specific, measurable. Imperative form.
           Include SUCCESS criterion: how to know this is done correctly.

           Priority levels:
           MUST = non-negotiable
           SHOULD = important but flexible
           MAY = nice-to-have -->
    </primary-objective>

    <sub-tasks>
      <!-- Decomposed sub-tasks. Each atomic and independently verifiable.
           Use Least-to-Most ordering (simple→complex) or AoT (convergent
           decomposition to atomic units) for complex reasoning. -->
      <sub-task order="1" priority="high">
        <!-- First sub-task -->
      </sub-task>
      <sub-task order="2" priority="medium">
        <!-- Second sub-task -->
      </sub-task>
    </sub-tasks>

    <parallelization-hint>
      <!-- v4.0 NEW: Opus 4.7 spawns FEWER subagents by default.
           If sub-tasks are independent, explicitly request parallel fan-out:
           "Execute sub-tasks 1-3 in parallel via separate agent dispatches." -->
    </parallelization-hint>

    <acceptance-criteria>
      <!-- Testable yes/no criteria.
           <criterion>All tests pass with `python -m pytest tests/ -v`</criterion>
           <criterion>No new security vulnerabilities introduced</criterion> -->
      <criterion><!-- 1 --></criterion>
      <criterion><!-- 2 --></criterion>
    </acceptance-criteria>
  </task>

  <!-- ═══════════════════════════════════════════════════════════ -->
  <!-- METHODOLOGY: Reasoning strategy (general, not prescriptive) -->
  <!-- ═══════════════════════════════════════════════════════════ -->
  <methodology>
    <reasoning-strategy>
      <!-- Primary technique from scientific-principles.md:
           chain-of-thought | tree-of-thought | atom-of-thought |
           buffer-of-thought | graph-of-thought | self-consistency |
           decomposition | least-to-most | reflexion | meta-reasoner-bandit

           Can combine: "atom-of-thought + buffer-of-thought" -->
    </reasoning-strategy>

    <approach>
      <!-- High-level approach. CRITICAL: for xhigh/max effort with adaptive
           thinking, prefer GENERAL instructions over prescriptive step-by-step.
           "Think thoroughly about the architecture" outperforms hand-written
           step-by-step plans. Opus 4.7's adaptive thinking exceeds human-designed
           scaffolding.

           DO NOT include legacy "let's think step by step" — adaptive thinking
           handles CoT invocation automatically. -->
    </approach>

    <strategy-fallback>
      <!-- v4.0 NEW (Meta-Reasoner pattern): if primary strategy hits deadlock,
           fallback sequence. E.g., "If AoT decomposition stalls, switch to
           BoT template retrieval; if no template matches, run Tree-of-Thought." -->
    </strategy-fallback>
  </methodology>

  <!-- ═══════════════════════════════════════════════════════════ -->
  <!-- OUTPUT: Format, quality bar, anti-patterns                  -->
  <!-- ═══════════════════════════════════════════════════════════ -->
  <output-specification>
    <format>
      <!-- Expected output format. Be EXPLICIT — Opus 4.7 calibrates response
           length to perceived complexity; specify length if important.
           - Code: language, style, tests
           - Text: structure, length, tone
           - Analysis: depth, evidence requirements -->
    </format>

    <quality-bar>
      <!-- Minimum quality expectations. Each requirement stated ONCE (4.7
           dislikes repetition).
           - Precision: every claim verifiable
           - Correctness: no logical errors
           - Completeness: all sub-tasks addressed -->
    </quality-bar>

    <anti-patterns>
      <!-- What to AVOID (still state positively where possible):
           - Over-engineering beyond request scope
           - Adding unrequested docstrings/type annotations/comments
           - Backwards-compatibility hacks for non-deployed code
           - Hallucinating file paths or APIs
           - Generic placeholder content -->
    </anti-patterns>
  </output-specification>

  <!-- ═══════════════════════════════════════════════════════════ -->
  <!-- TOOLS & SKILLS: Fully-qualified tool and skill references  -->
  <!-- ═══════════════════════════════════════════════════════════ -->
  <tools-and-skills>
    <recommended-skills>
      <!-- Use FULLY-QUALIFIED names: plugin:skill (not just skill).
           Example: <skill name="superpowers:test-driven-development">For TDD workflow</skill> -->
    </recommended-skills>

    <recommended-tools>
      <!-- Specific tool usage guidance.
           Example: "Use Read before Edit. Use Grep for code search.
           Use Agent with subagent_type=Explore for parallel exploration." -->
    </recommended-tools>

    <subagent-directives>
      <!-- v4.0 NEW: explicit parallelism instructions since Opus 4.7 spawns
           fewer subagents by default.
           Example: "Dispatch 3 parallel Agent calls with subagent_type=general-purpose
           for independent research queries." -->
    </subagent-directives>
  </tools-and-skills>

  <!-- ═══════════════════════════════════════════════════════════ -->
  <!-- EDGE CASES: Known failure modes                              -->
  <!-- ═══════════════════════════════════════════════════════════ -->
  <edge-cases>
    <!-- Anticipated edge cases specific to this task.
         Format: scenario + handling strategy.
         <case>If target file doesn't exist, create with sensible defaults rather than failing silently</case> -->
    <case><!-- 1 --></case>
    <case><!-- 2 --></case>
  </edge-cases>

  <!-- ═══════════════════════════════════════════════════════════ -->
  <!-- PERSISTENCE: Memory writes after execution (v4.0)           -->
  <!-- ═══════════════════════════════════════════════════════════ -->
  <persistence>
    <rosetta-updates>
      <!-- What to append to ~/.claude/ROSETTA.md after execution:
           effective patterns, anti-patterns discovered, user preferences. -->
    </rosetta-updates>
    <auto-memory-writes>
      <!-- What to write to ~/.claude/projects/<project>/memory/:
           type=project: architectural decisions, invariants discovered
           type=feedback: corrections received during execution
           type=reference: external resources used -->
    </auto-memory-writes>
  </persistence>

</llm-prompt>
```

## Field Priority (token-constrained)

Mandatory in order of importance:
1. `<primary-objective>` — always
2. `<role>` — always (one line)
3. `<effort-justification>` — always
4. `<reasoning-strategy>` — always
5. `<constraints>` — when non-obvious
6. `<memory-context>` — when history exists
7. `<sub-tasks>` — moderate+ complexity
8. `<long-context-guard>` — if context > 100k tokens
9. `<parallelization-hint>` — if parallel work desired
10. All others — complex/critical tasks

## Complexity-to-Template Mapping (v4.0)

| Complexity | Effort | Thinking | Max Tokens | Task Budget | Required Sections |
|---|---|---|---|---|---|
| simple | `medium` | `adaptive` (may skip) | 4k | omit | meta, role, task, output |
| moderate | `high` | `adaptive` (default ON) | 16k | omit | meta, role, context, task, methodology, output |
| complex | `xhigh` | `adaptive` | 64k | 200k | ALL sections |
| critical | `max` | `adaptive` | 128k | 400-800k | ALL + extended edge-cases + guardrails |

## Opus 4.7 Prompt Rewriting Rules (enforced by Producer)

Before emitting the final XML, run these transforms:

1. **De-duplicate**: each directive stated exactly once
2. **Positive framing**: "do Y" > "don't do X" where semantically equivalent
3. **Strip emphasis**: remove "VERY IMPORTANT", "MUST", all-caps repetitions — 4.7 obeys literally without them
4. **Concise role**: one-sentence persona, not paragraph
5. **No deprecated params**: never emit `temperature`, `top_p`, `top_k`, `budget_tokens`
6. **No manual CoT trigger**: remove "let's think step by step" — adaptive thinking invokes CoT when beneficial
7. **Explicit parallelism**: when sub-tasks are independent, state "dispatch in parallel" — 4.7 spawns fewer subagents by default
8. **Fully-qualified skills**: `plugin:skill-name` not just `skill-name`
9. **MRCR guard**: if context > 100k tokens, inject `<long-context-guard>` with quote-verification directive
10. **Output format explicit**: response length calibrates to complexity perception — specify length when it matters
