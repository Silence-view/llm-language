---
name: update
version: "1.0"
user-invocable: true
description: >
  Auto-research new Claude Code features, prompting innovations, and best
  practices. Searches academic papers, Anthropic changelog, and community
  resources to identify updates that should be integrated into llm-language.
  Use when: "/llm-language:update", "check for updates", "update llm-language",
  "new prompting techniques", "claude code changelog".
---

# llm-language:update — Self-Evolution Research Agent

## Overview
Autonomous research agent that keeps llm-language current by searching for:
- New Claude Code features (changelog, blog posts, release notes)
- New prompting techniques (academic papers, arXiv, conferences)
- CLAUDE.md best practices evolution (Anthropic official docs)
- Community innovations (plugins, skills, hooks)

## When to Use
Explicitly invoked via `/llm-language:update` or when user asks about updates.

## Pipeline

### Step 1: Research (parallel WebSearch)
Dispatch 4 parallel searches:
1. `site:code.claude.com changelog OR "new feature" {current_year}`
2. `site:arxiv.org prompt engineering OR prompt optimization {current_year}`
3. `site:anthropic.com Claude Code OR CLAUDE.md best practices {current_year}`
4. `Claude Code plugin skill hook community innovation {current_year}`

### Step 2: Diff Analysis
Compare findings against current llm-language capabilities:
- Read current SKILL.md to know what's already implemented
- Read current scoring-rubric.md to know current dimensions
- Read current scientific-principles.md to know current papers
- Identify GAPS: what exists in the ecosystem that llm-language doesn't use yet?

### Step 3: Impact Assessment
For each finding, assess:
- **Relevance**: Does this apply to prompt optimization? (0-10)
- **Impact**: Would integrating this measurably improve output quality? (0-10)
- **Effort**: How hard to integrate? (low/medium/high)
- **Priority**: Relevance × Impact, filtered by effort

### Step 4: Report
Present findings as a structured report:
```
★ llm-language:update ──────────────────────────
Research date: {date}
Sources scanned: {N}
New findings: {N relevant}
Actionable updates: {N priority > 7}
──────────────────────────────────────────────────

## Claude Code Updates
[List of new features with relevance score]

## New Prompting Techniques
[List of new papers/methods with impact score]

## CLAUDE.md Best Practices
[Any changes to recommended structure]

## Community Innovations
[Notable plugins, skills, hooks]

## Recommended Actions
[Priority-ordered list of what to integrate]
```

### Step 5: Optional Auto-Apply
If the user approves, apply the highest-priority updates:
- Add new papers to scientific-principles.md
- Update SKILL.md with new features
- Update scoring-rubric.md if new dimensions needed
- Update ROSETTA.md with new effective patterns

### Step 6: ROSETTA Update
Log the research session in ROSETTA.md Evolution Log.

## Key Sources to Monitor
| Source | URL | What to look for |
|--------|-----|-----------------|
| Claude Code Changelog | code.claude.com/docs/en/changelog | New features, API changes |
| Anthropic Blog | anthropic.com/blog | Best practices, model updates |
| arXiv cs.CL | arxiv.org/list/cs.CL | Prompt optimization papers |
| arXiv cs.SE | arxiv.org/list/cs.SE | LLM-assisted development |
| Claude Code GitHub | github.com/anthropics/claude-code | Plugin system, hooks API |
| EMNLP/ACL/NeurIPS proceedings | Various | Peer-reviewed prompt research |

## Anti-Patterns
- Do NOT auto-apply changes without user approval
- Do NOT add papers that aren't peer-reviewed or from established authors
- Do NOT recommend features that conflict with the current SKILL.md architecture
- Do NOT bloat scientific-principles.md beyond its current structure (add, don't duplicate)
