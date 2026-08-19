const VERIFIED_MCP_SERVERS = {
  // Databases & Vector Stores
  "postgres": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://localhost:5432/postgres"], "category": "Databases", "desc": "PostgreSQL read-only schema inspector & query engine" },
  "supabase": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-supabase"], "category": "Databases", "desc": "Supabase cloud management, Auth, Postgres & Edge Functions" },
  "sqlite": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-sqlite"], "category": "Databases", "desc": "Local SQLite database inspector and query runner" },
  "redis": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-redis", "redis://localhost:6379"], "category": "Databases", "desc": "Redis key-value cache, pub/sub & stream monitor" },
  "clickhouse": { "command": "npx", "args": ["-y", "mcp-server-clickhouse"], "category": "Databases", "desc": "ClickHouse OLAP BigData aggregation engine" },
  "mongodb": { "command": "npx", "args": ["-y", "mcp-server-mongodb"], "category": "Databases", "desc": "MongoDB document database inspector & aggregation runner" },
  "qdrant": { "command": "npx", "args": ["-y", "qdrant-mcp-server"], "category": "Vector & RAG", "desc": "Qdrant vector search & RAG semantic embeddings" },
  "chroma": { "command": "npx", "args": ["-y", "chroma-mcp"], "category": "Vector & RAG", "desc": "ChromaDB local vector embeddings database" },
  "pinecone": { "command": "npx", "args": ["-y", "pinecone-mcp-server"], "category": "Vector & RAG", "desc": "Pinecone serverless hybrid semantic vector search" },
  "elasticsearch": { "command": "npx", "args": ["-y", "elasticsearch-mcp"], "category": "Databases", "desc": "Elasticsearch 8 BM25 & vector search queries" },
  "meilisearch": { "command": "npx", "args": ["-y", "meilisearch-mcp"], "category": "Databases", "desc": "Meilisearch ultra-fast typo-tolerant search" },
  "duckdb": { "command": "npx", "args": ["-y", "duckdb-mcp"], "category": "Databases", "desc": "DuckDB in-memory analytical SQL engine" },

  // Web, Browser & Search
  "playwright": { "command": "npx", "args": ["-y", "@anthropic/mcp-playwright"], "category": "Browser & Testing", "desc": "Headless Chromium browser for visual UI verification & screenshots" },
  "puppeteer": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-puppeteer"], "category": "Browser & Testing", "desc": "Puppeteer browser scraper & PDF generator" },
  "firecrawl": { "command": "npx", "args": ["-y", "firecrawl-mcp"], "category": "Web Scraping", "desc": "Turn any website into clean LLM-ready Markdown" },
  "fetch": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-fetch"], "category": "Web & HTTP", "desc": "Fast HTML-to-Markdown HTTP fetching tool" },
  "brave-search": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-brave-search"], "category": "Search", "desc": "Brave Search API for global real-time web search" },
  "tavily": { "command": "npx", "args": ["-y", "tavily-mcp"], "category": "Search", "desc": "Tavily AI search engine optimized for LLM agents" },
  "context7": { "command": "npx", "args": ["-y", "@upstash/context7-mcp@latest"], "category": "Documentation", "desc": "Live up-to-date documentation injector by Upstash" },

  // Developer Tools & Version Control
  "filesystem": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-filesystem", "."], "category": "System", "desc": "Secure scoped local file system access" },
  "github": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-github"], "category": "DevOps", "desc": "Official GitHub integration for PRs, Issues, and Actions" },
  "gitlab": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-gitlab"], "category": "DevOps", "desc": "GitLab repositories, Merge Requests, and CI/CD pipelines" },
  "docker": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-docker"], "category": "DevOps", "desc": "Official Docker container management and logs inspector" },
  "sentry": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-sentry"], "category": "Observability", "desc": "Sentry crash reports, stack traces, and APM metrics" },

  // Project Management & Notes
  "notion": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-notion"], "category": "Productivity", "desc": "Notion workspace pages, tasks, and engineering documentation" },
  "linear": { "command": "npx", "args": ["-y", "mcp-remote", "https://mcp.linear.app/sse"], "category": "Productivity", "desc": "Linear sprint tasks & Git branch synchronization" },
  "jira": { "command": "npx", "args": ["-y", "jira-mcp-server"], "category": "Productivity", "desc": "Atlassian Jira agile boards, tickets, and backlog management" },
  "clickup": { "command": "npx", "args": ["-y", "clickup-mcp"], "category": "Productivity", "desc": "ClickUp tasks, spaces, and workspace workflows" },

  // Communications & Notifications
  "telegram": { "command": "npx", "args": ["-y", "telegram-mcp-server"], "category": "Social & Bots", "desc": "Telegram bot management, channel alerts, and direct messaging 🇷🇺" },
  "slack": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-slack"], "category": "Communications", "desc": "Slack channels, thread replies, and notification alerts" },
  "discord": { "command": "npx", "args": ["-y", "discord-mcp-server"], "category": "Communications", "desc": "Discord server webhooks, bots, and community management" },

  // Fintech & Payments
  "stripe": { "command": "npx", "args": ["-y", "mcp-stripe"], "category": "Fintech", "desc": "Global payment gateway: Checkout sessions, subscriptions, refunds" },
  "yookassa": { "command": "npx", "args": ["-y", "@theyahia/yookassa-mcp"], "category": "Fintech", "desc": "YooKassa ruble payments, 54-FZ receipts, SBP, recurring bills 🇷🇺" },
  "lemonsqueezy": { "command": "npx", "args": ["-y", "lemonsqueezy-mcp"], "category": "Fintech", "desc": "Merchant of record for SaaS digital products & licenses" },

  // Cloud Providers & Infrastructure
  "yandex-cloud": { "command": "npx", "args": ["-y", "yandex-cloud-mcp"], "category": "Cloud", "desc": "Compute VMs, S3 Object Storage, Managed YDB in Russia 🇷🇺" },
  "aws": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-aws"], "category": "Cloud", "desc": "AWS Lambda, S3 buckets, DynamoDB, and CloudWatch logs" },
  "cloudflare": { "command": "npx", "args": ["-y", "cloudflare-mcp"], "category": "Cloud", "desc": "Cloudflare Workers edge functions, KV storage, and DNS records" },

  // Agent Reasoning & Memory
  "sequential-thinking": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"], "category": "Reasoning", "desc": "Dynamic multi-step reasoning and hypothesis refinement" },
  "memory": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-memory"], "category": "Memory", "desc": "Persistent knowledge graph memory across agent sessions" }
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
    servers: VERIFIED_MCP_SERVERS,
    total: Object.keys(VERIFIED_MCP_SERVERS).length,
    cloud: 'Vercel Serverless Registry v3.0'
  });
};
