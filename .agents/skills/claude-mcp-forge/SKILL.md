---
name: claude-mcp-forge
description: Guide for creating, configuring, testing, and troubleshooting Model Context Protocol (MCP) servers for Claude Code.
triggers: mcp server, create mcp, test mcp, configure mcp, mcp forge
---

# MCP Forge — Model Context Protocol Engineering Skill

## Overview
Use this skill when developing, testing, or integrating Model Context Protocol (MCP) servers for Claude Code.

## Standard MCP Server Formats

### 1. stdio Transport (Default)
In `~/.claude.json` or `.claude.json`:
```json
{
  "mcpServers": {
    "my-server": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://localhost:5432/mydb"],
      "env": {
        "PGUSER": "postgres"
      }
    }
  }
}
```

### 2. SSE Remote Transport
```json
{
  "mcpServers": {
    "linear-remote": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://mcp.linear.app/sse"],
      "env": {
        "LINEAR_API_KEY": "lin_api_..."
      }
    }
  }
}
```

## Testing Protocol
1. Verify executable exists in PATH (`node`, `npx`, `python`, `docker`).
2. Run dry-run execution with a 3-5 second timeout.
3. Check for auth errors or missing environment variables.
4. Verify tool definitions match the Model Context Protocol specification.
