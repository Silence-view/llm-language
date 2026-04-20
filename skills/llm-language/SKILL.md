---
name: llm-language
version: "4.1"
user-invocable: true
effort: xhigh
description: >
  Use when user explicitly invokes "/llm-language" or says "llm-language",
  "optimize prompt", "re-engineer prompt", "massima precisione", "maximum
  quality", "ottimizza il prompt". This skill re-engineers the user's
  prompt through multi-agent debate with scientific optimization,
  ROSETTA.md + auto-memory dual-layer persistent memory, mandatory codebase
  awareness, web deep research, full skill access, AND v4.1 skill-level
  meta-refinement (audits relevant user-owned skills, applies safe fixes
  automatically). Targets Claude Opus 4.7 with adaptive thinking + xhigh/max
  effort (backward-compatible with Opus 4.6, Sonnet 4.6). Ships hooks for
  AUTOMATIC ROSETTA + auto-memory updates on EVERY skill invocation, not
  just explicit llm-language calls.
---

# llm-language v4.1

## Overview

A self-evolving prompt meta-compiler that re-engineers user messages through multi-agent debate grounded in 125+ scientific papers, producing optimized XML-structured prompts for Claude Opus 4.7 with adaptive thinking + xhigh/max effort. The system maintains **dual-layer persistent memory** (ROSETTA.md for user-level patterns + auto-memory for project-level state) and **mandatory codebase awareness** — reading the actual project before generating prompts, ensuring every output is grounded in reality.

**Core cycle:** ROSETTA + Auto-Memory Load → **Codebase Scan** → **CLAUDE.md Check** → Intake → Generate → Critique → Revise → Execute → ROSETTA + Auto-Memory Update

**New in v4.0 (Opus 4.7 native):**
- **Target model: Claude Opus 4.7** — uses `effort` parameter (low/medium/high/xhigh/max) with adaptive thinking; `temperature`, `top_p`, `top_k`, `budget_tokens` stripped from output (rejected on 4.7)
- **Complexity → effort map**: simple→medium, moderate→high, complex→**xhigh** (sweet spot for coding/agentic), critical→**max** (frontier problems only)
- **Task budgets** (beta) — for multi-hour agentic loops, Producer emits advisory token budget
- **Dual-layer memory** — ROSETTA.md (cross-project user patterns) + auto-memory (`~/.claude/projects/<project>/memory/` for project-level learnings, typed: user/feedback/project/reference)
- **Prompt rewriter v2** — enforces Opus 4.7 rules: de-dup, positive framing, concise role, explicit parallelism, no deprecated params, no manual "let's think step by step" (adaptive thinking handles CoT)
- **Guardrails** (OpenAI SDK pattern) — pre/post validators in XML output
- **MRCR guard** — for context >100k tokens, inject quote-verification directive (Opus 4.7 MRCR regression)
- **Threshold raised to 9.3** — Critic must score ≥9.3 to accept (was 9.2) with 10 dimensions (added Effort Calibration + Memory Integration)
- **Meta-Reasoner bandit** — strategy selection (single-pass / debate / BoT-retrieve / AoT-decompose / deep-research) adapts via Thompson sampling
- **PreCompact hook** — snapshot ROSETTA state before compaction (write-then-allow, never block)
- **Agent Teams mode** — proposed when task is adversarial + cross-cutting (requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`)
- **Backward compatible** — emits legacy XML when target model is Opus 4.6 / Sonnet 4.6

**Carried from v3.x:**
- Mandatory codebase awareness (Producer reads CLAUDE.md + key files before generating)
- ROSETTA cold-start bootstrap (infers user profile from CLAUDE.md + git log)
- 4 revision rounds max, Critic anchor at 5, context mismatch detection
- CLAUDE.md auto-maintenance (WHY-WHAT-HOW structure, Codified Context methodology)
- Deep research via WebSearch, full skill access

**NEW in v4.1 (Skill Meta-Refinement + Jarvis Overhaul + Auto-ROSETTA):**
- **Phase 7 Skill Audit** — every `/llm-language` invocation lightly audits skills relevant to the current task; applies SAFE auto-fixes (deprecated syntax, emphasis markers) and flags RISKY refinement candidates to Summary Banner
- **New sub-skill `/llm-language:refine-skills`** — deep audit of all user-owned skills with 10-dim rubric, backups, rollback support
- **Automatic ROSETTA updates** — shipped hooks (SessionStart, UserPromptSubmit, Stop, TaskCompleted) write to ROSETTA every session without requiring explicit `/llm-language` invocation
- **Jarvis v3.0 overhaul** — lowered Phase 2 threshold (10 → 3 observations), session-start awareness cards, plugin monitor auto-arm, first-run onboarding
- **Micro-task splitting as default methodology** — Producer decomposes complex tasks into 3-15 atomic tracked tasks; codified in ROSETTA bootstrap as standard pattern
- **Skill refinement audit trail** — every auto-fix logged to `auto-memory/skill-refinement-audit.md` with rollback pointers

## When to Use

**Only when explicitly invoked.** The full pipeline runs on:
- `/llm-language` command
- User says "llm-language", "optimize prompt", "massima precisione", "maximum quality"

**ROSETTA.md updates happen passively** — even when the skill is NOT invoked, ROSETTA.md should be updated at session boundaries to capture user style signals (language preference, communication patterns, domain context). This is handled by the ROSETTA Passive Update mechanism (see Phase 6b).

---

## Pipeline Execution (7 Phases)

### Phase 0: DUAL-LAYER MEMORY LOAD (inline, first thing)

**v4.0 CHANGE: Load BOTH ROSETTA.md (user-level) AND auto-memory (project-level).**

**0.A — ROSETTA.md (cross-project user preferences)**

1. Check if `~/.claude/ROSETTA.md` exists
2. If it exists: read it fully — this is the user's preference profile, accumulated learnings, effective patterns, and (v4.0 NEW) Buffer-of-Thoughts template meta-buffer + Meta-Reasoner bandit state + failure taxonomy
3. If it does NOT exist: **COLD-START BOOTSTRAP** — before creating from template:
   a. Read CLAUDE.md (if exists) to extract: project description, commands, architecture, conventions
   b. Run `git log --oneline -20` to extract: recent activity, author name, commit style
   c. Infer from conversation language: Italian/English/mixed preference
   d. Pre-populate ROSETTA.md user profile from these signals BEFORE creating from template
   e. Then create from `references/rosetta-bootstrap.md` with the pre-populated fields filled in
4. Extract from ROSETTA.md:
   - **User preferences** (communication style, preferred output formats, domain expertise)
   - **Effective patterns** (techniques that scored high, approaches the user responded well to)
   - **Anti-patterns** (things that failed or the user corrected)
   - **Domain context** (projects, tech stack, common themes)
   - **v4.0 NEW: Thought templates** (BoT meta-buffer — reusable solution schemas)
   - **v4.0 NEW: Strategy bandit state** (Thompson priors for single-pass / debate / BoT / AoT / deep-research)
   - **v4.0 NEW: Failure taxonomy** (error class → specialized fixer mapping)

**0.B — Auto-memory (project-level learnings, v4.0 NEW)**

Claude Code v2.1.59+ auto-maintains `~/.claude/projects/<project>/memory/` where `<project>` is derived from git repo root. Load it:

1. Read `~/.claude/projects/<project>/memory/MEMORY.md` if it exists (first 200 lines / 25KB auto-loaded by harness, but skill verifies)
2. Index the topic files: extract filenames from MEMORY.md to know what's stored
3. Load topic files on demand during Phase 2 based on task relevance (don't dump all upfront)
4. Memory types to leverage:
   - `type: user` — user role, preferences, knowledge for this project
   - `type: feedback` — past corrections, confirmations, guidance
   - `type: project` — architectural decisions, invariants, active work
   - `type: reference` — pointers to external systems (Linear boards, Grafana dashboards, etc.)

**0.C — Merge into `<memory-context>` block**

Merge ROSETTA + auto-memory into a single `<memory-context>` XML block passed to ALL subsequent agents. Structure:

```xml
<memory-context>
  <rosetta-patterns>{relevant patterns from ROSETTA}</rosetta-patterns>
  <thought-templates>{relevant BoT templates matching task pattern}</thought-templates>
  <strategy-prior>{current bandit estimate for optimal strategy}</strategy-prior>
  <auto-memory-entries>
    <user-notes>{user-level project preferences}</user-notes>
    <feedback-history>{past corrections on similar tasks}</feedback-history>
    <project-facts>{architectural decisions, invariants}</project-facts>
    <references>{external resources}</references>
  </auto-memory-entries>
</memory-context>
```

### Phase 0.5: CODEBASE SCAN (MANDATORY — inline, no subagent)

**This phase is NON-OPTIONAL. Skip it = skill failure.**

Scan the current project to build a `<codebase-context>` block:

1. **Read CLAUDE.md** (or AGENTS.md, GEMINI.md if present) — extract:
   - Project description and purpose
   - Architecture overview and module roles
   - Critical invariants and conventions
   - Test commands and build commands
   - Any explicit "do NOT" rules

2. **Read key project files** — use `Glob` to find entry points, then `Read` the first 50-80 lines of:
   - Main entry point (main.py, index.ts, etc.)
   - Config files (params.yaml, package.json, etc.)
   - Up to 3 most-recently-modified source files (from git status)

3. **Project structure inventory** — run `ls` or `Glob` on the root to understand directory layout

4. **Relevance check** — compare the user's request against the project context:
   - If the request is **RELEVANT** to the project: anchor all subsequent prompts to the codebase
   - If the request is **IRRELEVANT** (e.g., auth system for a backtest): flag with `<context-mismatch>` and offer clarification options
   - If **AMBIGUOUS**: use codebase to disambiguate (e.g., "questi dati" → the Parquet files in data/)

5. **File content check** — if the request targets a specific file/section that may already exist:
   - Read the target file to check if the content is already present
   - If content exists: frame the task as "revise/extend" not "create from scratch"

The `<codebase-context>` block is passed to ALL subsequent agents alongside `<rosetta-context>`.

### Phase 0.6: CLAUDE.md MAINTENANCE (inline, first invocation per project)

**On the FIRST invocation in a project that has no CLAUDE.md, or when the existing CLAUDE.md is stale (>30 days since last update), generate or refresh it.**

This phase implements the "Codified Context" methodology (arxiv:2602.20478) — treating CLAUDE.md as load-bearing documentation that AI agents depend on for correct output.

#### When to Generate (from scratch)

If no CLAUDE.md exists in the project root:

1. **Scan the project** using Phase 0.5 data (already collected):
   - Entry points, config files, directory structure
   - Package manager files (package.json, pyproject.toml, requirements.txt, Cargo.toml)
   - Test configuration and commands
   - Git history for recent activity patterns

2. **Generate CLAUDE.md** following the WHY-WHAT-HOW structure (Anthropic 2026):

   ```markdown
   # {Project Name} — {One-line description}

   {2-3 sentence project summary: what it does, why it exists}

   ## Commands
   ```bash
   # Build/run
   {detected from package.json scripts, Makefile, pyproject.toml}

   # Test
   {detected from test framework config}

   # Lint/format
   {detected from linter config}
   ```

   ## Architecture
   {Module map: which directories/files do what, data flow}

   ## Conventions
   {Code style, naming, testing patterns — inferred from existing code}

   ## Critical Invariants
   {Things that MUST NOT break — inferred from test assertions and comments}

   ## What NOT to Do
   {Anti-patterns specific to this project}
   ```

3. **Keep it under 200 lines** — use progressive disclosure:
   - Main CLAUDE.md: high-level (commands, architecture, invariants)
   - Detailed docs in separate files referenced with @path/to/file.md

4. **Present to user for review** before writing — never auto-commit

#### When to Update (existing CLAUDE.md)

If CLAUDE.md exists but is stale (detected via git log on the file):

1. **Diff analysis**: compare CLAUDE.md content against current codebase state
   - Are commands still valid? (run them to check)
   - Are file paths still correct? (Glob to verify)
   - Are invariants still documented? (check test files)
   - Are new modules/features missing from the architecture section?

2. **Incremental update**: propose specific edits (not full rewrite)
   - Add new modules/commands discovered
   - Remove references to deleted files
   - Update invariants based on new test patterns
   - Flag sections that may be outdated

3. **Staleness detection heuristic**:
   - Count commits since CLAUDE.md last modified
   - If > 50 commits or > 30 days: flag for review
   - If new directories or entry points added: flag for update

#### CLAUDE.md Quality Principles (from research)

Based on 50+ sources (HumanLayer 2026, Anthropic Official, Codified Context arxiv:2602.20478, EclipseSource 2025):

1. **Conciseness is critical**: LLMs handle ~150-200 instructions reliably; Claude Code's system prompt already uses ~50. Target < 200 lines.
2. **WHY-WHAT-HOW structure**: Project purpose → tech stack/architecture → development workflows
3. **Progressive disclosure**: Keep task-specific docs in separate files, reference with @path
4. **No sensitive data**: Treat as public documentation (no API keys, credentials, connection strings)
5. **No style rules**: Use linters/formatters instead — LLMs are expensive and slow for style enforcement
6. **File:line pointers, not code snippets**: Snippets go stale; file references stay current
7. **Iterate continuously**: Treat as living document, not one-time setup
8. **Test your commands**: Every command in CLAUDE.md should actually work when run
9. **Invariants > conventions**: Focus on things that break if violated, not preferences
10. **Human-curated, AI-assisted**: AI generates the draft; human validates and curates

#### Skipping This Phase

Skip if:
- CLAUDE.md was updated within the last 7 days (< 50 commits since)
- The user explicitly says "skip CLAUDE.md update"
- The current task is simple complexity

### Phase 1: INTAKE (inline, no subagent)

**1.1 Capture Raw Input**

Store the user's exact message verbatim. This is IMMUTABLE.

**1.2 Discover Available Skills**

Run `Glob` on `~/.claude/skills/*/SKILL.md`, `~/.claude/agents/*.md`, and `~/.claude/plugins/*/skills/*/SKILL.md` to enumerate all available skills and agents. For each, extract `name` and `description`. Build a compact registry.

**CRITICAL: Exclude `llm-language` from the registry.**

**1.3 Classify Complexity + Select Effort (v4.0)**

Map complexity directly to Opus 4.7 `effort` parameter:

| Complexity | Description | Effort | Max Tokens | Task Budget |
|---|---|---|---|---|
| **simple** | single-step, clear output, no ambiguity | `medium` | 4k | omit |
| **moderate** | multi-step, clear dependencies | `high` | 16k | omit |
| **complex** | multiple approaches, architecture decisions | `xhigh` | 64k | 200k |
| **critical** | high-stakes, irreversible, frontier problem | `max` | 128k | 400-800k |

**Notes:**
- `xhigh` is the Anthropic-recommended starting point for coding and agentic work on Opus 4.7
- `max` adds significant cost for small gains on most workloads and can cause overthinking on structured-output tasks — reserve for genuinely frontier problems
- If user explicitly says "massima precisione" / "maximum quality" → escalate by one level (complex→max, moderate→xhigh)
- If target model is Sonnet 4.6, compress: simple→low, moderate→medium, complex→high, critical→max

**1.4 Assess Uncertainty**

Before proceeding, evaluate: is the user's intent clear enough to generate a high-quality prompt? Check:
- Is the primary objective unambiguous?
- Are there critical missing details that would change the approach?
- Does ROSETTA.md context resolve the ambiguity?

**If uncertainty is HIGH and cannot be resolved by ROSETTA.md context:**

1. First, calculate HOW MANY questions you'd need for an excellent result (N). Consider:
   - Number of ambiguous aspects in the user's message
   - Number of critical decisions that depend on user preference
   - How much ROSETTA.md already covers
2. Use `AskUserQuestion` to present the user with a recommendation:
   - "Per un risultato ottimale servirebbero N domande di chiarimento. Quante vuoi che te ne faccia?"
   - Options: "Tutte (N) — massima precisione", "Solo le top 2-3 — bilanciato", "Zero — procedi con le tue assunzioni"
3. Ask ONLY the number of questions the user approved, ordered by impact (highest-impact first)
4. Do NOT ask obvious questions — only ask when the answer would materially change the generated prompt

**If uncertainty is LOW or ROSETTA.md resolves it:** proceed without interrupting the user. ROSETTA.md preferences have priority over asking — if the answer is already in ROSETTA, don't ask again.

**1.5 Select Scientific Principles**

Use the Quick Decision Matrix in `references/scientific-principles.md`. Cross-reference with ROSETTA.md effective patterns — if the user historically responds well to certain techniques, prefer those.

**1.6 Read XML Template**

Read `references/xml-prompt-template.md` for the Producer agent.

### Phase 2: GENERATE (Producer Subagent) — v4.0 Opus 4.7 native

Dispatch a **general-purpose Agent** (model=opus-4-7, effort=xhigh by default) with FULL tool access:

```
You are an expert prompt engineer specializing in Claude Opus 4.7 optimization.
You have access to ALL tools: WebSearch, Read, Grep, Glob, Bash, and all
available skills. Use them when needed.

Your task: transform the user's raw input into a maximally optimized XML prompt
targeting Claude Opus 4.7 (falls back to Opus 4.6/Sonnet 4.6 if target differs).

You MUST ground the prompt in the actual codebase — never generate in a vacuum.

RAW USER INPUT:
<raw-input>
{user's exact message}
</raw-input>

USER + PROJECT MEMORY (from Phase 0 dual-layer load):
<memory-context>
  <rosetta-patterns>{ROSETTA.md effective patterns, anti-patterns, user profile}</rosetta-patterns>
  <thought-templates>{relevant BoT templates matching task pattern}</thought-templates>
  <strategy-prior>{Meta-Reasoner bandit estimate for best strategy}</strategy-prior>
  <auto-memory-entries>{relevant typed entries from ~/.claude/projects/<project>/memory/}</auto-memory-entries>
</memory-context>

PROJECT CONTEXT (from Phase 0.5 codebase scan):
<codebase-context>
{project description, architecture, invariants, key file contents, relevance assessment}
</codebase-context>

AVAILABLE SKILLS AND AGENTS:
<skill-registry>
{skill/agent registry from Phase 1 — use FULLY-QUALIFIED names plugin:skill}
</skill-registry>

COMPLEXITY LEVEL: {classified complexity}

COMPLEXITY → EFFORT MAPPING (v4.0):
- simple → effort="medium", max_tokens=4000
- moderate → effort="high", max_tokens=16000
- complex → effort="xhigh", max_tokens=64000, task_budget=200000  ← SWEET SPOT for coding
- critical → effort="max", max_tokens=128000, task_budget=400000-800000

SELECTED SCIENTIFIC PRINCIPLES:
<principles>
{selected principle IDs — include 2026 additions: A6-AoT, D4-BoT, D5-MetaReasoner,
 F1-AdaptiveThinking, F4-xhighEffort, H7-AutoMemory, H8-AgentTeams where applicable}
</principles>

XML TEMPLATE TO FOLLOW:
<template>
{content of references/xml-prompt-template.md — v4.0 schema}
</template>

INSTRUCTIONS:
1. Analyze the raw input to extract the user's TRUE intent (not just surface request)
2. USE memory-context to align with known user preferences and effective patterns
3. Apply Meta-Reasoner bandit: pick strategy with highest Thompson posterior for this task class
4. If domain knowledge missing, USE WebSearch to research — deep research for complex/critical
5. Fill every XML template section with specific, precise content
6. Apply selected scientific principles to <methodology>
7. Match skills/agents from the registry using FULLY-QUALIFIED names (plugin:skill)
8. Set `effort` attribute on root element based on complexity mapping above
9. Set `thinking="adaptive"` (manual budget_tokens rejected on Opus 4.7)
10. Ensure <role> is ONE LINE — verbose personas degrade Opus 4.7 output
11. Decompose into sub-tasks ordered by dependency (use AoT convergent decomposition for complex)
12. Add <parallelization-hint> when sub-tasks are independent (Opus 4.7 spawns fewer subagents by default)
13. Add <long-context-guard> if total context > 100k tokens (MRCR regression mitigation)
14. Add <guardrails> with input/output validators (OpenAI SDK pattern)
15. Define concrete acceptance criteria in <acceptance-criteria>
16. Specify <anti-patterns> to avoid (cross-reference ROSETTA anti-patterns)
17. If matching BoT template found, adapt it (<selected-techniques>D4-BoT</selected-techniques>)
18. Emit <strategy-fallback> chain for complex/critical (Meta-Reasoner pattern)
19. Fill <persistence> section: what to write to ROSETTA and auto-memory after execution
20. **v4.1 micro-task decomposition (default for complexity ≥ moderate):** Produce 3-15 atomic sub-tasks in <sub-tasks>, each independently verifiable. Add explicit <verification-step> per sub-task. Prefer many-small-tasks over few-large-tasks — reduces error compounding, enables granular rollback, produces audit trail via TaskCreate integration.

RESEARCH PROTOCOL:
- complex/critical → WebSearch for domain best practices BEFORE writing the prompt
- moderate → WebSearch only if domain unfamiliar
- simple → no research
- Always cite findings in <context><background>

OUTPUT: Return ONLY the complete XML prompt. No commentary, just XML.

OPUS 4.7 PROMPT REWRITING RULES (apply BEFORE emitting):
1. De-duplicate: each directive stated exactly ONCE — 4.7 obeys literally
2. Positive framing: "do Y" not "don't do X" (where semantically equivalent)
3. Strip emphasis markers: remove "VERY IMPORTANT", "MUST", repeated caps
4. Concise role: ONE SENTENCE persona, not paragraph
5. No deprecated params: NEVER emit `temperature`, `top_p`, `top_k`, `budget_tokens`
6. No manual CoT trigger: remove "let's think step by step" — adaptive thinking handles
7. Explicit parallelism: state "dispatch in parallel" when independent sub-tasks
8. Fully-qualified skills: `plugin:skill-name` not just `skill-name`
9. Output format explicit: response length calibrates to perceived complexity — specify if it matters
10. If target model is Opus 4.6 or Sonnet 4.6, use legacy attributes (`thinking="ultrathink"`) — 4.7-specific attributes cause 400 errors on older models

CRITICAL RULES:
- Preserve user's original intent EXACTLY
- Be SPECIFIC — every instruction unambiguous
- Favor GENERAL instructions over prescriptive steps in methodology
- Include available skills in <tools-and-skills> only if genuinely relevant
- XML prompt must be immediately executable — no placeholders or TODOs
- LEVERAGE memory-context — it contains what works for THIS user on THIS project
- GROUND every claim in codebase-context — reference real files, real invariants
- If request is IRRELEVANT to the project, flag <context-mismatch> and offer alternatives
- If target content ALREADY EXISTS, frame as revise/extend
- NEVER recommend technologies/scale beyond what the project actually uses
- Match architecture recommendations to ACTUAL team size, budget, infrastructure
```

### Phase 3: CRITIQUE (Critic Subagent) — v4.0 10 dimensions

Dispatch a **separate general-purpose Agent** (model=opus-4-7, effort=high) with FULL tool access:

```
You are an independent prompt quality critic targeting Claude Opus 4.7. You have
access to ALL tools including WebSearch — use them to verify claims or research standards.

ORIGINAL USER MESSAGE:
<raw-input>
{user's exact message}
</raw-input>

DUAL-LAYER MEMORY CONTEXT (from Phase 0):
<memory-context>
{ROSETTA patterns + auto-memory entries + BoT templates + bandit priors}
</memory-context>

GENERATED XML PROMPT:
<generated-prompt>
{Producer's output from Phase 2}
</generated-prompt>

SCORING RUBRIC (10 dimensions, threshold 9.3):
<rubric>
{content of references/scoring-rubric.md}
</rubric>

CODEBASE CONTEXT (from Phase 0.5):
<codebase-context>
{project description, architecture, invariants — use this to verify the prompt is grounded}
</codebase-context>

INSTRUCTIONS:
1. Score each of the 10 dimensions (1-10) using the anchored scale
2. For each score, cite SPECIFIC evidence from the generated prompt
3. For any score < 8, explain the issue and suggest a concrete fix
4. Dim 7 (User-Fit Alignment): does prompt leverage memory-context effectively?
5. Dim 8 (Codebase Grounding): real files, invariants, scale match?
6. **NEW Dim 9 (Effort Calibration, weight 0.06)**: is effort level appropriate?
   - Too high (max for simple task) → 4 or lower
   - Perfect match with justification → 9-10
   - Missing effort attribute → 2
7. **NEW Dim 10 (Memory Integration, weight 0.05)**: does prompt leverage
   auto-memory and/or memory-context effectively? Does it emit <persistence>
   directives for post-execution memory writes?
8. Calculate weighted score (see scoring-rubric.md for weights)
9. Set verdict to "accept" if weighted score >= **9.3**, "revise" otherwise
10. If CRITICAL ambiguity neither prompt nor memory resolves, flag
    <needs-clarification>question</needs-clarification>
11. **v4.0 NEW — Opus 4.7 compliance check**: reject prompts containing
    `temperature`, `top_p`, `top_k`, `budget_tokens` — these cause 400 errors.
    Flag as structural issue (Dim 4 = 3 or below).

OUTPUT: Return evaluation in XML format from the rubric.

ANTI-INFLATION RULES:
- **Start at 5 and justify UPWARD** — do not start at 7
- "Adequate" = 6. "Good" = 7. "Strong" = 8. "Excellent" = 9. 10 = literally perfect.
- EVERY score must cite specific content from the prompt
- Missing required sections = automatic 4 or below for structure
- Be genuinely critical — FIND WEAKNESSES, not validate
- Cross-check EVERY claim against codebase-context
- If prompt over-engineers beyond project's actual scale, penalize heavily
- If target model is Opus 4.7 but prompt has `thinking="ultrathink"` literal → structure = 4
  (should be `effort="xhigh|max"` + `thinking="adaptive"`)
```

**If the Critic flags `<needs-clarification>`:** pause the pipeline and use `AskUserQuestion` to ask the user. Incorporate the answer, then re-run the Critic.

### Phase 4: REVISE + FINAL CRITIQUE

**If verdict is "accept" (score >= 9.3):** Skip to Phase 5.

**If verdict is "revise" (score < 9.3):**

Dispatch Producer again with critic feedback, memory-context, codebase context, and full tool access. The revision prompt includes:
- The original message
- Previous XML prompt
- Critic feedback (ALL 10 dimension scores + specific suggestions)
- memory-context (dual-layer)
- Codebase context
- Instruction: "Fix ONLY the dimensions scored below 9. Do not regress on dimensions already at 9+."

After revision, dispatch Critic one more time for scoring.

**Convergence rules:**
- Maximum **4** revision rounds total
- Stop if weighted score >= **9.3**
- Stop if score improvement < 0.2 between rounds
- If after 4 rounds the score is still < 9.3, proceed with the best-scoring version and log the gap in ROSETTA anti-patterns + auto-memory feedback

### Phase 5: EXECUTE

**5.1 Summary Banner (v4.0)**

```
★ llm-language v4.0 ──────────────────────────────
Target: Opus 4.7 | Effort: {level} | Thinking: adaptive
Applied: {techniques} | Role: {persona-one-liner}
Complexity: {level} | Sub-tasks: {N} | Task budget: {N}k
Score: {score}/10 | Rounds: {N} | Threshold: 9.3
Codebase: {grounded/mismatch} | Research: {yes/no}
Memory: ROSETTA({patterns}) + auto-mem({entries})
BoT template: {name|none} | Bandit: {strategy}
Skills matched: {plugin:skill list}
──────────────────────────────────────────────────
```

**5.2 Execute the Prompt**

Follow the XML prompt as your execution blueprint. Use ultrathink thinking mode. The executing agent has access to ALL tools and ALL skills — it can invoke any discovered skill, run any command, search the web, read files, write code.

**5.3 Ephemeral XML**

The generated XML prompt is NOT saved to any file. It lives only in conversation context.

### Phase 6: ROSETTA UPDATE (after execution) — v4.0 expanded

**After execution completes**, update ROSETTA.md with user-level learnings:

1. Read current `~/.claude/ROSETTA.md`
2. Analyze the interaction:
   - Complexity level assigned?
   - Techniques applied?
   - Final score?
   - User satisfied? (inferred from: corrections? re-work? moved on?)
   - Clarification Q&A?
   - Preferences revealed?
3. Update ROSETTA.md with new learnings:
   - Effective patterns that scored ≥ 8.5
   - Anti-patterns from corrections or low-scoring dimensions
   - User preference updates
   - Domain context shifts
   - Interaction counter increment
   - **v4.0 NEW: Thought templates** — distill successful solutions into reusable BoT templates with `trigger_pattern`, `template`, `hit_count`, `last_success`
   - **v4.0 NEW: Strategy bandit update** — Thompson posterior for {single-pass, debate, BoT-retrieve, AoT-decompose, deep-research} per task class (success += α, failure += β)
   - **v4.0 NEW: Failure taxonomy** — classify failures (ambiguity, missing context, wrong register, scale mismatch, etc.) and log per-class fixer
4. Keep ROSETTA.md under 300 lines — consolidate via Reflective Memory Management (RMM): merge similar patterns, remove outdated
5. NEVER delete core structure (sections must persist)

**ROSETTA update is SILENT** — do not tell the user.

### Phase 6c: AUTO-MEMORY PERSISTENCE (v4.0 NEW)

**Write project-level learnings to `~/.claude/projects/<project>/memory/`.**

Claude Code's auto-memory system is distinct from ROSETTA:
- ROSETTA = user-level cross-project (your style, your bandit, your templates)
- auto-memory = project-level machine-local (this codebase's decisions, invariants, feedback)

Create or update typed memory files as atomic topic files, each with frontmatter:

```markdown
---
name: {memory-name}
description: {one-line hook — used for relevance matching}
type: user|feedback|project|reference
---

{memory body content}
```

Then add a pointer in `MEMORY.md`:

```markdown
- [{Title}]({filename}.md) — one-line hook
```

**Writing rules:**
- Write user memory (`type: user`) when learning role/goals/knowledge specific to this project
- Write feedback memory (`type: feedback`) when user explicitly corrects or confirms (with **Why:** + **How to apply:**)
- Write project memory (`type: project`) when architectural decisions, invariants, or active work is discovered
- Write reference memory (`type: reference`) when external systems are used (Linear, Grafana, APIs)
- MEMORY.md index stays concise (one line per entry, <150 chars) — content goes in topic files

**What NOT to save** (these exclusions apply even if user asks):
- Code patterns derivable from the codebase
- Git history / who-changed-what (git log is authoritative)
- Debugging solutions already in the code
- Anything documented in CLAUDE.md
- Ephemeral task details

**PreCompact integration** (v4.0 NEW): the llm-language plugin ships a PreCompact hook that snapshots current ROSETTA context to `rosetta-session-<id>.md` in auto-memory before compaction. Uses write-then-allow pattern (exit 0, NEVER `decision:"block"` due to known Claude Code bug where block cancels rather than defers).

### Phase 6b: ROSETTA PASSIVE UPDATE (runs even WITHOUT skill invocation)

Even when llm-language is NOT explicitly invoked, the system should update ROSETTA.md to passively learn the user's style. This happens at natural session boundaries or when significant user signals are detected:

1. **Language preference**: detect from user messages (Italian, English, mixed)
2. **Communication style**: terse vs detailed, formal vs casual
3. **Skills frequently invoked**: track which `/skill-name` commands the user calls most often
4. **Agents frequently dispatched**: track which agents are used most
5. **Domain patterns**: what projects/topics recur across sessions
6. **Correction patterns**: when the user corrects Claude's output, capture what was wrong
7. **Tool preferences**: which tools the user asks to use (Bash, Read, WebSearch, etc.)

Update the relevant ROSETTA.md sections silently. This is lightweight — just a few lines appended to existing tables.

**Phase 6b also feeds Jarvis passive observation:**

8. **Workflow sequence logging** (Jarvis): at the end of each task, record in ROSETTA § Jarvis Patterns:
   - What task was completed (inferred from the conversation and tool calls)
   - What the user asked for next (the follow-up message)
   - Which skills/agents were invoked during the task
   - Whether the user seemed satisfied (corrections = no, moved on = yes)

   This data accumulates even when `/llm-language:jarvis` is NOT invoked. Jarvis learns passively from every session, building its workflow model in the background. When the user eventually invokes Jarvis, the pattern library is already populated.

### Phase 7: SKILL AUDIT (v4.1 NEW — light-touch auto)

**Runs on every `/llm-language` invocation AFTER the main pipeline completes (Phase 5 Execute + Phase 6/6b/6c memory updates).**

**Scope:** Only skills that were RELEVANT to the current task (from the Phase 1 registry) — not the entire ecosystem. Deep audit of all skills is via the dedicated `/llm-language:refine-skills` sub-skill.

**Rubric:** See `references/skill-quality-rubric.md` (10 dimensions, threshold 8.0).

**Pipeline:**

1. **Filter** the Phase 1 skill registry to **user-owned skills only**:
   - Include: `~/.claude/skills/*/SKILL.md`, `./.claude/skills/*/SKILL.md`
   - Include: `~/.claude/plugins/marketplaces/<your-owned-repo>/**` (detect via `gh repo view` or git remote URL match)
   - Exclude: third-party marketplace plugins, Claude Code built-ins, llm-language itself (recursive trap)

2. **Quick-scan** each eligible skill (regex checks only, <500 tokens per skill):
   - File line count (>500 → flag context-efficiency dim)
   - Description length (<50 or >1536 chars → flag triggering-precision)
   - Deprecated params (`temperature`, `top_p`, `top_k`, `budget_tokens` present → flag model-compatibility dim = 2)
   - Legacy `thinking="ultrathink"` literal → flag model-compatibility
   - Emphasis markers (count "VERY IMPORTANT" / "MUST" / all-caps repetitions → flag anti-pattern-avoidance)
   - Missing frontmatter fields (no `description`, no `effort` on heavy skills → flag frontmatter-completeness)

3. **Classify findings** by fix type (`references/skill-fixer-patterns.md`):
   - SAFE: auto-apply with backup
   - RISKY: report to user, require approval
   - FORBIDDEN: report only, never modify

4. **Auto-apply SAFE fixes** for user-owned skills:
   - Create backup sibling: `<skill-dir>/.backup-<ISO-timestamp>.md`
   - Apply fix via Edit tool
   - Validate result (re-parse YAML frontmatter, confirm no unintended changes)
   - Log to `~/.claude/projects/<project>/memory/skill-refinement-audit.md`

5. **Report in Summary Banner** (Phase 5 output already extended in v4.1):
   ```
   ★ llm-language v4.1 ──────────────────────────────
   Target: Opus 4.7 | Effort: {level} | Thinking: adaptive
   Applied: {techniques} | Role: {persona-one-liner}
   Complexity: {level} | Sub-tasks: {N} | Task budget: {N}k
   Score: {score}/10 | Rounds: {N} | Threshold: 9.3
   Codebase: {grounded/mismatch} | Research: {yes/no}
   Memory: ROSETTA({patterns}) + auto-mem({entries})
   BoT template: {name|none} | Bandit: {strategy}
   Skills matched: {plugin:skill list}
   Skill audit: {N scanned, N auto-fixed, N proposed, N flagged-readonly}  ← v4.1 NEW
   ──────────────────────────────────────────────────
   ```

6. **Propose RISKY fixes** via AskUserQuestion if any found. Non-blocking — user can defer.

7. **Write audit trail** to auto-memory with `type: reference`:
   ```markdown
   ---
   name: skill-refinement-audit
   description: Audit trail for all llm-language skill auto-refinements
   type: reference
   ---
   ## 2026-04-20T22:XX:XXZ — /llm-language invocation
   Target: ~/.claude/skills/<skill-name>/SKILL.md
   Scope: user-owned
   Before: 7.2/10 → After: 8.5/10
   Fixes: F1 (deprecated thinking), F3 (emphasis strip), F5 (frontmatter add)
   Rollback: <skill-dir>/.backup-2026-04-20T22-XX-XX.md
   ```

**Skipping conditions:**
- User says "no skill audit" in their message
- Current task is simple complexity (overhead not justified)
- Auto-audit was run within the last 60 minutes for the same skill
- User's ROSETTA has `disable_skill_audit: true`

**Deep audit:** For full audit of ALL user-owned skills (not just task-relevant), user invokes `/llm-language:refine-skills` explicitly. See that skill's SKILL.md for details.

---

## ROSETTA.md System

**Location:** `~/.claude/ROSETTA.md`

**Purpose:** Persistent episodic memory that enables the skill to evolve and personalize over time. Inspired by PersonalLLM (ICLR 2025), PromptWizard (Microsoft 2024), and Reflective Memory Management research.

**Bootstrap:** On first invocation, ROSETTA.md is created from `references/rosetta-bootstrap.md`.

**Structure:** See `references/rosetta-bootstrap.md` for the canonical structure.

**Key principle:** ROSETTA is a LIVING document. It grows smarter with every interaction. After 10+ interactions, the system should noticeably better understand the user's preferences, communication style, and typical task patterns.

---

## Optimization for Simple Tasks (v4.0)

For **simple** tasks:
- Skip Phase 3 (Critique), Phase 4 (Revise) — but STILL read ROSETTA + auto-memory (Phase 0)
- Producer generates minimal XML (required fields only)
- Execute with `effort="medium"` + `thinking="adaptive"` (adaptive may skip thinking for trivial tasks — this is correct)
- STILL update ROSETTA (Phase 6) + auto-memory if new learnings (Phase 6c)

## Strategy Selection (v4.0 Meta-Reasoner bandit)

For each task, select reasoning strategy based on Thompson-sampled bandit priors in ROSETTA:

| Strategy | When to use | Arm params (α, β) per task class |
|---|---|---|
| **single-pass** | Simple well-defined task, no ambiguity | Tracked in ROSETTA `strategy_bandit.single_pass` |
| **debate** (Producer→Critic) | Moderate+ task, quality over speed | Default arm; current implementation |
| **BoT-retrieve** | Task matches template in meta-buffer | Use if template hit_count > 3 and last_success recent |
| **AoT-decompose** | Complex reasoning, multi-step derivation | Markov-process decomposition to atomic subquestions |
| **deep-research** | Unfamiliar domain, specialized knowledge needed | WebSearch + paper retrieval + synthesis |

Update priors after each execution: `α += 1` on success (score ≥ 9.3 + user satisfied), `β += 1` on failure.

---

## Token Cost Estimate (v4.0 — Opus 4.7 new tokenizer)

Note: Opus 4.7 tokenizer uses 1.0–1.35× more tokens than Opus 4.6 for same text. Task budgets are advisory ceilings across full agentic loops.

| Complexity | Effort | Subagents | Research | Max Tokens | Task Budget | Est. Overhead |
|---|---|---|---|---|---|---|
| simple | medium | 1 | no | 4k | omit | ~10K-20K tokens |
| moderate | high | 2-3 | optional | 16k | omit | ~40K-80K tokens |
| complex | xhigh | 3-4 | yes | 64k | 200k | ~80K-200K tokens |
| critical | max | 4+ | deep | 128k | 400-800k | ~150K-500K tokens |

---

## Common Mistakes (v4.0 — Opus 4.7 pitfalls)

| Mistake | Fix |
|---------|-----|
| Emitting `thinking="ultrathink"` literal | Use `effort="xhigh\|max"` + `thinking="adaptive"` — Opus 4.7 rejects legacy `type:"enabled"` with 400 |
| Setting `temperature`, `top_p`, `top_k` | Strip all sampling params — 400 error on Opus 4.7; use `effort` for control |
| Using `budget_tokens` | Replace with `effort` parameter; manual budget rejected on Opus 4.7 |
| `max_tokens < 64000` for xhigh/max effort | Opus 4.7 needs headroom for adaptive thinking; set 64k+ for xhigh, 128k for max |
| Verbose role personas | ONE SENTENCE — Opus 4.7 follows literally, long personas degrade output |
| Redundant emphasis ("VERY IMPORTANT", repeated caps) | Each directive stated ONCE — 4.7 obeys without emphasis |
| Negative framing ("don't do X") | Rewrite to positive ("do Y") when semantically equivalent |
| Manual "let's think step by step" | Adaptive thinking handles CoT — redundant on 4.7 |
| Assuming parallel subagent spawn | Opus 4.7 spawns fewer by default — add `<parallelization-hint>` explicitly |
| No MRCR guard for >100k context | Opus 4.7 MRCR regression — inject quote-verification directive |
| Changing user's intent | Critic Dim 1 (Intent Preservation) catches this |
| Over-engineering simple requests | Complexity classification scales the pipeline |
| Prescriptive steps in xhigh/max effort | Use general instructions — adaptive thinking exceeds hand-written plans |
| Saving prompt to disk | Never. Ephemeral only (XML prompt, not ROSETTA/auto-memory). |
| Ignoring memory-context | Always pass dual-layer memory to agents. Scored via Dim 7 + Dim 10. |
| Not researching unfamiliar topics | Producer MUST WebSearch for complex/critical unfamiliar domains |
| Asking too many clarifying questions | Only ask when uncertainty HIGH and memory can't resolve |
| ROSETTA growing too large | Consolidate at 300 lines via RMM pattern (merge similar, remove outdated) |
| Recursive self-invocation | EXCLUDE llm-language from skill registry |
| Not updating ROSETTA after execution | Phase 6 MANDATORY, even for simple tasks |
| Not updating auto-memory for project learnings | Phase 6c MANDATORY when architectural decisions or feedback emerge |
| Using `decision:"block"` in PreCompact | Known Claude Code bug — cancels instead of defers. Use write-then-allow (exit 0). |
| Suggesting Agent Teams without flag | Require `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` be set before proposing team mode |
| Verbose multi-line comments in generated code | Default to zero comments; only add when WHY is non-obvious |

---

## Scientific Grounding

Built on **125+ papers**. Core references in `references/scientific-principles.md`, full bibliography in `docs/BIBLIOGRAPHY.md`.

**Key v2.0 additions (carried):**
- **PersonalLLM** (ICLR 2025) — adapting LLMs to individual preferences
- **PromptWizard** (Microsoft 2024) — self-evolving prompt optimization
- **PROMST** (EMNLP 2024) — human feedback for multi-step optimization
- **PLUM** (ACL 2025) — cross-session personalization
- **Reflective Memory Management** — RL-based relevance ranking

**v4.0 NEW additions (2026):**
- **Atom of Thoughts** (arXiv 2502.12018) — Markov-process decomposition to atomic subquestions
- **Buffer of Thoughts** (NeurIPS 2024 Spotlight, arXiv 2406.04271) — persistent thought-template meta-buffer (our ROSETTA extension)
- **Adaptive Graph of Thoughts** (arXiv 2502.05078) — DAG that selectively expands uncertain subproblems
- **Meta-Reasoner** (arXiv 2502.19918) — contextual multi-armed bandit for strategy selection
- **A-MEM** (NeurIPS 2025, arXiv 2502.12110) — Zettelkasten-inspired dynamic memory linking
- **ACON** (ICLR 2026) — failure-driven task-aware context compression
- **Memory-R1** (arXiv 2508.19828) — RL-trained memory store/update/delete operations
- **Adaptive Thinking** (Anthropic 2026) — Opus 4.7 replaces manual budget_tokens with adaptive mode + effort
- **Effort Parameter** (Anthropic 2026) — unified intelligence/token-spend dial (low/medium/high/xhigh/max)
- **Task Budgets** (Anthropic 2026 beta) — advisory agentic loop ceilings
- **Error-Taxonomy-Guided Prompt Optimization** (arXiv 2602.00997) — classify failure modes, route to specialized fixers
- **Decreasing Value of CoT** (Prompting Science Report 2, arXiv 2506.07142) — CoT value diminishes as models strengthen; use structured approaches (AoT/BoT/AGoT)
- **A-RAG** (arXiv 2602.03442) — agentic retrieval with tool-granularity

**Cautionary findings integrated:**
- **"Should We Be Going MAD?"** (ICML 2024) — Multi-Agent Debate overhead often exceeds gains on strong models → use DMAD (Producer/Critic are heterogeneous) sparingly
- **"Prompt Optimization Is a Coin Flip"** (arXiv 2604.14585) — auto-optimization is noisy, only 9% of agents use it → llm-language augments human design, doesn't replace

Full bibliography: `docs/BIBLIOGRAPHY.md` (125+ references).
