# Claude Code Ultimate Setup — 1-Click Online Web Installer
# Usage: irm https://raw.githubusercontent.com/temkalt/claude-ultimate-hub/main/install.ps1 | iex

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host @"
================================================================
  CLAUDE CODE ULTIMATE SETUP — ONLINE INSTALLER
  Global Ecosystem Hub · Master All-in-One
================================================================
"@ -ForegroundColor Cyan

$tempDir = Join-Path $env:TEMP ("claude-setup-" + [Guid]::NewGuid().ToString().Substring(0,8))
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

$scriptUrl = "https://raw.githubusercontent.com/temkalt/claude-ultimate-hub/main/setup-claude-code-ultimate.ps1"
$scriptPath = Join-Path $tempDir "setup-claude-code-ultimate.ps1"

Write-Host "[>>] Downloading latest setup engine..." -ForegroundColor Yellow

# Download local setup script if available in workspace, otherwise fetch
if (Test-Path "$PSScriptRoot\setup-claude-code-ultimate.ps1") {
    Copy-Item "$PSScriptRoot\setup-claude-code-ultimate.ps1" $scriptPath -Force
} else {
    Invoke-RestMethod -Uri $scriptUrl -OutFile $scriptPath
}

Write-Host "[OK] Engine downloaded. Launching Master All-in-One installation..." -ForegroundColor Green
powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Profile Master

Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
