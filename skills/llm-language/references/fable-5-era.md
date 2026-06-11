# Fable 5 / Mythos-Class Era — Migration & Targeting Reference (v4.4)

Research date: 2026-06-11. All facts cross-verified ≥2 sources (official docs + independent).
Supersedes `opus-4-7-migration.md` as the primary targeting reference; that file remains valid
for Opus 4.7-specific parameter rules (which carry forward to 4.8 and Fable 5).

## Terminology (IMPORTANT — prevents hallucination)

- The correct tier name is **"Mythos-class"**, NOT "Claude 5 family". Official docs never use
  "Claude 5". Fable/Mythos is a NEW naming line ABOVE Opus, not a continuation of
  Opus/Sonnet/Haiku numbering.
- **Claude Fable 5** (`claude-fable-5`): Mythos-class model made safe for general availability
  via safety classifiers. GA since 2026-06-09 (Claude Code v2.1.170, 2026-06-10).
- **Claude Mythos 5** (`claude-mythos-5`): same underlying weights WITHOUT those classifiers;
  restricted to approved orgs (Project Glasswing cyber defenders, vetted bio researchers,
  US-gov collaboration). NOT self-serve. 30-day mandatory data retention; excluded from
  zero-data-retention agreements ("Covered Models").
- Announcement: https://www.anthropic.com/news/claude-fable-5-mythos-5

## Model lineup (2026-06-11)

| Model | ID | $/MTok in/out | Context | Max out | Effort default | Notes |
|---|---|---|---|---|---|---|
| Fable 5 | `claude-fable-5` | 10 / 50 | 1M | 128k | (set explicitly) | Mythos-class GA; adaptive thinking ALWAYS ON |
| Opus 4.8 | `claude-opus-4-8` | 5 / 25 | 1M | 128k | `high` | New workhorse default (2026-05-28); fast mode 2× price for 2.5× speed |
| Sonnet 4.6 | `claude-sonnet-4-6` | — | — | — | — | Mid tier unchanged |
| Haiku 4.5 | `claude-haiku-4-5-20251001` | — | — | — | — | /goal evaluator default |

**Negative results:** no Sonnet 5, Haiku 5, Opus 5; Fable 5 has NO fast mode, NO extended
thinking, NO thinking-disable, NO raw CoT (`thinking.display: summarized|omitted`), NOT a
Dreams pipeline model, NOT available under ZDR.

## Fable 5 API mechanics the Producer/Critic must know

1. **Adaptive thinking always on** — `thinking: {"type":"disabled"}` NOT supported. Depth is
   controlled ONLY via `effort` (low/medium/high/xhigh/max). Never emit manual CoT triggers
   or `budget_tokens`.
2. **`temperature`/`top_p`/`top_k`** → HTTP 400 on Opus 4.7+ (assume same on Fable 5 —
   officially stated for "Opus 4.7 and later"; confidence medium for Fable extension).
3. **Refusal surface (NEW)**: safety classifiers (cyber, bio/chem, anti-distillation) can
   decline → HTTP 200 with `stop_reason: "refusal"` + `stop_details.category`
   (`cyber`/`bio`/`reasoning_extraction`). Refused-before-output requests are unbilled.
4. **`fallbacks` parameter (beta)**: server-side retry on another model (billed at fallback
   model's rates) + fallback credit refunds prompt-cache switching cost. Claude Code analogue:
   `fallbackModel` setting, up to 3 fallbacks (v2.1.166).
5. **Classifier trigger rate**: <5% of sessions, reroutes to Opus 4.8. ~0.03% of traffic gets
   silent capability degradation on frontier-LLM-dev prompts — a reproducibility hazard for
   prompt-optimization experiments. **Generated prompts for benchmark/eval work SHOULD include
   a refusal-detection check** (assert `stop_reason != "refusal"`, log `stop_details.category`).
6. **Tokenizer**: same as Opus 4.7 (~30% more tokens vs pre-4.7). No new tokenizer with Fable 5.

## Complexity → model + effort map (v4.4 — replaces the Opus-4.7-only map)

| Complexity | Target model | Effort | Max tokens | Task budget |
|---|---|---|---|---|
| simple | Opus 4.8 (or Sonnet 4.6) | `medium` | 4k | omit |
| moderate | Opus 4.8 | `high` (its default) | 16k | omit |
| complex | Opus 4.8 | `xhigh` | 64k | 200k |
| critical | Opus 4.8 `max` → **escalate to Fable 5 `xhigh`** | see note | 128k | 400-800k |

**Escalation rule (NEW dimension — the ceiling moved):** "max on Opus" is no longer the top of
the capability ladder. For genuinely frontier problems (long-horizon agentic work, hours-scale
autonomy, hardest reasoning) prefer **Fable 5 at high/xhigh** over Opus 4.8 at max. Practitioner
consensus: Fable 5 is an agent-harness model, not a chat model — delegate responsibilities, not
tasks; orchestrate cheaper Claude variants as subagents; slow first token is expected.

**Cost guards are MANDATORY when targeting Fable 5:**
- 2× Opus 4.8 pricing; effort tiers span ~7.5× output-token cost on the same prompt
  (Willison: low=1,929 tok → max=14,430 tok, with inconsistent effort→token scaling).
- Real-world datapoint: $110/day in normal experimentation.
- ALWAYS pair Fable 5 execution with a stop rule (`/goal` bound clause, task_budget, or
  explicit completion condition) — "it keeps working until the harness cuts it off".
- Subscription inclusion ends 2026-06-22; from 06-23 Fable 5 draws prepaid usage credits
  ($2,000/day redemption cap).

## Ultracode semantics (orchestration toggle, NOT an effort tier)

`ultracode` = xhigh effort + automatic dynamic-workflow triggering (Workflow tool) for every
substantive task. It is a per-task keyword / session toggle in Claude Code, orthogonal to the
`effort` API parameter — the API has no "ultracode" value. Escalation model is 3-axis:
depth (`effort`), capability (Opus 4.8 → Fable 5), breadth (single-agent → workflow →
ultracode). Cost discipline: use per-task, never per-session (community: ~20% of weekly Max
tokens burned in one day). Quality patterns unlocked: adversarial verify panels,
loop-until-dry discovery, judge panels, completeness critics.

## Subagent dispatch (Agent tool)

The Agent tool `model` enum is now **`sonnet | opus | haiku | fable`**. Version-pinned values
like `opus-4-7` are NOT valid enum members — use alias names. In Claude Code, `/model fable`
selects Fable 5; `opus` resolves to Opus 4.8 (default since v2.1.154).

## Claude Code changes relevant to llm-language (v2.1.139 → v2.1.173)

- **v2.1.170 (Jun 9)**: Fable 5 support. v2.1.172: nested sub-agents up to 5 levels.
- **v2.1.166-169**: `fallbackModel` (≤3), `--thinking disabled` / `MAX_THINKING_TOKENS=0`,
  `/cd`, `--safe-mode` (`CLAUDE_CODE_SAFE_MODE`), `post-session` hook, `disableBundledSkills`,
  glob deny rules.
- **v2.1.154 (May 28)**: Opus 4.8 default (`effort: high` everywhere, `/effort xhigh`),
  **dynamic workflows** (Workflow tool — script-orchestrated fan-out of tens-hundreds of
  subagents; "plan-as-code" keeps orchestration state out of model context), **ultracode**
  toggle (xhigh + auto-workflows; community: use per-task, not per-session — ~20% weekly Max
  tokens burned in a day), lean system prompt default, fast mode repriced 2×/2.5×.
- **v2.1.152**: `/code-review --fix`, skill `disallowed-tools`, `/reload-skills`,
  SessionStart hooks can return `reloadSkills`/`sessionTitle`, **MessageDisplay hook event**
  (transform/hide assistant text at display time — candidate surface for Summary Banner).
- **v2.1.147**: `/simplify` → `/code-review` rename. v2.1.144: `/resume` for background
  sessions; `/model` is session-scoped (`d` for default).
- **/goal, Outcomes, Dreaming, Agent View: NO Fable-5-era changes.** Dreams supports
  Opus 4.8/4.7 + Sonnet 4.6 only (NOT Fable 5). Unofficial "AutoDream" in Claude Code
  (idle ~24h + ~5 sessions → auto-memory consolidation) — medium confidence, undocumented.
- **Advisor tool (beta)**: fast executor + high-intelligence advisor mid-generation; June 2
  added per-call `max_tokens` cap. Platform-native separate-evaluator — same family as
  /goal ⇄ Outcomes ⇄ Critic.

## Deprecation watch (P0, updated 2026-06-11)

| Date | Event | Migration |
|---|---|---|
| **2026-06-15 9AM PT** | `claude-sonnet-4-20250514` + `claude-opus-4-20250514` RETIRE | → `claude-sonnet-4-6` / → **`claude-opus-4-8`** (NOT 4.7) |
| **2026-06-15** | Agent SDK billing split: separate monthly credit pool (Pro $20 … Enterprise $200/seat). Covers `claude -p`, GH Actions, SDK-auth apps. **One-time manual claim required** — credits do not auto-apply | claim in account settings |
| 2026-06-22→23 | Fable 5 leaves plan limits → prepaid usage credits | enable Settings > Usage |
| 2026-06-30 | `claude-mythos-preview` retires | → `claude-mythos-5` |
| ~late June | Fast mode on Opus 4.6 removed (~30d after 4.8 launch) | → fast mode on 4.8 |
| 2026-08-05 | `claude-opus-4-1-20250805` retires (announced 06-05) | → `claude-opus-4-8` |

## New research (verified arXiv IDs)

- **MASPO** — arXiv:2605.06623, **ICML 2026** (poster): joint prompt optimization across whole
  multi-agent systems; downstream-successor success as fitness; +2.9 avg accuracy over SOTA.
- **Generalizable Self-Evolving Memory for Automatic Prompt Optimization** — arXiv:2603.21520:
  directly relevant to ROSETTA-layer design.
- **MemPO** — arXiv:2603.00680: self-memory policy optimization for long-horizon agents.
- **SDAR** — arXiv:2605.15155: on-policy self-distillation as gated auxiliary objective on RL.
- **Memory for Autonomous LLM Agents survey** — arXiv:2603.07670: 5-family taxonomy.
- MASPOB — arXiv:2603.02630: bandit prompt optimization for MAS with GNNs.
