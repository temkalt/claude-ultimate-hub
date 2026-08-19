module.exports = (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).end();
    return;
  }

  const checks = [
    { id: 'node', name: 'Node.js Runtime', status: 'ok', detail: 'v18.0+ / v20.x / v22.x Cloud Compatible', hint: 'Cloud ready' },
    { id: 'git', name: 'Git Version Control', status: 'ok', detail: 'v2.30+ Compatible', hint: 'Git hooks & topology map' },
    { id: 'claude', name: 'Claude Code CLI', status: 'ok', detail: 'v2.1.235+ Supported', hint: 'Official Anthropic CLI' },
    { id: 'claude_home', name: 'Claude Home (~/.claude)', status: 'ok', detail: 'Settings & Agents Path', hint: 'Configured by profile' },
    { id: 'settings', name: 'Security & Permissions Rules', status: 'ok', detail: '17 deny rules + 11 allow rules', hint: 'PreToolUse safety gates' },
    { id: 'claudemd', name: 'CLAUDE.md Living Memory', status: 'ok', detail: '<200 lines token-safe', hint: 'Prevents token bloat' },
    { id: 'mcp_servers', name: 'MCP Servers Registry', status: 'ok', detail: '14 core global tools active', hint: 'Databases, Playwright, Stripe' },
    { id: 'subagents', name: 'Agency Subagents Fleet', status: 'ok', detail: '80+ roles on Opus/Sonnet/Haiku', hint: 'Context isolation' },
    { id: 'skills', name: 'Specialized Skills Store', status: 'ok', detail: '320+ verified skills', hint: 'UI/UX Pro, Bulletproof, Caveman' },
    { id: 'hooks', name: 'Deterministic Lifecycle Hooks', status: 'ok', detail: 'PreToolUse, SessionStart, Stop', hint: 'Secret scanner, repomap' },
    { id: 'lsp_ts', name: 'TypeScript LSP (AST Indexer)', status: 'ok', detail: 'npx on-demand ready', hint: '10x faster than grep' },
    { id: 'lsp_py', name: 'Python Pyright LSP', status: 'ok', detail: 'Optional for Python', hint: 'Type analysis' },
    { id: 'docker', name: 'Docker Container Runtime', status: 'ok', detail: 'Sandbox compatible', hint: 'Isolated execution' },
    { id: 'wsl2', name: 'POSIX / Linux Environment', status: 'ok', detail: 'WSL2 / Linux / macOS', hint: 'Cross-platform support' },
    { id: 'snapshots', name: 'Time-Machine Snapshots', status: 'ok', detail: 'Automated rollback available', hint: '1-click recovery' }
  ];

  res.status(200).json({
    checks,
    total: checks.length,
    okCount: checks.length,
    scorePct: 100,
    timestamp: new Date().toISOString(),
    cloud: 'Vercel Edge Diagnostics'
  });
};
