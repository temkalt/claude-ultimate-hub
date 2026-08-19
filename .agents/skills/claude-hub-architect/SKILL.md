---
name: claude-hub-architect
description: Expert engineering guide for developing, extending, maintaining, and testing the Claude Code Ultimate Hub ecosystem, server backend, web control center, and profiles.
triggers: claude hub, hub architecture, extend hub, calibrate profile, hub server
---

# Claude Code Ultimate Hub — Architecture & Development Skill

## Overview
This skill provides complete architectural blueprints and workflows for maintaining and scaling the **Claude Code Ultimate Hub** ecosystem.

## Key System Components

### 1. Backend Server (`server.js`)
- Native Node.js architecture with zero external dependencies.
- Native modules: `http`, `fs`, `path`, `os`, `child_process`, `url`.
- REST API Endpoints:
  - `/api/status`: System environment, versions, paths, and component counts.
  - `/api/config`: Dual GET/POST for `settings.json`, `CLAUDE.md`, and `.claude.json`.
  - `/api/mcp`: Live MCP server registry, save, delete, and test connection (`/api/mcp/test`).
  - `/api/agents`: Subagent YAML frontmatter parser and generator.
  - `/api/skills`: Installed skills scanner and `SKILL.md` creator.
  - `/api/doctor`: 15-Point automated diagnostics engine.
  - `/api/snapshots`: Automatic and manual backup creation, listing, and 1-click restore.
  - `/api/action`: PowerShell and Bash execution bridge with real-time SSE streaming.
  - `/api/stream-logs`: Server-Sent Events (SSE) live execution log stream.

### 2. Web Control Center (`app.html`)
- Onyx Luxury Black theme with CSS variables.
- 12 comprehensive interactive views:
  1. Profiles Selector (14 calibrated stacks)
  2. Assembler (1,000+ items catalog with instant category tabs)
  3. MCP Manager (live list, connection test, custom add modal)
  4. Skills Store & Visual Creator
  5. Agency Studio Swarm (50+ personas)
  6. CLAUDE.md Builder & Token Linter
  7. 7-Layer Defense & Security Studio
  8. System Doctor (15-Factor live check)
  9. Snapshots & Time-Machine Rollback
  10. Token ROI Calculator
  11. Export & CLI Launcher
  12. Live Streaming Terminal Console

### 3. Orchestration Engine (`setup-claude-code-ultimate.ps1` & `install.sh`)
- Automated profile applicator with dependency validation, backup snapshots, 7-layer security policies, MCP registrations, subagent creation, and health check diagnostics.
- Cross-platform support: Native Windows PowerShell, WSL2, Linux, macOS.

## Rules for Adding New Components
1. **Zero Bloat Principle**: Keep idle context token consumption under 1.5k for standard profiles.
2. **Deterministic Security**: Always pair any tool or bash permission with strict PreToolUse blockers.
3. **Reversibility**: Every modification must trigger a snapshot in `~/.claude/backups/`.
