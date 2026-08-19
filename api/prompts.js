const PROMPT_MATRIX = [
  { id:'arch-review', cat:'Architecture', name:'Architectural Deep Review', cmd:'/arch-review', prompt:'Analyze the system architecture of this project. Identify bottlenecks, single points of failure, scaling boundaries, and propose modular ADR refactoring steps.' },
  { id:'tdd-generate', cat:'TDD & Testing', name:'TDD Test Suite Generator', cmd:'/tdd-gen', prompt:'Generate a comprehensive, isolated test suite using AAA structure (Arrange, Act, Assert). Cover happy paths, corner cases, error throws, and race conditions.' },
  { id:'sec-audit', cat:'Security', name:'OWASP Security Vulnerability Audit', cmd:'/sec-audit', prompt:'Perform an exhaustive OWASP Top 10 security audit. Check for secret exfiltration, SQL injection, XSS, unauthenticated endpoints, and insecure dependencies.' },
  { id:'refactor-clean', cat:'Refactoring', name:'Clean Architecture Refactoring', cmd:'/clean-refactor', prompt:'Refactor this module adhering to Clean Architecture and SOLID principles. Separate business logic from I/O frameworks, extract interfaces, and ensure testability.' },
  { id:'perf-opt', cat:'Performance', name:'High-Throughput Performance Tuning', cmd:'/perf-tune', prompt:'Analyze time and memory complexity. Eliminate unnecessary allocations, optimize database query plans, add batching/caching, and suggest vectorization.' },
  { id:'sql-schema', cat:'Databases', name:'PostgreSQL Schema & Index Optimizer', cmd:'/sql-opt', prompt:'Review PostgreSQL database schemas, constraints, foreign keys, and indexes. Recommend partial, composite, and GIN indexes for query optimization.' },
  { id:'docker-prod', cat:'DevOps', name:'Multi-Stage Production Dockerfile', cmd:'/docker-prod', prompt:'Generate an ultra-lightweight, hardened multi-stage Dockerfile running as non-root user with minimal Alpine/distroless base image.' },
  { id:'landing-copy', cat:'Marketing', name:'High-Conversion Landing Page Copy', cmd:'/copy-hero', prompt:'Craft compelling, viral headline, subheadline, 3-step value props, social proof triggers, and CTA microcopy using the PAS copywriting framework.' },
  { id:'ast-grep-pattern', cat:'AST Tools', name:'AST Grep Pattern Synthesizer', cmd:'/ast-pattern', prompt:'Construct high-speed ast-grep YAML rules to identify and replace deprecated API usages across the entire codebase.' },
  { id:'api-openapi', cat:'API Design', name:'Clean REST / OpenAPI 3.1 Spec', cmd:'/openapi-gen', prompt:'Design an OpenAPI 3.1 specification with strict request/response schemas, JWT auth bearer schemes, error envelopes, and rate limit headers.' }
];

module.exports = (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).end();
    return;
  }

  res.status(200).json({
    prompts: PROMPT_MATRIX,
    total: PROMPT_MATRIX.length,
    cloud: 'Vercel Edge'
  });
};
