@echo off
title Claude Code Ultimate Hub — Web Control Center
cd /d "%~dp0"
echo ================================================================
echo   CLAUDE CODE ULTIMATE HUB v2.0.0
echo   Launching Local Execution Bridge on http://localhost:3456/
echo ================================================================
echo.
timeout /t 1 /nobreak >nul
start "" "http://localhost:3456"
node server.js
pause
