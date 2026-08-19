#!/usr/bin/env bash
# ==============================================================================
#  Claude Code Ultimate Hub — Universal POSIX / Linux / macOS Installer v3.0.0
# ==============================================================================

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "\n${CYAN}================================================================${NC}"
echo -e "${CYAN}  CLAUDE CODE ULTIMATE HUB — UNIVERSAL LAUNCHER v3.0.0${NC}"
echo -e "${CYAN}  1,000+ Tools, Calibrated Profiles & Web Control Center${NC}"
echo -e "${CYAN}================================================================${NC}\n"

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 1. Dependency Checks
if ! command_exists node; then
    echo -e "  ${RED}[XX] Node.js is required but not installed.${NC} Please install Node.js (https://nodejs.org/)"
    exit 1
fi

echo -e "  ${GREEN}[OK] Node.js:${NC} $(node -v)"
if command_exists git; then
    echo -e "  ${GREEN}[OK] Git:${NC} $(git --version)"
fi

# 2. Setup Claude directories
CLAUDE_HOME="$HOME/.claude"
mkdir -p "$CLAUDE_HOME/agents"
mkdir -p "$CLAUDE_HOME/skills"
mkdir -p "$CLAUDE_HOME/hooks"
mkdir -p "$CLAUDE_HOME/backups"
mkdir -p "$CLAUDE_HOME/commands"

# 3. Setup Hub Workspace
HUB_DIR="$HOME/.claude-ultimate-hub"
if [ ! -d "$HUB_DIR" ]; then
    echo -e "  [>>] Downloading Claude Code Ultimate Hub to $HUB_DIR..."
    git clone --depth 1 https://github.com/temkalt/claude-ultimate-hub.git "$HUB_DIR" >/dev/null 2>&1 || {
        mkdir -p "$HUB_DIR"
        curl -fsSL https://raw.githubusercontent.com/temkalt/claude-ultimate-hub/main/server.js -o "$HUB_DIR/server.js"
        curl -fsSL https://raw.githubusercontent.com/temkalt/claude-ultimate-hub/main/app.html -o "$HUB_DIR/app.html"
    }
fi

cd "$HUB_DIR"

echo -e "\n  ${GREEN}[OK] Starting Local Execution Bridge on http://localhost:3456/...${NC}"
echo -e "  ${CYAN}[>>] Opening Web Control Center in your default browser...${NC}\n"

# Open browser in background
(
    sleep 1
    if command_exists xdg-open; then
        xdg-open "http://localhost:3456" >/dev/null 2>&1 || true
    elif command_exists open; then
        open "http://localhost:3456" >/dev/null 2>&1 || true
    fi
) &

# Run local node server
exec node server.js
