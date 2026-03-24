# llm-language

**A scientifically-grounded prompt meta-compiler for Claude Code**

> Automatic prompt re-engineering through multi-agent debate, grounded in 100+ prompt engineering papers, specialized for Claude Opus 4.6 with ultrathink.

---

## Overview

`llm-language` is a [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugin that intercepts every user message and re-engineers it through a multi-agent Generate-Critique-Revise pipeline before execution. The system produces an optimized XML-structured prompt that is ephemeral (never saved to disk) and executed with maximum reasoning depth.

The pipeline implements a **Diverse Multi-Agent Debate** (DMAD) architecture where a Producer agent generates an optimized prompt and an independent Critic agent evaluates it against a 6-dimension scoring rubric. If the score falls below 8.5/10, the prompt is revised and re-evaluated, up to 2 rounds.

### Key Features

- **Automatic interception** of every user message (skippable with "skip llm-language")
- **Multi-agent debate**: Producer (generator) + Critic (evaluator) with heterogeneous roles
- **Scientific grounding**: 15+ techniques from 100+ papers mapped to task types
- **XML-structured output**: leverages Claude's native XML parsing capabilities
- **Complexity-adaptive**: scales pipeline depth (simple=1 agent, critical=4 agents)
- **Ephemeral prompts**: generated XML lives only in conversation context
- **Opus 4.6 optimized**: ultrathink activation, extended context exploitation

## Architecture

```
User Message
    |
    v
[Phase 1: INTAKE]          Classify complexity, discover skills,
    |                       select scientific principles
    v
[Phase 2: GENERATE]        Producer Agent (Opus) generates XML prompt
    |                       using selected techniques + template
    v
[Phase 3: CRITIQUE]        Critic Agent (Opus) scores on 6 dimensions
    |                       using anchored rubric (1-10 scale)
    v
[Phase 4: REVISE]          If score < 8.5: revise + re-critique
    |                       Max 2 rounds, delta convergence < 0.3
    v
[Phase 5: EXECUTE]         Summary banner + execute with ultrathink
```

### Scoring Rubric

| Dimension | Weight | What it measures |
|---|---|---|
| Intent Preservation | 0.25 | User's original goal unchanged |
| Precision | 0.20 | Every instruction specific, unambiguous |
| Completeness | 0.20 | Sub-tasks + edge cases covered |
| Structure | 0.15 | XML well-formed, clear hierarchy |
| Opus 4.6 Optimization | 0.10 | Model-specific capabilities leveraged |
| Scientific Grounding | 0.10 | Appropriate techniques applied |

### Token Cost

| Complexity | Subagents | Estimated Overhead |
|---|---|---|
| simple | 1 | ~8K-15K tokens |
| moderate | 2-3 | ~30K-50K tokens |
| complex | 3-4 | ~50K-80K tokens |
| critical | 4 | ~80K-120K tokens |

## Installation

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
- Claude Opus 4.6 model access

### Method 1: Install via Marketplace (recommended)

This registers the GitHub repository as a Claude Code marketplace, making it installable with a single command.

```bash
# Step 1: Add the GitHub repository as a marketplace source
claude plugins marketplace add https://github.com/Silence-view/llm-language

# Step 2: Install the plugin globally (user scope = works in any directory)
claude plugins install llm-language@llm-language --scope user

# Step 3: Verify installation
claude plugins list
# Expected output:
#   llm-language@llm-language
#   Version: 1.0.0
#   Scope: user
#   Status: enabled
```

To update to a newer version later:
```bash
claude plugins install llm-language@llm-language --scope user
```

To uninstall:
```bash
claude plugins uninstall llm-language@llm-language
claude plugins marketplace remove llm-language
```

### Method 2: Install from Local Clone

If you want to modify the skill or develop locally:

```bash
# Step 1: Clone the repository
git clone https://github.com/Silence-view/llm-language.git ~/.claude/plugins/local/llm-language

# Step 2: Register the local folder as a marketplace
claude plugins marketplace add ~/.claude/plugins/local/llm-language

# Step 3: Install at user scope
claude plugins install llm-language@llm-language --scope user

# Step 4: Verify
claude plugins list
```

With a local clone, any changes you make to the skill files take effect immediately.

### Method 3: Install as Standalone Skill (minimal)

If you don't need the full plugin infrastructure:

```bash
# Copy just the skill directory
git clone https://github.com/Silence-view/llm-language.git /tmp/sl-temp
cp -r /tmp/sl-temp/skills/llm-language ~/.claude/skills/llm-language
rm -rf /tmp/sl-temp
```

> **Note:** Standalone skills only work when Claude Code loads the `~/.claude/skills/` directory. The plugin method (Methods 1-2) is more reliable and works globally.

## Usage

### Automatic Mode (default)

Once installed, the skill triggers automatically on every user message. You'll see a summary banner before each response:

```
★ llm-language ──────────────────────────────
Applied: CoT + Self-Refine | Role: Senior Backend Engineer
Complexity: moderate | Sub-tasks: 3 | Thinking: ultrathink
Score: 8.7/10 | Rounds: 1
Skills matched: paper, humanizer
──────────────────────────────────────────────────
```

### Manual Invocation

```
/llm-language
```

### Skip for a Message

Include "skip llm-language" or "raw mode" in your message to bypass the pipeline.

## File Structure

```
llm-language/
├── .claude-plugin/
│   ├── plugin.json              # Plugin identity
│   └── marketplace.json         # Registration metadata
├── skills/
│   └── llm-language/
│       ├── SKILL.md             # Main skill (pipeline orchestrator)
│       └── references/
│           ├── scientific-principles.md   # 15+ techniques, 100+ papers
│           ├── xml-prompt-template.md     # XML template with field docs
│           └── scoring-rubric.md          # 6-dimension quality rubric
├── docs/
│   └── BIBLIOGRAPHY.md          # Full academic bibliography
├── README.md
└── LICENSE
```

## Scientific Foundation

The system synthesizes findings from the following research areas. For the full bibliography with 100+ papers, see [`docs/BIBLIOGRAPHY.md`](docs/BIBLIOGRAPHY.md).

### Core Techniques Implemented

#### A. Reasoning Enhancement

| Technique | Citation | Application in llm-language |
|---|---|---|
| Chain-of-Thought (CoT) | Wei et al., NeurIPS 2022 | Step-by-step decomposition in `<methodology>` |
| Zero-Shot CoT | Kojima et al., NeurIPS 2022 | "Think step by step" triggers for simple tasks |
| Tree-of-Thought (ToT) | Yao et al., NeurIPS 2023 | Multiple reasoning paths for ambiguous problems |
| Self-Consistency | Wang et al., ICLR 2023 | Multiple paths, majority vote for high-stakes tasks |
| Least-to-Most | Zhou et al., ICLR 2023 | Simple-to-complex sub-task ordering |

#### B. Self-Improvement & Reflection

| Technique | Citation | Application in llm-language |
|---|---|---|
| Self-Refine | Madaan et al., NeurIPS 2023 | Core Generate-Critique-Revise cycle |
| Reflexion | Shinn et al., NeurIPS 2023 | Learning from prior critique feedback |
| Constitutional AI | Bai et al., arXiv 2022 | Scoring rubric as "constitution" |

#### C. Structural Optimization

| Technique | Citation | Application in llm-language |
|---|---|---|
| XML Structured Prompting | Xu et al., arXiv 2025; Anthropic 2025 | Entire output is XML-structured |
| Instruction Hierarchy | Wallace et al., 2024 | MUST/SHOULD/MAY priority ordering |
| Few-Shot Exemplars | Brown et al., NeurIPS 2020 | Thinking traces in examples |

#### D. Meta-Techniques

| Technique | Citation | Application in llm-language |
|---|---|---|
| Meta-Prompting | Fernando et al., 2023; Suzgun & Kalai, 2024 | The skill IS meta-prompting |
| Automatic Prompt Engineering | Zhou et al., ICLR 2023 | Automated prompt optimization |
| Decomposed Prompting | Khot et al., ICLR 2023 | Modular sub-task delegation |

#### E. Multi-Agent Techniques

| Technique | Citation | Application in llm-language |
|---|---|---|
| Multi-Agent Debate (MAD) | Du et al., ICML 2024 | Producer-Critic debate cycle |
| Diverse MAD (DMAD) | Liang et al., 2024 | Heterogeneous agent roles |

#### F. Model-Specific (Claude Opus 4.6)

| Technique | Citation | Application in llm-language |
|---|---|---|
| Extended Thinking | Anthropic, 2025-2026 | Ultrathink with ~32K thinking tokens |
| Claude XML Best Practices | Anthropic, 2025 | Consistent tags, primacy/recency |
| Context Window Optimization | Anthropic, 2025 | 1M context exploitation |

### Key Findings Informing Design

1. **General instructions outperform prescriptive steps** in extended thinking mode (Anthropic, 2026). The Producer generates high-level methodology rather than step-by-step plans.

2. **DMAD consistently outperforms standard MAD** (Liang et al., 2024). We use heterogeneous roles (Producer vs Critic) rather than identical debaters.

3. **Role prompting improves style/format but not factual accuracy** (Meincke et al., 2025; multiple studies). The `<role>` field is used for output alignment, not knowledge claims.

4. **XML reduces hallucination** in structured outputs (Xu et al., 2025; Anthropic, 2025). The entire prompt is XML-structured.

5. **Score inflation is a known failure mode** in multi-agent evaluation (Smit et al., 2024). The rubric uses anti-inflation rules: start at 7, require evidence for every score.

## Decision Matrix

Used in Phase 1.4 to select appropriate scientific techniques:

| Task Type | Primary Technique | Secondary | Thinking Level |
|---|---|---|---|
| Simple factual | Direct instruction | -- | quick/default |
| Multi-step reasoning | CoT | Self-Consistency | extended |
| Ambiguous/creative | ToT | DMAD | ultrathink |
| Code generation | Decomposition | Self-Refine | extended |
| Architecture/design | ToT + Decomposition | Reflexion | ultrathink |
| Analysis/research | CoT + Retrieval-Aug | Calibration | ultrathink |
| Writing/editing | Role + Self-Refine | Few-shot | extended |
| Debugging | Reflexion + CoT | Adversarial | extended |
| Complex multi-part | Least-to-Most + DecomP | Meta-Prompting | ultrathink |

## Contributing

Contributions are welcome. Areas of interest:

- **New scoring dimensions** for the rubric
- **Technique-specific optimizations** for different Claude models
- **Benchmark results** comparing llm-language outputs vs raw prompts
- **Domain-specific XML templates** (e.g., for code review, academic writing)

## License

MIT License. See [LICENSE](LICENSE).

## Citation

If you use this work in academic research, please cite:

```bibtex
@software{llm_language_2026,
  title     = {llm-language: A Scientifically-Grounded Prompt Meta-Compiler for Claude Code},
  author    = {Andre},
  year      = {2026},
  url       = {https://github.com/Silence-view/llm-language},
  note      = {Multi-agent prompt optimization plugin implementing DMAD, Self-Refine,
               and XML-structured prompting for Claude Opus 4.6},
  license   = {MIT}
}
```

## Acknowledgments

This work builds on the foundational research of Wei et al. (Chain-of-Thought), Yao et al. (Tree-of-Thought), Madaan et al. (Self-Refine), Du et al. (Multi-Agent Debate), and Anthropic's Claude prompting guidelines. Full bibliography in [`docs/BIBLIOGRAPHY.md`](docs/BIBLIOGRAPHY.md).
