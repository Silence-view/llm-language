---
name: update
version: "3.2"
user-invocable: true
effort: high
description: >
  Auto-research new Claude Code features, prompting innovations, memory
  modalities, model deprecations, and best practices (Fable 5 / Opus 4.8
  era — Mythos-class aware; backward compatible with Opus 4.7/4.6/Sonnet 4.6).
  Searches official Anthropic docs, arXiv, YouTube, and community sources to
  identify updates that should be integrated into llm-language. v3.2 adds the
  Fable 5 / Mythos-class monitor (refusal surface, fallbacks param, classifier
  rerouting, subscription-window billing), dynamic-workflows/ultracode
  tracking, AutoDream watch, advisor-tool monitoring, and the refreshed P0
  deprecation table (Opus 4.1 → 2026-08-05, mythos-preview → 2026-06-30,
  Agent SDK credit claim 2026-06-15, Fable credits cutover 2026-06-22/23).
  v3.0 shipped /goal tracking + separate-evaluator pattern.
  Use when: "/llm-language:update", "check for updates", "update llm-language",
  "new prompting techniques", "Claude Code changelog", "new memory features",
  "/goal command", "agent view", "outcomes", "dreaming", "fable 5", "mythos".
---

# llm-language:update — Self-Evolution Research Agent (v3.2)

## v3.2 era note (2026-06-11)

The frontier moved: **Claude Fable 5** (`claude-fable-5`, Mythos-class tier ABOVE Opus, GA
2026-06-09) and **Opus 4.8** (`claude-opus-4-8`, new workhorse default since 2026-05-28).
Terminology: "Mythos-class", NEVER "Claude 5 family" (docs never use it). Authoritative
era reference: `skills/llm-language/references/fable-5-era.md`. New monitored surfaces:
refusal API (`stop_reason: "refusal"` + `stop_details.category`), `fallbacks` beta param,
classifier rerouting to Opus 4.8 (<5% sessions) + silent degradation controversy,
dynamic workflows / ultracode, nested sub-agents (≤5 levels), advisor tool (beta),
AutoDream (unofficial idle memory consolidation), MessageDisplay + post-session hooks.

**P0 deprecation table (refresh each run):** Sonnet 4 + Opus 4 retire 2026-06-15
(→ `claude-sonnet-4-6` / → **`claude-opus-4-8`**); Agent SDK billing split 2026-06-15
(separate monthly credit pool, **one-time manual claim required**); Fable 5 leaves plan
limits 2026-06-22→23 (prepaid usage credits); `claude-mythos-preview` retires 2026-06-30
(→ `claude-mythos-5`); fast mode on Opus 4.6 removed ~late June; Opus 4.1 retires
2026-08-05 (→ `claude-opus-4-8`).

## Overview
Autonomous research agent that keeps llm-language current by searching for:
- **Claude model updates** (Fable 5 / Mythos-class, Opus 4.8+, Sonnet 4.6+, Haiku 4.5+, new effort tiers, adaptive thinking, task budgets, tokenizer changes, refusal/fallback API surface)
- **Claude Code features** (hooks, skills, plugins, memory, output styles, agent view, background sessions, **`/goal` + Outcomes** pattern)
- **Long-horizon autonomy primitives** (`/goal`, Outcomes, Dreaming, separate-evaluator patterns)
- **New prompting research** (arXiv, NeurIPS, ICLR, ACL, EMNLP — 2025-2026; MAD, MASPO, Tournament-of-Prompts, OPTAGENT, SDRL, Agentic Memory)
- **Memory systems** (auto-memory MEMORY.md, Memory Tool API, Memory Import, claude-mem, mem0/letta/zep/cognee, Dreaming consolidation)
- **Agent framework ecosystem** (OpenAI Agents SDK, Google ADK + A2A 1.2, Microsoft Agent Framework, CrewAI, LangGraph)
- **Community innovations** (plugins, skills, hooks, marketplace, awesome-claude-code-toolkit, claude-mem)
- **YouTube content** (demos, reviews, walkthroughs — via yt-learner skill)
- **Deprecation & billing watch** (P0: Sonnet 4 / Opus 4 retire 2026-06-15; Agent SDK Credit pool split)

**v3.0 changes vs v2.0:**
- **`/goal` command** as a first-class monitored feature AND as an internal mechanism to run the update loop itself
- **Separate-evaluator pattern** (`/goal` ⇄ Outcomes ⇄ LangGraph HITL ⇄ verification-before-completion) flagged as cross-vendor convergence — recommended integration
- **P0 deprecation tracking** (model retirement dates surfaced explicitly with migration mappings)
- **Agent SDK billing-split warning** (separate credit pool from 2026-06-15)
- **A2A protocol 1.2** monitoring (signed agent cards, multi-vendor interop)
- **Token-compaction tracking** (ADK Event Compaction, Anthropic server-side compaction beta, Opus 4.7 tokenizer +0–35%)
- **Outcomes + Dreaming** as new monitored Anthropic primitives
- **Negative-result reporting** required (e.g., "no Sonnet 4.7 exists — Anthropic skipped that number")
- Reordered priority tiers to surface P0 deprecations before feature additions

## When to Use
Explicitly invoked via `/llm-language:update` or when user asks about updates, new memory features, Opus 4.7, `/goal`, Outcomes, Dreaming, Agent View, deprecations, or agent frameworks.

## Pipeline (v3.0)

### Step 1: Parallel Research Dispatch

Launch 3–4 background agents in parallel (≤ 4 to avoid rate-limit). Brief each as a self-contained research agent with explicit "do not fabricate, cite URLs, flag low-confidence" rules.

**Agent A — Anthropic + Academic Deep Research (deep-research or general-purpose)**
- Task: official docs, changelog, anthropic.com/news, arXiv 2025–2026
- Focus: `/goal`, Outcomes, Dreaming, Agent View, model deprecations, tokenizer changes, new effort tiers
- Must cross-verify every Anthropic-feature claim across ≥ 2 sources (official docs + one independent)

**Agent B — YouTube Research (yt-learner or general-purpose)**
- Task: find YouTube videos on recent updates
- Channels: AI Explained, Matthew Berman, Bycloud, David Shapiro, 1littlecoder, Prompt Engineering, Fireship, Two Minute Papers, Indy Dev Dan, Cole Medin, All About AI, Sam Witteveen, World of AI
- Note: YouTube anti-scraping often blocks channel/date extraction — accept partial attribution; cross-reference via aggregator articles

**Agent C — Memory + Framework + Community (general-purpose)**
- Task: memory modalities, agent frameworks, community ecosystem
- Focus: claude-mem, mem0/letta/zep, OpenAI Agents SDK, Google ADK, A2A protocol, Microsoft Agent Framework, LangGraph, CrewAI; awesome-claude-code-* repos; Simon Willison posts; Reddit r/ClaudeAI

**Agent D (optional, only when scope demands) — Targeted Feature Deep-Dive**
- Use when a specific high-impact feature (e.g., `/goal`) needs verbatim docs extraction + code-pattern study
- Do not launch unless A/B/C cannot satisfy

### Step 2: Direct WebSearch + WebFetch (in parallel with agents)

Run 4–6 targeted queries for immediate signal **while** agents work in background:

1. `Claude {NextOpus} OR {NextSonnet} release features {current_year}`
2. `Claude Code changelog {current_year} {current_month} new features`
3. `Claude Code "/goal" OR Outcomes OR Dreaming OR "Agent View" {current_year}`
4. `site:arxiv.org prompt optimization OR multi-agent debate OR agentic memory {current_year}`
5. `Claude Code memory MEMORY.md auto-memory {current_year}`
6. `Anthropic model deprecation OR retirement {current_year}`

Direct WebFetch authoritative pages (always preferred over secondary blogs):
- `https://code.claude.com/docs/en/changelog`
- `https://code.claude.com/docs/en/whats-new`
- `https://code.claude.com/docs/en/goal`
- `https://code.claude.com/docs/en/agent-view`
- `https://platform.claude.com/docs/en/about-claude/models/overview`
- `https://platform.claude.com/docs/en/about-claude/model-deprecations`
- `https://www.anthropic.com/news`
- `https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md` (use raw URL — `https://github.com/anthropics/claude-code/raw/refs/heads/main/CHANGELOG.md` — when WebFetch returns nav-only)

### Step 3: Diff Analysis

Compare findings against current llm-language capabilities:
- Read `skills/llm-language/SKILL.md` — what's implemented?
- Read `references/scoring-rubric.md` — what dimensions exist?
- Read `references/scientific-principles.md` + `docs/BIBLIOGRAPHY.md` — what papers are referenced?
- Read `references/xml-prompt-template.md` — current schema version?
- Read `.claude-plugin/plugin.json` + `marketplace.json` — installed version?
- Read `hooks/` directory — shipped hooks?
- Read `skills/jarvis/SKILL.md` + `skills/refine-skills/SKILL.md` — sub-skills state?

**Identify GAPS:**
- New model features not leveraged (effort tiers, tokenizer changes, thinking budgets)
- New hooks not used (PreCompact, TaskCreated, PermissionDenied, SubagentStart, **`effort.level`/`$CLAUDE_EFFORT` exposure**)
- New autonomy primitives not integrated (`/goal`, Outcomes, separate-evaluator)
- New memory modes not integrated (Dreaming, Memory Import, Memory for Managed Agents)
- New papers not referenced
- Community patterns not adopted
- Agent framework patterns worth borrowing (ADK Event Compaction, OpenAI harness+sandbox, LangGraph HITL checkpoints)
- **Deprecation exposure** (any pinned model IDs in llm-language scoring/templates that retire soon?)

### Step 4: Impact Assessment

For each finding, assess:

| Dimension | Scoring |
|---|---|
| **Relevance** | 0-10 — applies to prompt optimization / agent design? |
| **Impact** | 0-10 — integration measurably improves quality? |
| **Effort** | low / medium / high |
| **Breaking** | yes / no — requires migration? |
| **Time-pressure** | days / weeks / months until forced |
| **Priority** | `Relevance × Impact ÷ Effort_weight`, filtered by breaking + time-pressure |

**Priority tiers (v3.0 reordered — P0 surfaces deprecations first):**
- **P0 (critical, time-bound)** — model deprecations with dates, API removals, billing changes, security CVEs
- **P1 (high)** — significant quality gains (Impact ≥ 8), reasonable effort
- **P2 (medium)** — nice-to-have improvements
- **P3 (low)** — documentation, polish, future-proofing

### Step 5: Report

Present findings as structured report:

```
★ llm-language:update v3.0 ──────────────────────
Research date: {date}
Sources scanned: {N} (official docs + papers + YouTube + changelog + community)
Agents dispatched: {N}
New findings: {N relevant}
Actionable updates: {N priority > 7}
──────────────────────────────────────────────────

## P0 — Time-Bound Breaking Changes
[Model retirements with dates, billing changes, must-have migrations]

## P0 — Negative Results
[What does NOT exist (e.g., "no Sonnet 4.7") — to prevent future hallucination]

## Claude Model Updates
[Versions, effort tiers, thinking modes, tokenizer notes]

## Claude Code Features
[/goal, Outcomes, Dreaming, Agent View, hooks, skills, plugins, memory, commands]

## Long-Horizon Autonomy Primitives  ← NEW v3.0 section
[Separate-evaluator pattern across vendors; integration recipes]

## New Prompting Research
[Papers with arXiv IDs + venue + one-line takeaway]

## Memory Modalities
[Auto-memory, Memory Tool API, Memory Import, Dreaming, third-party MCP memory servers]

## Agent Framework Insights
[Patterns from OpenAI/Google/Microsoft/CrewAI/LangGraph + A2A protocol status]

## YouTube Takeaways
[Top N videos with actionable insights + creator confidence notes]

## Community Innovations
[Notable plugins, skills, hooks, marketplaces]

## Recommended Actions (Priority-ordered)
- [P0] Critical migrations (with deadline)
- [P1] High-impact integrations
- [P2] Medium-impact improvements
- [P3] Polish
```

### Step 6: Optional Auto-Apply

If the user approves (or in auto mode), apply the highest-priority updates:
- Update `plugin.json` version (semantic: **major** for breaking, **minor** for features, **patch** for fixes)
- Update `marketplace.json` to match
- Update `SKILL.md` files (llm-language, jarvis, refine-skills, update itself) with new features
- Update `scoring-rubric.md` if new dimensions needed
- Update `scientific-principles.md` + `docs/BIBLIOGRAPHY.md` with new papers
- Update `rosetta-bootstrap.md` if schema change
- Update `xml-prompt-template.md` if schema change
- Create new `references/` files for major migration guides (e.g., `goal-integration.md`, `deprecation-2026-06-15.md`)
- Ship new hooks in `hooks/` directory (e.g., a hook that warns when a deprecated model ID is detected in transcripts)
- Update `README.md` to reflect version change

### Step 7: ROSETTA Update

Log the research session in ROSETTA.md Evolution Log:
- Date (ISO)
- Versions before → after
- Findings summary (one line per P0/P1)
- Changes applied (file-level)
- User feedback (if any)
- Confidence notes (which claims are well-sourced vs speculative)

### Step 8: Git Commit (if applicable)

If running in a git repo (llm-language source):
- Stage changed files (NEVER `git add .` — list paths explicitly)
- Commit with conventional format: `feat(vX.Y.Z): {summary}` / `fix(vX.Y.Z): {summary}` / `chore(vX.Y.Z): deprecation watch`
- Push to origin/main **only with user authorization**
- For breaking changes (major bump), require explicit user approval before commit

---

## Cross-Reference: llm-language v4.3 Native `/goal` Integration

As of llm-language v4.3.0 (2026-05-20), `/goal` is integrated as a first-class primitive at **Phase 1.4b (Goal Gate)** + **Phase 5.0 (Execute Wrapper)** of the main skill. The integration was decided via 3-agent debate (architecture / safety / cost — all three converged on the same hybrid placement) and follows the separate-evaluator pattern documented in `scientific-principles.md` § F8.

Key invariants enforced by the integration:
- 8-clause activation predicate (complex/critical + xhigh/max + task_budget≥200K + multi-step + hooks_enabled + no_loop + no_outer_goal + depth=0)
- Deterministic condition synthesis from `<acceptance-criteria>` + `<sub-tasks>` (Producer is NOT involved)
- Bound N = 15 (complex) / 30 (critical) / N_max = 40
- EVIDENCE block per turn mandatory
- Allowlist scope-creep prevention via PreToolUse hooks
- Three cost guards (per-run / per-day / per-month projection)
- Audit JSON in `auto-memory/goal_invocations/<run_id>.json`
- Critical tier behind feature flag until false_positive_rate < 5% over ≥ 50 runs

When `update` finds new `/goal`-adjacent features (Outcomes evolution, new evaluator models, A2A 1.2 cross-vendor signed cards), assess impact against this integration; propose changes to Phase 1.4b predicate or Phase 5.0 synthesis template.

## Using `/goal` to Power the Update Loop Itself (v3.0 recipe)

The `/goal` command is itself a tool to make `/llm-language:update` more autonomous. Recommended invocation when the user wants a hands-off update sweep:

```
> /goal report contains P0/P1/P2/P3 sections, every P0 has source URL + deadline, no fabricated arXiv IDs, and SKILL.md version bumped if any P0/P1 applied or stop after 25 turns
```

Why this works:
- **Separate evaluator** (Haiku default) cheaply checks each turn whether report meets the contract — much cheaper than the executor model
- **Verifiable finish line** — the rubric forces measurable conditions (avoids "make report better" anti-pattern)
- **Bound clause** (`or stop after 25 turns`) prevents token blow-up since `/goal` has no native turn cap
- **Cost note** — evaluator tokens are billed on small/fast model pool; main-turn spend dominates

⚠️ **`/goal` caveats** (must respect):
- Evaluator does NOT call tools — only judges what's surfaced in the transcript. Conditions like "tests pass" only hold if Claude actually ran tests and surfaced output.
- Requires trusted workspace; blocked by `disableAllHooks` or `allowManagedHooksOnly`.
- One active goal per session; persists across `--resume`/`--continue` (turn count resets).
- Scope creep risk — agent may "fix adjacent messy code". Scope the condition narrowly.

---

## Key Sources to Monitor (v3.0)

### Anthropic Official
| Source | URL | What to look for |
|--------|-----|-----------------|
| Anthropic News | anthropic.com/news | Model launches, major announcements |
| Claude API Docs | platform.claude.com/docs | Feature docs, migration guides |
| **Model Deprecations** | platform.claude.com/docs/en/about-claude/model-deprecations | P0 retirement dates + migration mappings |
| Claude Code Docs | code.claude.com/docs | Skills, hooks, plugins, memory |
| Claude Code Changelog | code.claude.com/docs/en/changelog | Version-by-version changes |
| **What's New (weekly digest)** | code.claude.com/docs/en/whats-new | Curated week-by-week summary |
| **`/goal` docs** | code.claude.com/docs/en/goal | Authoritative goal command reference |
| **Agent View docs** | code.claude.com/docs/en/agent-view | Background sessions, agent dashboard |
| Anthropic Engineering Blog | anthropic.com/engineering | Best practices, patterns |
| Code w/ Claude conference | claude.com/blog/code-w-claude-{year} | Annual feature reveals (Dreaming, Outcomes) |

### Academic
| Source | URL | What to look for |
|--------|-----|-----------------|
| arXiv cs.CL | arxiv.org/list/cs.CL | Prompt optimization, reasoning, MAD |
| arXiv cs.SE | arxiv.org/list/cs.SE | LLM-assisted development |
| arXiv cs.AI | arxiv.org/list/cs.AI | Agent frameworks, memory |
| arXiv cs.MA | arxiv.org/list/cs.MA | Multi-agent systems |
| NeurIPS / ICLR / ACL / EMNLP / COLM | proceedings | Peer-reviewed |
| OpenReview | openreview.net | Pre-print / in-review |

**Papers to track explicitly (2026 wave, verify before citing):**
- MASPO — Joint Prompt Optimization for Multi-Agent Systems
- Tournament of Prompts — Elo + structured debates
- OPTAGENT — Verbal RL for inter-agent communication
- Self-Debate RL (SDRL) — pre-deployment MAD prep
- Iterative Audit Convergence — prompt QA loops
- From Storage to Experience — agent memory survey
- Agentic Memory / AgeMem — memory ops as tool-actions
- Security of Long-Term Memory — Write/Store/Retrieve/Execute/Share lifecycle

### Community
| Source | URL | What to look for |
|--------|-----|-----------------|
| Claude Code GitHub | github.com/anthropics/claude-code | Issues, PRs, plugin samples |
| awesome-claude-code | github.com/hesreallyhim/awesome-claude-code | Curated ecosystem |
| awesome-claude-code-toolkit | github.com/rohitg00/awesome-claude-code-toolkit | Agents, skills, commands, plugins |
| awesome-claude-plugins | github.com/quemsah/awesome-claude-plugins | Automated plugin index (15k+) |
| claude-mem | github.com/thedotmack/claude-mem | Local persistent memory (SQLite + ChromaDB) |
| Reddit r/ClaudeAI | reddit.com/r/ClaudeAI | User experiences, gotchas |
| Hacker News | news.ycombinator.com | Discussion threads |
| Simon Willison's blog | simonwillison.net | Deep analyses, system prompt diffs, live conference notes |

### YouTube Channels (for yt-learner / Agent B)
- AI Explained, Matthew Berman, Bycloud, David Shapiro, 1littlecoder
- Prompt Engineering, Fireship, Two Minute Papers
- Indy Dev Dan, Cole Medin, All About AI, Sam Witteveen, World of AI

### Agent Framework Ecosystem
- OpenAI Agents SDK (openai.github.io/openai-agents-python) — harness + sandbox + configurable memory
- Google ADK + **A2A 1.2** (google.github.io/adk-docs) — Event Compaction, signed agent cards
- Microsoft Agent Framework (docs) — Semantic Kernel + AutoGen unified
- CrewAI (docs.crewai.com)
- LangGraph (docs.langchain.com/oss/python/langgraph) — HITL checkpoints, deep-agent templates
- Anthropic Claude Agent SDK — note **billing split from 2026-06-15** (separate credit pool)

---

## Anti-Patterns (v3.0)

### Research process
- Do NOT auto-apply breaking changes without explicit user confirmation
- Do NOT add papers without verifying arXiv IDs (especially when search returns only titles)
- Do NOT cite vendor marketing copy as authoritative — always seek primary documentation
- Do NOT fabricate YouTube URLs, channel names, or upload dates — YouTube anti-scraping often blocks attribution; report partial findings explicitly
- Do NOT recommend features that conflict with current SKILL.md architecture without documenting the migration
- Do NOT bloat scientific-principles.md beyond its current structure (add, don't duplicate)
- Do NOT ignore sobering findings (e.g., "Prompt Optimization Is a Coin Flip" — auto-optimization variance)
- Do NOT commit to git without user authorization
- Do NOT dispatch more than 4 parallel agents — diminishing returns and rate limits
- Do NOT recommend Opus 4.7-specific features when user's target model is older (check ROSETTA for preferred target)
- **NEW v3.0**: Do NOT omit a P0 section just because nothing seems urgent — explicit "no current P0 items" is the correct output. The check itself is the value.
- **NEW v3.0**: Do NOT skip negative-result reporting (e.g., "Sonnet 4.7 does not exist") — surfaces version-confusion that propagates through prompts.

### `/goal`-specific (when using `/goal` internally)
- Do NOT use vague conditions ("make report comprehensive") — evaluator silently fails
- Do NOT omit the bound clause (`or stop after N turns`) — no native cap, token blow-up
- Do NOT assume evaluator ran tools — it only sees the transcript
- Do NOT run `/goal` in `disableAllHooks` mode — it is itself a hook
- Do NOT chain `/goal` with `/loop` — they conflict (`/loop` retriggers on interval, `/goal` after each turn)

---

## v3.0 Enhancements over v2.0

- **`/goal` first-class tracking** — promoted from "any new commands" bucket to its own monitored primitive, with the Codex-cloned origin documented
- **Separate-evaluator pattern recognition** — `/goal` ⇄ Outcomes ⇄ LangGraph HITL ⇄ ADK ⇄ `verification-before-completion` flagged as cross-vendor convergence
- **`/goal`-driven update loop** — explicit recipe to make the update sweep autonomous via `/goal`
- **P0 deprecation watch** — Sonnet 4 / Opus 4 retirement (2026-06-15) surfaced as P0 with migration mappings (`claude-sonnet-4-20250514` → `claude-sonnet-4-6`, `claude-opus-4-20250514` → `claude-opus-4-8` — corrected v3.2: target is 4.8, not 4.7)
- **Agent SDK billing split** — separate "Agent SDK Credit pool" effective 2026-06-15 documented as P0 operational change
- **A2A protocol 1.2** — multi-vendor agent interop standard (Linux Foundation Agentic AI Foundation) added to ecosystem monitor
- **Token-compaction tracking** — ADK Event Compaction, Anthropic server-side compaction beta, Opus 4.7 tokenizer (1.0–1.35× more tokens than 4.6)
- **Outcomes + Dreaming** — new Anthropic primitives (Code w/ Claude 2026-05-06 keynote) added to monitor list
- **Agent View + background sessions** — `claude --bg`, `/bg`, `claude agents` dashboard
- **Negative-result reporting** — required when version-confusion exists (e.g., no Sonnet 4.7)
- **Raw-URL fallback** — when WebFetch on github.com/blob returns nav-only, retry with `raw/refs/heads/main/...`
- **Reordered priority tiers** — P0 deprecations and billing surface before feature additions
- **Confidence notes mandatory** in final report — every finding tagged high/medium/low confidence with source count
