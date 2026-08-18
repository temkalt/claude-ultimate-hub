# ==============================================================================
#  Claude Code Ultimate Hub — 1-Click Interactive TUI Installer (Onyx Edition)
#  Repository: https://github.com/temkalt/claude-ultimate-hub
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

function Show-Header {
    Clear-Host
    Write-Host @"
  ██████╗██╗      █████╗ ██╗   ██╗██████╗ ███████╗    ██╗  ██╗██╗   ██╗██████╗ 
 ██╔════╝██║     ██╔══██╗██║   ██║██╔══██╗██╔════╝    ██║  ██║██║   ██║██╔══██╗
 ██║     ██║     ███████║██║   ██║██║  ██║█████╗      ███████║██║   ██║██████╔╝
 ██║     ██║     ██╔══██║██║   ██║██║  ██║██╔══╝       ██╔══██║██║   ██║██╔══██╗
 ╚██████╗███████╗██║  ██║╚██████╔╝██████╔╝███████╗     ██║  ██║╚██████╔╝██████╔╝
  ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝     ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
                 CLAUDE CODE ULTIMATE HUB — ONYX EDITION (1,000+ TOOLS)
"@ -ForegroundColor White

    Write-Host "  ─────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "  Repository: https://github.com/temkalt/claude-ultimate-hub" -ForegroundColor DarkGray
    Write-Host "  ─────────────────────────────────────────────────────────────────────────────`n" -ForegroundColor DarkGray
}

$tempDir = Join-Path $env:TEMP ("claude-hub-" + [Guid]::NewGuid().ToString().Substring(0,8))
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
$scriptPath = Join-Path $tempDir "setup-claude-code-ultimate.ps1"
$scriptUrl = "https://raw.githubusercontent.com/temkalt/claude-ultimate-hub/main/setup-claude-code-ultimate.ps1"

# Download or locate script
if (Test-Path "$PSScriptRoot\setup-claude-code-ultimate.ps1") {
    Copy-Item "$PSScriptRoot\setup-claude-code-ultimate.ps1" $scriptPath -Force
} else {
    try {
        Invoke-RestMethod -Uri $scriptUrl -OutFile $scriptPath
    } catch {
        Write-Host "[-] Error loading setup engine: $_" -ForegroundColor Red
        exit 1
    }
}

Show-Header

Write-Host "  Select installation profile or action:`n" -ForegroundColor Yellow

Write-Host "  [1] 🌟 Master All-in-One (Calibrated Global Flagship: 34 Core Tools)" -ForegroundColor Green
Write-Host "  [2] 🌐 Full-Stack Web (Next.js 15, Playwright, UI/UX Pro, TS LSP, Supabase)" -ForegroundColor White
Write-Host "  [3] ⚙️ Backend & APIs (PostgreSQL, SQLite, Redis, Python Pyright, AST-Grep)" -ForegroundColor White
Write-Host "  [4] 🎯 Core (Minimal zero-bloat foundation)" -ForegroundColor White
Write-Host "  [5] 🔒 Security Auditor (OWASP, Bulletproof, Opus Reviewer)" -ForegroundColor White
Write-Host "  [6] 🇷🇺 Russia / CIS Stack (Telegram, YooKassa, Yandex Cloud, Caveman)" -ForegroundColor Cyan
Write-Host "  [7] 💎 Full Ultimate (All 1,000+ Tools)" -ForegroundColor Magenta
Write-Host "  ─────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host "  [8] 🩺 Run System Health-Check Diagnostics" -ForegroundColor Yellow
Write-Host "  [9] 🔧 Repair & Reset Safety Hooks" -ForegroundColor Yellow
Write-Host "  [R] ⏪ Rollback to Previous Snapshot" -ForegroundColor Red
Write-Host "  [0] 🌐 Open Interactive Web Hub in Browser" -ForegroundColor Cyan
Write-Host "  [Q] Exit`n" -ForegroundColor DarkGray

$choice = Read-Host "  Enter option [1-9, R, 0, Q] (default: 1)"
if (-not $choice) { $choice = '1' }

switch ($choice.Trim().ToUpper()) {
    '1' {
        Write-Host "`n[>>] Installing Master All-in-One Profile..." -ForegroundColor Green
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Profile Master
    }
    '2' {
        Write-Host "`n[>>] Installing Full-Stack Web Profile..." -ForegroundColor White
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Profile Web
    }
    '3' {
        Write-Host "`n[>>] Installing Backend & APIs Profile..." -ForegroundColor White
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Profile Backend
    }
    '4' {
        Write-Host "`n[>>] Installing Core Profile..." -ForegroundColor White
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Profile Core
    }
    '5' {
        Write-Host "`n[>>] Installing Security Auditor Profile..." -ForegroundColor White
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Profile Security
    }
    '6' {
        Write-Host "`n[>>] Installing Russia / CIS Profile..." -ForegroundColor Cyan
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Profile Russia
    }
    '7' {
        Write-Host "`n[>>] Installing Full Ultimate (1,000+ Tools) Profile..." -ForegroundColor Magenta
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Profile Full
    }
    '8' {
        Write-Host "`n[>>] Running System Diagnostics..." -ForegroundColor Yellow
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -HealthCheck
    }
    '9' {
        Write-Host "`n[>>] Running Repair Mode..." -ForegroundColor Yellow
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Repair
    }
    'R' {
        Write-Host "`n[>>] Rolling back to previous snapshot..." -ForegroundColor Red
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Rollback
    }
    '0' {
        $webUrl = "https://temkalt.github.io/claude-ultimate-hub/"
        if (Test-Path "$PSScriptRoot\index.html") { $webUrl = "$PSScriptRoot\index.html" }
        Write-Host "`n[>>] Opening Claude Code Ultimate Hub in browser..." -ForegroundColor Cyan
        Start-Process $webUrl
    }
    'Q' {
        Write-Host "`n[!] Setup cancelled by user." -ForegroundColor DarkGray
        exit 0
    }
    Default {
        Write-Host "`n[>>] Unknown selection, installing Master Profile..." -ForegroundColor Green
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Profile Master
    }
}
