---
name: update
version: "2.0"
user-invocable: true
effort: high
description: >
  Auto-research new Claude Code features, prompting innovations, memory
  modalities, and best practices (targeting Opus 4.7 era). Searches academic
  papers, Anthropic changelog, YouTube, and community resources to identify
  updates that should be integrated into llm-language. v2.0 adds parallel
  agent dispatch, YouTube research via yt-learner, agent framework comparison,
  memory modality tracking, and model-specific migration checks.
  Use when: "/llm-language:update", "check for updates", "update llm-language",
  "new prompting techniques", "Claude Code changelog", "new memory features".
---

# llm-language:update — Self-Evolution Research Agent (v2.0)

## Overview
Autonomous research agent that keeps llm-language current by searching for:
- **Claude model updates** (Opus 4.7+, new effort levels, adaptive thinking, task budgets)
- **Claude Code features** (hooks, skills, plugins, memory modes, agent teams)
- **New prompting research** (arXiv, NeurIPS, ICLR, ACL, EMNLP — 2025-2026)
- **Memory systems** (auto-memory, Memory Tool API, MCP bridges like mem0/letta/zep)
- **Agent framework ecosystem** (OpenAI SDK, Google ADK, Microsoft Agent Framework, CrewAI, LangGraph)
- **Community innovations** (plugins, skills, hooks, marketplace)
- **YouTube content** (demos, reviews, walkthroughs — via yt-learner skill)

**v2.0 changes vs v1.0:**
- Parallel agent dispatch (deep-research + yt-learner + memory-research)
- Memory modality tracking (auto-memory, Memory Tool, external MCP)
- Agent framework comparison (5+ frameworks benchmarked)
- Model migration checks (Opus 4.7 breaking changes detection)
- Richer report format with priority tiers

## When to Use
Explicitly invoked via `/llm-language:update` or when user asks about updates / new memory features / Opus 4.7 / agent frameworks.

## Pipeline (v2.0)

### Step 1: Parallel Research Dispatch

Launch 3-4 background agents in parallel:

**Agent A — Deep Research (deep-research skill or general-purpose agent)**
- Task: find new papers, Anthropic docs, framework updates
- Focus: arXiv cs.CL, cs.SE, Anthropic platform docs, Claude Code docs

**Agent B — YouTube Research (yt-learner skill or general-purpose agent)**
- Task: find YouTube videos on recent updates
- Focus: AI Explained, Matthew Berman, Bycloud, David Shapiro, 1littlecoder, Prompt Engineering channel, Two Minute Papers

**Agent C — Memory Modality Research (general-purpose agent)**
- Task: investigate new memory features in Claude Code and ecosystem
- Focus: auto-memory, Memory Tool API, mem0/letta/zep, claude-mem plugin, Obsidian MCP

**Agent D (optional) — Framework Comparison (general-purpose agent)**
- Task: benchmark llm-language against other agent frameworks
- Focus: OpenAI Agents SDK, Google ADK, Microsoft Agent Framework, CrewAI, LangGraph

### Step 2: Direct WebSearch (in parallel with agents)

4 targeted queries for immediate signal:
1. `Claude Opus 4.7 OR 4.8 release features {current_year}`
2. `Claude Code changelog {current_year} {current_month} new features`
3. `site:arxiv.org prompt engineering OR prompt optimization {current_year}`
4. `Claude Code memory MEMORY.md auto-memory {current_year}`

### Step 3: Diff Analysis

Compare findings against current llm-language capabilities:
- Read current `skills/llm-language/SKILL.md` — what's already implemented?
- Read `references/scoring-rubric.md` — what dimensions exist?
- Read `references/scientific-principles.md` — what papers are referenced?
- Read `references/xml-prompt-template.md` — what's the current schema version?
- Read `.claude-plugin/plugin.json` — what version is installed?
- Read `hooks/` directory — what hooks are already shipped?

**Identify GAPS:**
- New model features not leveraged (effort levels, task budgets, adaptive thinking)
- New hooks not used (PreCompact, TaskCreated, PermissionDenied, SubagentStart)
- New memory modes not integrated
- New papers not referenced
- Community patterns not adopted
- Agent framework patterns that could be borrowed

### Step 4: Impact Assessment

For each finding, assess:

| Dimension | Scoring |
|---|---|
| **Relevance** | 0-10 — does it apply to prompt optimization? |
| **Impact** | 0-10 — would integration measurably improve quality? |
| **Effort** | low / medium / high — integration complexity |
| **Breaking** | yes / no — does it require migration (model change, API removal)? |
| **Priority** | `Relevance × Impact ÷ Effort_weight` — filtered by breaking status |

**Priority tiers:**
- **P0 (critical)** — breaking changes, model deprecations, must-have compliance
- **P1 (high)** — significant quality gains (Impact ≥ 8), reasonable effort
- **P2 (medium)** — nice-to-have improvements, moderate effort
- **P3 (low)** — documentation, polish, future-proofing

### Step 5: Report

Present findings as structured report:

```
★ llm-language:update ──────────────────────────
Research date: {date}
Sources scanned: {N} (docs + papers + YouTube + changelog)
Agents dispatched: {N}
New findings: {N relevant}
Actionable updates: {N priority > 7}
──────────────────────────────────────────────────

## Breaking Changes (P0)
[Model deprecations, API removals, must-have migrations]

## Claude Model Updates
[New model versions, effort levels, thinking modes]

## Claude Code Features
[Hooks, skills, plugins, memory, commands]

## New Prompting Research
[Papers with arXiv IDs + citation + venue]

## Memory Modalities
[Auto-memory, Memory Tool API, external MCP integrations]

## Agent Framework Insights
[Patterns from OpenAI/Google/Microsoft/CrewAI/LangGraph worth borrowing]

## YouTube Takeaways
[Ranked top N videos with actionable insights]

## Community Innovations
[Notable plugins, skills, hooks]

## Recommended Actions (Priority-ordered)
- [P0] Critical migrations
- [P1] High-impact integrations
- [P2] Medium-impact improvements
- [P3] Polish
```

### Step 6: Optional Auto-Apply

If the user approves (or in auto mode), apply the highest-priority updates:
- Update `plugin.json` version (semantic: major for breaking, minor for features)
- Update `marketplace.json` to match
- Update `SKILL.md` with new features
- Update `scoring-rubric.md` if new dimensions needed
- Update `scientific-principles.md` + `docs/BIBLIOGRAPHY.md` with new papers
- Update `rosetta-bootstrap.md` if schema change
- Update `xml-prompt-template.md` if schema change
- Create new `references/` files for major migration guides
- Ship new hooks in `hooks/` directory
- Update `README.md` to reflect version change

### Step 7: ROSETTA Update

Log the research session in ROSETTA.md Evolution Log. Capture:
- Date
- Changes applied
- Rationale
- User feedback (if any)

### Step 8: Git Commit (if applicable)

If running in a git repo (e.g., llm-language source repo):
- Stage changed files
- Commit with conventional format: `feat(vX.Y.Z): {summary}` for features, `fix(vX.Y.Z): {summary}` for fixes
- Push to origin/main if authorized
- Note: user confirmation required for push operations

## Key Sources to Monitor (v2.0)

### Anthropic Official
| Source | URL | What to look for |
|--------|-----|-----------------|
| Anthropic News | anthropic.com/news | Model launches, major announcements |
| Claude API Docs | platform.claude.com/docs | Feature docs, migration guides |
| Claude Code Docs | code.claude.com/docs | Skills, hooks, plugins, memory |
| Claude Code Changelog | code.claude.com/docs/en/changelog | Version-by-version changes |
| Anthropic Engineering Blog | anthropic.com/engineering | Best practices, patterns |

### Academic
| Source | URL | What to look for |
|--------|-----|-----------------|
| arXiv cs.CL | arxiv.org/list/cs.CL | Prompt optimization, reasoning |
| arXiv cs.SE | arxiv.org/list/cs.SE | LLM-assisted development |
| arXiv cs.AI | arxiv.org/list/cs.AI | Agent frameworks, memory |
| NeurIPS / ICLR / ACL / EMNLP | proceedings | Peer-reviewed prompt research |
| OpenReview | openreview.net | Pre-print / in-review papers |

### Community
| Source | URL | What to look for |
|--------|-----|-----------------|
| Claude Code GitHub | github.com/anthropics/claude-code | Issues, PRs, plugin samples |
| awesome-claude-code | github.com/hesreallyhim/awesome-claude-code | Curated ecosystem |
| Reddit r/ClaudeAI | reddit.com/r/ClaudeAI | User experiences, gotchas |
| Hacker News | news.ycombinator.com | Discussion threads |
| Simon Willison's blog | simonwillison.net | Deep analyses, system prompt diffs |

### YouTube Channels (for yt-learner)
- AI Explained
- Matthew Berman
- Bycloud
- David Shapiro
- 1littlecoder
- Prompt Engineering
- Fireship (for brief dev updates)
- Two Minute Papers (for paper coverage)

### Agent Framework Ecosystem
- OpenAI Agents SDK (openai.github.io/openai-agents-python)
- Google ADK + A2A (google.github.io/adk-docs)
- Microsoft Agent Framework (docs)
- CrewAI (docs.crewai.com)
- LangGraph (docs.langchain.com/oss/python/langgraph)

## Anti-Patterns (v2.0)

- Do NOT auto-apply breaking changes without explicit user confirmation
- Do NOT add papers that aren't peer-reviewed OR from established authors / official Anthropic sources
- Do NOT recommend features that conflict with current SKILL.md architecture without documenting the migration
- Do NOT bloat scientific-principles.md beyond its current structure (add, don't duplicate)
- Do NOT cite vendor marketing copy as authoritative — always seek primary documentation
- Do NOT ignore sobering findings (e.g., "Prompt Optimization Is a Coin Flip" — auto-optimization is noisy)
- Do NOT commit to git without user authorization
- Do NOT dispatch more than 4 parallel agents — diminishing returns and rate limits
- Do NOT recommend Opus 4.7-specific features when user's target model is older (check ROSETTA for preferred target)

## v2.0 Enhancements over v1.0

- **Parallel agent dispatch** — up to 4 background agents working in parallel, not sequential searches
- **YouTube integration** — first-class citizen via yt-learner skill
- **Memory modality tracking** — explicit agent for new memory features (distinct from general updates)
- **Framework benchmarking** — compares llm-language architecture against 5+ agent frameworks
- **Breaking change detection** — P0 tier flags migrations required for model deprecations
- **Auto-apply with git commit** — end-to-end update → test → commit → push workflow
- **Cautionary balance** — integrates "sobering findings" to prevent overclaiming (MAD overhead, prompt optimization variance)
