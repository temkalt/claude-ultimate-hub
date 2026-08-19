const DEFAULT_MCP_SERVERS = {
  "stripe": { "command": "npx", "args": ["-y", "mcp-stripe"] },
  "supabase": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-supabase"] },
  "postgres": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://localhost:5432/postgres"] },
  "sqlite": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-sqlite"] },
  "redis": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-redis", "redis://localhost:6379"] },
  "docker": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-docker"] },
  "playwright": { "command": "npx", "args": ["-y", "@anthropic/mcp-playwright"] },
  "notion": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-notion"] },
  "linear": { "command": "npx", "args": ["-y", "mcp-remote", "https://mcp.linear.app/sse"] },
  "sentry": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-sentry"] },
  "context7": { "command": "npx", "args": ["-y", "@upstash/context7-mcp@latest"] },
  "telegram": { "command": "npx", "args": ["-y", "telegram-mcp-server"] },
  "yookassa": { "command": "npx", "args": ["-y", "@theyahia/yookassa-mcp"] },
  "yandex-cloud": { "command": "npx", "args": ["-y", "yandex-cloud-mcp"] }
};

module.exports = (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).end();
    return;
  }

  res.status(200).json({
    servers: DEFAULT_MCP_SERVERS,
    total: Object.keys(DEFAULT_MCP_SERVERS).length,
    cloud: 'Vercel Serverless Registry'
  });
};
