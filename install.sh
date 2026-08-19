#!/usr/bin/env bash
# ==============================================================================
#  Claude Code Ultimate Hub — Universal POSIX / Linux / macOS Installer v2.5.0
# ==============================================================================

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "\n${CYAN}================================================================${NC}"
echo -e "${CYAN}  CLAUDE CODE ULTIMATE HUB — UNIVERSAL INSTALLER v2.5.0${NC}"
echo -e "${CYAN}  1,000+ Tools, Calibrated Profiles & Web Control Center${NC}"
echo -e "${CYAN}================================================================${NC}\n"

# 1. Dependency Checks
echo -e "  [>>] Checking dependencies..."

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

if ! command_exists node; then
    echo -e "  ${RED}[XX] Node.js is required but not installed.${NC} Please install Node.js v18.0+"
    exit 1
fi

if ! command_exists git; then
    echo -e "  ${RED}[XX] Git is required but not installed.${NC}"
    exit 1
fi

echo -e "  ${GREEN}[OK] Node.js:${NC} $(node -v)"
echo -e "  ${GREEN}[OK] Git:${NC} $(git --version)"

# 2. Setup Claude Home directories
CLAUDE_HOME="$HOME/.claude"
mkdir -p "$CLAUDE_HOME/agents"
mkdir -p "$CLAUDE_HOME/skills"
mkdir -p "$CLAUDE_HOME/hooks"
mkdir -p "$CLAUDE_HOME/backups"

echo -e "  ${GREEN}[OK] Claude home prepared:${NC} $CLAUDE_HOME"

# 3. Check for PowerShell Core or native Node fallback
if command_exists pwsh; then
    echo -e "  [>>] PowerShell Core (pwsh) detected. Running full setup engine..."
    pwsh -NoProfile -ExecutionPolicy Bypass -File "./setup-claude-code-ultimate.ps1" "$@"
else
    echo -e "  [>>] Launching Node.js local Web Control Center on http://localhost:3456..."
    node server.js &
    SERVER_PID=$!
    echo -e "  ${GREEN}[OK] Control Center running (PID: $SERVER_PID)${NC}"
    echo -e "  Open in browser: ${CYAN}http://localhost:3456/${NC}"
fi
