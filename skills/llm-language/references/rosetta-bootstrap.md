# ROSETTA.md — Bootstrap Template (v4.0)

When `~/.claude/ROSETTA.md` does not exist, create it with the following content. Replace `{date}` with the current date.

**v4.0 additions vs v2.0:**
- `## Thought Templates` — Buffer-of-Thoughts meta-buffer (reusable solution schemas)
- `## Strategy Bandit` — Meta-Reasoner Thompson priors per task class
- `## Failure Taxonomy` — Error-Taxonomy-Guided fixer mapping
- `## Auto-Memory Pointers` — links to project-level auto-memory files
- `## Opus 4.7 Notes` — user-specific calibrations for Opus 4.7 quirks

---

```markdown
# ROSETTA — Adaptive Prompt Memory (v4.0)

> This file is maintained automatically by llm-language v4.0.
> It captures patterns that improve output quality for this specific user.
> Do not delete — the system reads it before every prompt optimization.
>
> Complementary to `~/.claude/projects/<project>/memory/` (project-level auto-memory).
> ROSETTA = user-level, cross-project, version-controllable.

**Created:** {date}
**Last updated:** {date}
**Interactions:** 0
**Target model:** claude-opus-4-7 (default) | claude-opus-4-6 | claude-sonnet-4-6

---

## User Profile

### Communication Style
- Language preference: (detected after first interactions — Italian/English/mixed)
- Verbosity preference: (terse / balanced / detailed — detected)
- Technical level: (beginner / intermediate / advanced / expert — detected)
- Preferred effort: (low / medium / high / xhigh / max — detected from "massima precisione" signals)
- **Preferred task granularity: micro-task-split (v4.1 DEFAULT)** — decompose complex tasks into 3-15 atomic micro-tasks, track via TaskCreate/TaskUpdate, execute sequentially with intermediate verification. Codified after empirical evidence that splitting produces more auditable, lower-error outcomes on multi-part critical work.

### Domain Expertise
- Primary domains: (detected after first interactions)
- Current projects: (detected after first interactions)
- Tech stack: (detected after first interactions)

### Output Preferences
- Preferred format: (code-first / explanation-first / mixed — detected)
- Wants educational insights: (yes/no — detected)
- Prefers examples: (yes/no — detected)
- Comment density: (zero / minimal / verbose — detected; default zero per Anthropic 4.7 guidance)

---

## Effective Patterns

Techniques and approaches that consistently produce high-quality results for this user.

### High-Scoring Techniques
| Technique | Context | Score | Date |
|---|---|---|---|
| (populated after first interactions) | | | |

### Preferred Role Personas
| Persona | Domain | User Response | Date |
|---|---|---|---|
| (populated after first interactions) | | | |

### Successful Prompt Structures
- (populated after first interactions)

### Standard Methodology Patterns (v4.1 defaults)

- **Micro-task splitting** — for any task of complexity ≥ moderate, decompose into 3-15 atomic micro-tasks (each independently verifiable). Track progress via TaskCreate / TaskUpdate. Execute sequentially. Verify intermediate outputs before proceeding. Rationale: reduces error compounding, enables granular rollback, provides audit trail.
- **Parallel batching within micro-tasks** — when micro-tasks have no dependency between them, batch into single response with multiple tool calls (Edit/Read/Write in parallel). Rationale: minimizes turn count without sacrificing granularity.
- **Verify-before-advance** — after each micro-task marked complete, verify via dedicated check (test run, Read to confirm content, grep for absence of regressions) BEFORE starting next micro-task.
- **Pre-flight verification** — before starting any destructive or mutating work, verify current state (git status, file contents, JSON validity). Rationale: no errors tolerated on max-precision tasks.

---

## Thought Templates (v4.0 — Buffer-of-Thoughts meta-buffer)

Distilled reusable solution schemas from past successful optimizations. When a new task matches a template's `trigger_pattern`, retrieve and adapt rather than regenerate from scratch.

| Template Name | Trigger Pattern | Template Body | Hit Count | Last Success | Status |
|---|---|---|---|---|---|
| (populated after first 5-10 interactions) | regex or keyword pattern | abbreviated XML skeleton | N | date | active/stale |

**Maintenance rules (BoT):**
- New templates distilled by Producer after score ≥ 9.3
- Template is considered ACTIVE if hit_count ≥ 3 AND last_success within 60 days
- Stale templates (hit_count < 3 after 30 days) are pruned during consolidation
- Templates are parameterized — leave `{placeholder}` for task-specific substitutions

---

## Strategy Bandit (v4.0 — Meta-Reasoner Thompson priors)

Contextual multi-armed bandit over reasoning strategies. Each arm tracks Beta(α, β) posterior per task class.

### Task Classes
- `code-architecture` — system design, module layout
- `code-implementation` — writing new functions/classes
- `code-refactoring` — modifying existing code
- `debugging` — diagnosing and fixing bugs
- `writing-technical` — documentation, reports, papers
- `writing-creative` — narrative, marketing, communication
- `research-synthesis` — literature review, comparison
- `data-analysis` — statistics, ML, data science
- `general-question` — factual Q&A, explanations

### Arm Posteriors (initialized to uniform Beta(1,1))

| Task Class | Arm | α | β | Hit Rate | Last Update |
|---|---|---|---|---|---|
| code-architecture | single-pass | 1 | 1 | — | — |
| code-architecture | debate | 1 | 1 | — | — |
| code-architecture | BoT-retrieve | 1 | 1 | — | — |
| code-architecture | AoT-decompose | 1 | 1 | — | — |
| code-architecture | deep-research | 1 | 1 | — | — |
| (populated for each task class × arm combination over time) | | | | | |

**Update rule:**
- On success (score ≥ 9.3 AND user satisfied): α += 1
- On failure (score < 8.5 OR user corrected): β += 1
- Sampling: for each task, draw posterior ~ Beta(α, β), pull arm with highest sampled value

---

## Failure Taxonomy (v4.0 — Error-Taxonomy-Guided fixers)

Classifies common failure modes and maps to specialized fixer prompts.

| Class | Symptom | Fixer Strategy |
|---|---|---|
| ambiguity | Output interpreted question wrongly | Escalate to AskUserQuestion with top-3 interpretations |
| missing-context | Output referenced wrong codebase parts | Re-run Phase 0.5 with broader Glob patterns |
| wrong-register | Output tone/formality mismatched preference | Inject explicit tone directive in <constraints> |
| scale-mismatch | Over-engineered for project scale | Add `<scale-constraint>` with team/budget data |
| stale-reference | Referenced deleted/renamed files | Run `git ls-files` before referencing paths |
| redundancy-bloat | Output repetitive or verbose | Apply Opus 4.7 literal-following rule (de-dup) |
| subagent-underuse | Claude didn't spawn parallel subagents | Add explicit `<parallelization-hint>` directive |
| mrcr-hallucination | Fabricated quotes from long context | Inject `<long-context-guard>` with quote-verify rule |

**Workflow:** When Critic flags low score on a dimension, Producer looks up the matching failure class and applies the mapped fixer during revision.

---

## Anti-Patterns

Approaches that failed, were corrected by the user, or scored poorly.

### Failed Approaches
| What was tried | What went wrong | Correction | Date |
|---|---|---|---|
| (populated after first interactions) | | | |

### User Corrections
- (populated after first interactions)

---

## Skill & Agent Usage

### Most Used Skills
| Skill | Times Used | Last Used | Notes |
|---|---|---|---|
| (populated automatically) | | | |

### Preferred Agents
| Agent | Times Dispatched | Avg Satisfaction | Notes |
|---|---|---|---|
| (populated automatically) | | | |

### Tool Preferences
| Tool | Frequency | Context | Notes |
|---|---|---|---|
| (populated automatically) | | | |

---

## Domain Context

### Active Projects
| Project | Tech Stack | Key Constraints | Status |
|---|---|---|---|
| (populated after first interactions) | | | |

### Recurring Themes
- (populated after first interactions)

---

## Auto-Memory Pointers (v4.0)

Links to project-level auto-memory files. ROSETTA is user-level; auto-memory is project-level. Both are consulted in Phase 0.

| Project | Auto-Memory Location | Last Indexed |
|---|---|---|
| (populated as projects are worked on) | `~/.claude/projects/<project>/memory/MEMORY.md` | date |

**Index format** (when populated): brief list of topic files per project so llm-language knows what's stored where without re-reading everything.

---

## Opus 4.7 Notes (v4.0)

User-specific calibrations for Opus 4.7 behavior quirks. Populated as observed.

### Observed quirks for this user
- (populated as user works with Opus 4.7 — e.g., "This user's prompts tend to trigger overthinking at max effort for financial analysis tasks → prefer xhigh")

### Ultrathink keyword usage
- Known Claude Code bug: ultrathink keyword downgrades to `high` when session is at `xhigh` or `max`
- Workaround: use `/effort max` explicitly instead of ultrathink keyword; or use separate sessions

### Deprecated params to strip
When generating prompts for Opus 4.7, NEVER emit:
- `temperature`, `top_p`, `top_k` (400 error)
- `thinking.type: "enabled"` with `budget_tokens` (400 error)
- Manual CoT trigger "let's think step by step" (redundant, Opus 4.7 adaptive handles)

### Task Budgets
- Beta header: `task-budgets-2026-03-13`
- Not supported in Claude Code at launch
- Only for direct Messages API use

---

## Jarvis Patterns (v3.2 — populated by /llm-language:jarvis)

Workflow sequence observations for proactive mode.

| Date | Task Done | Next Action | Confidence | Pattern |
|---|---|---|:----------:|---------|
| (populated by Jarvis observation phase) | | | | |

---

## Evolution Log

| Date | Change | Trigger |
|---|---|---|
| {date} | ROSETTA v4.0 initialized | First llm-language invocation |
```
