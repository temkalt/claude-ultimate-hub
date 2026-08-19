// ==============================================================================
//  Claude Code Ultimate Hub — Local Direct Execution Bridge & Web Server v2.0.0
//  Zero external dependencies (uses native Node.js: http, child_process, fs, path, os)
// ==============================================================================

const http = require('http');
const fs = require('fs');
const path = require('path');
const os = require('os');
const { spawn, exec } = require('child_process');

const PORT = process.env.PORT || 3456;
const ROOT_DIR = __dirname;
const USER_HOME = os.homedir();
const CLAUDE_DIR = path.join(USER_HOME, '.claude');
const CLAUDE_SETTINGS = path.join(CLAUDE_DIR, 'settings.json');
const CLAUDE_MD = path.join(CLAUDE_DIR, 'CLAUDE.md');
const CLAUDE_JSON = path.join(USER_HOME, '.claude.json');
const BACKUPS_DIR = path.join(CLAUDE_DIR, 'backups');

let activeProcess = null;
const clients = new Set();

// Send Server-Sent Events (SSE) to connected browser clients
function sendSSE(event, data) {
  const msg = `event: ${event}\ndata: ${JSON.stringify(data)}\n\n`;
  for (const client of clients) {
    try {
      client.write(msg);
    } catch (e) {
      clients.delete(client);
    }
  }
}

// Execute PowerShell script with live streaming output
function runPowerShellScript(args = [], actionName = 'Task') {
  if (activeProcess) {
    sendSSE('log', { type: 'warn', text: `[!] A process is already running. Please wait or stop it first.\n` });
    return false;
  }

  const scriptPath = path.join(ROOT_DIR, 'setup-claude-code-ultimate.ps1');
  const psArgs = ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', scriptPath, ...args];

  sendSSE('start', { action: actionName, time: new Date().toLocaleTimeString() });
  sendSSE('log', { type: 'info', text: `\n[>>] Starting Task: ${actionName}\n[>>] Command: powershell ${psArgs.join(' ')}\n\n` });

  try {
    activeProcess = spawn('powershell.exe', psArgs, { cwd: ROOT_DIR });

    activeProcess.stdout.on('data', (data) => {
      const text = data.toString('utf8');
      sendSSE('log', { type: 'stdout', text });
    });

    activeProcess.stderr.on('data', (data) => {
      const text = data.toString('utf8');
      sendSSE('log', { type: 'stderr', text });
    });

    activeProcess.on('close', (code) => {
      const statusText = code === 0 ? 'SUCCESS' : 'FAILED';
      sendSSE('log', { 
        type: code === 0 ? 'success' : 'fail', 
        text: `\n[${statusText}] Process finished with exit code ${code}\n` 
      });
      sendSSE('finish', { code, action: actionName });
      activeProcess = null;
    });

    activeProcess.on('error', (err) => {
      sendSSE('log', { type: 'fail', text: `\n[-] Process execution error: ${err.message}\n` });
      sendSSE('finish', { code: 1, action: actionName });
      activeProcess = null;
    });

    return true;
  } catch (err) {
    sendSSE('log', { type: 'fail', text: `[-] Execution failed: ${err.message}\n` });
    activeProcess = null;
    return false;
  }
}

// Helpers for reading/writing configuration files
function getLocalConfig() {
  let settings = {};
  let claudemd = '';
  let claudejson = {};

  try {
    if (fs.existsSync(CLAUDE_SETTINGS)) {
      settings = JSON.parse(fs.readFileSync(CLAUDE_SETTINGS, 'utf8') || '{}');
    }
  } catch (e) {
    settings = { error: e.message };
  }

  try {
    if (fs.existsSync(CLAUDE_MD)) {
      claudemd = fs.readFileSync(CLAUDE_MD, 'utf8');
    }
  } catch (e) {
    claudemd = '';
  }

  try {
    if (fs.existsSync(CLAUDE_JSON)) {
      claudejson = JSON.parse(fs.readFileSync(CLAUDE_JSON, 'utf8') || '{}');
    }
  } catch (e) {
    claudejson = {};
  }

  return { settings, claudemd, claudejson };
}

function getSnapshotsList() {
  if (!fs.existsSync(BACKUPS_DIR)) return [];
  try {
    const entries = fs.readdirSync(BACKUPS_DIR, { withFileTypes: true });
    return entries
      .filter(e => e.isDirectory())
      .map(d => {
        const full = path.join(BACKUPS_DIR, d.name);
        const files = fs.readdirSync(full);
        const stat = fs.statSync(full);
        return {
          id: d.name,
          date: stat.mtime.toISOString(),
          files: files
        };
      })
      .sort((a, b) => new Date(b.date) - new Date(a.date));
  } catch (e) {
    return [];
  }
}

const server = http.createServer((req, res) => {
  const parsedUrl = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  const pathname = parsedUrl.pathname;

  // CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  // 1. SSE Stream
  if (pathname === '/api/stream-logs') {
    res.writeHead(200, {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive'
    });
    res.write(`event: connected\ndata: ${JSON.stringify({ status: 'connected', version: '2.0.0' })}\n\n`);
    clients.add(res);

    req.on('close', () => {
      clients.delete(res);
    });
    return;
  }

  // 2. Status API
  if (pathname === '/api/status' && req.method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      status: 'ready',
      activeProcess: activeProcess !== null,
      serverTime: new Date().toISOString(),
      platform: process.platform,
      arch: process.arch,
      nodeVersion: process.version,
      claudeHome: CLAUDE_DIR,
      settingsFound: fs.existsSync(CLAUDE_SETTINGS),
      claudeMdFound: fs.existsSync(CLAUDE_MD)
    }));
    return;
  }

  // 3. Config API (Read)
  if (pathname === '/api/config' && req.method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(getLocalConfig()));
    return;
  }

  // 4. Config API (Write)
  if (pathname === '/api/config' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        const json = JSON.parse(body || '{}');
        if (!fs.existsSync(CLAUDE_DIR)) {
          fs.mkdirSync(CLAUDE_DIR, { recursive: true });
        }

        if (json.settings) {
          fs.writeFileSync(CLAUDE_SETTINGS, JSON.stringify(json.settings, null, 2), 'utf8');
        }
        if (typeof json.claudemd === 'string') {
          fs.writeFileSync(CLAUDE_MD, json.claudemd, 'utf8');
        }

        sendSSE('log', { type: 'success', text: `[OK] Configuration files updated successfully.\n` });
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: true, message: 'Configuration saved' }));
      } catch (err) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: false, error: err.message }));
      }
    });
    return;
  }

  // 5. Snapshots API
  if (pathname === '/api/snapshots' && req.method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ snapshots: getSnapshotsList() }));
    return;
  }

  // 6. Actions Execution API
  if (pathname === '/api/action' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        const json = JSON.parse(body || '{}');
        const action = json.action;
        const profile = json.profile || 'Master';
        const components = json.components || '';

        let started = false;

        switch (action) {
          case 'apply-profile':
            started = runPowerShellScript(['-Profile', profile], `Apply Profile (${profile})`);
            break;

          case 'apply-components':
            if (components) {
              started = runPowerShellScript(['-Profile', profile, '-Components', components], `Apply Custom Components (${profile})`);
            } else {
              started = runPowerShellScript(['-Profile', profile], `Apply Profile (${profile})`);
            }
            break;

          case 'health-check':
            started = runPowerShellScript(['-HealthCheck'], '15-Point System Health-Check');
            break;

          case 'repair':
            started = runPowerShellScript(['-Repair'], 'Repair and Reset Safety Hooks');
            break;

          case 'rollback':
            started = runPowerShellScript(['-Rollback'], 'Rollback to Previous Snapshot');
            break;

          case 'launch-claude':
            exec('start cmd /k claude', { cwd: ROOT_DIR });
            sendSSE('log', { type: 'info', text: '\n[>>] Launched Claude Code in external terminal window.\n' });
            started = true;
            break;

          case 'stop-process':
            if (activeProcess) {
              activeProcess.kill('SIGINT');
              sendSSE('log', { type: 'warn', text: '\n[!] Process termination requested by user.\n' });
              activeProcess = null;
              started = true;
            }
            break;

          default:
            res.writeHead(400, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ error: `Unknown action: ${action}` }));
            return;
        }

        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: started, action }));
      } catch (err) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: err.message }));
      }
    });
    return;
  }

  // 7. Static File Serving
  let filePath = path.join(ROOT_DIR, pathname === '/' ? 'app.html' : pathname);

  if (!fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) {
    filePath = path.join(ROOT_DIR, 'app.html');
  }

  const extname = String(path.extname(filePath)).toLowerCase();
  const mimeTypes = {
    '.html': 'text/html; charset=utf-8',
    '.js': 'text/javascript; charset=utf-8',
    '.css': 'text/css; charset=utf-8',
    '.json': 'application/json; charset=utf-8',
    '.png': 'image/png',
    '.jpg': 'image/jpg',
    '.svg': 'image/svg+xml',
    '.ico': 'image/x-icon',
    '.ps1': 'text/plain; charset=utf-8',
    '.md': 'text/markdown; charset=utf-8'
  };

  const contentType = mimeTypes[extname] || 'application/octet-stream';

  fs.readFile(filePath, (error, content) => {
    if (error) {
      if (error.code === 'ENOENT') {
        res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
        res.end('404 Not Found');
      } else {
        res.writeHead(500);
        res.end(`Server Error: ${error.code}`);
      }
    } else {
      res.writeHead(200, { 'Content-Type': contentType });
      res.end(content, 'utf-8');
    }
  });
});

server.listen(PORT, () => {
  console.log(`\n================================================================`);
  console.log(`  CLAUDE CODE ULTIMATE HUB — WEB CONTROL CENTER v2.0.0`);
  console.log(`  Direct Web UI: http://localhost:${PORT}/`);
  console.log(`  Public Hub:    http://localhost:${PORT}/index.html`);
  console.log(`================================================================\n`);
});
