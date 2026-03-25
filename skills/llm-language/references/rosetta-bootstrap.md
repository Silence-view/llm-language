# ROSETTA.md — Bootstrap Template

When `~/.claude/ROSETTA.md` does not exist, create it with the following content. Replace `{date}` with the current date.

---

```markdown
# ROSETTA — Adaptive Prompt Memory

> This file is maintained automatically by llm-language v2.0.
> It captures patterns that improve output quality for this specific user.
> Do not delete — the system reads it before every prompt optimization.

**Created:** {date}
**Last updated:** {date}
**Interactions:** 0

---

## User Profile

### Communication Style
- Language preference: (detected after first interactions)
- Verbosity preference: (terse / balanced / detailed — detected after first interactions)
- Technical level: (beginner / intermediate / advanced / expert — detected after first interactions)

### Domain Expertise
- Primary domains: (detected after first interactions)
- Current projects: (detected after first interactions)
- Tech stack: (detected after first interactions)

### Output Preferences
- Preferred format: (code-first / explanation-first / mixed — detected)
- Wants educational insights: (yes/no — detected)
- Prefers examples: (yes/no — detected)

---

## Effective Patterns

Techniques and approaches that consistently produce high-quality results for this user.

### High-Scoring Techniques
<!-- Format: | Technique | Context | Score | Date | -->
| Technique | Context | Score | Date |
|---|---|---|---|
| (populated after first interactions) | | | |

### Preferred Role Personas
<!-- Which expert personas produce the best results -->
| Persona | Domain | User Response | Date |
|---|---|---|---|
| (populated after first interactions) | | | |

### Successful Prompt Structures
<!-- Specific structural patterns that worked well -->
- (populated after first interactions)

---

## Anti-Patterns

Approaches that failed, were corrected by the user, or scored poorly.

### Failed Approaches
<!-- Format: | What was tried | What went wrong | Correction | Date | -->
| What was tried | What went wrong | Correction | Date |
|---|---|---|---|
| (populated after first interactions) | | | |

### User Corrections
<!-- Direct corrections from the user that reveal preferences -->
- (populated after first interactions)

---

## Skill & Agent Usage

### Most Used Skills
<!-- Track which /skill-name commands the user invokes most often -->
| Skill | Times Used | Last Used | Notes |
|---|---|---|---|
| (populated automatically) | | | |

### Preferred Agents
<!-- Track which agents produce results the user is most satisfied with -->
| Agent | Times Dispatched | Avg Satisfaction | Notes |
|---|---|---|---|
| (populated automatically) | | | |

### Tool Preferences
<!-- Which tools the user prefers or asks for explicitly -->
| Tool | Frequency | Context | Notes |
|---|---|---|---|
| (populated automatically) | | | |

---

## Domain Context

### Active Projects
<!-- Current projects and their key details -->
| Project | Tech Stack | Key Constraints | Status |
|---|---|---|---|
| (populated after first interactions) | | | |

### Recurring Themes
<!-- Topics that come up repeatedly -->
- (populated after first interactions)

---

## Evolution Log

<!-- Brief log of significant ROSETTA updates -->
| Date | Change | Trigger |
|---|---|---|
| {date} | ROSETTA initialized | First llm-language invocation |
```
