---
name: claude-subagent-designer
description: Guide for creating specialized, isolated subagent personas with model routing (Opus/Sonnet/Haiku), tool whitelists, and compressed output formats.
triggers: create subagent, subagent design, agency role, persona creation
---

# Subagent Designer — Claude Code Persona Engineering Skill

## Overview
Subagents allow Claude Code to delegate domain-specific tasks to dedicated assistants running in isolated context windows.

## File Format & Scope
Subagents are stored as Markdown files with YAML frontmatter:
- **Global scope**: `~/.claude/agents/*.md`
- **Project scope**: `.claude/agents/*.md` or `.agents/agents/*.md`

## Structure Template
```markdown
---
name: architect
model: claude-opus-5
description: Lead system architect for high-level system design and trade-offs.
tools: Read, Bash, Glob
---

# Architect Subagent Instructions

You are a principal system architect.

## Responsibilities
- Design scalable, modular architectures.
- Evaluate trade-offs between competing technologies.
- Author Architecture Decision Records (ADRs).

## Output Guidelines
- Executive summary first.
- Clear trade-off comparison matrix.
- Concrete code interface definitions.
```

## Model Routing Strategy
- **`claude-opus-5`**: System Architecture, OWASP Security Audits, Chaos Testing, Complex Multi-File Refactoring.
- **`claude-sonnet-5`**: General Feature Engineering, Code Review, Test Automation, Bug Fixing.
- **`claude-haiku-4-5`**: Rapid Documentation, Changelog Generation, JSDoc Specs, Simple File Linting.
