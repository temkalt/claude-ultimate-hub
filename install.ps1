# ==============================================================================
#  Claude Code Ultimate Hub -- 1-Click Interactive Installer (Web & TUI Edition)
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
 ██║     ██║     ██╔══██║██║   ██║██║  ██║██╔══╝      ██╔══██║██║   ██║██╔══██╗
 ╚██████╗███████╗██║  ██║╚██████╔╝██████╔╝███████╗    ██║  ██║╚██████╔╝██████╔╝
  ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
                 CLAUDE CODE ULTIMATE HUB -- WEB & TUI v2.0.0
"@ -ForegroundColor White

    Write-Host "  -----------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  Repository: https://github.com/temkalt/claude-ultimate-hub" -ForegroundColor DarkGray
    Write-Host "  -----------------------------------------------------------------------------`n" -ForegroundColor DarkGray
}

$tempDir = Join-Path $env:TEMP ("claude-hub-" + [Guid]::NewGuid().ToString().Substring(0,8))
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
$scriptPath = Join-Path $tempDir "setup-claude-code-ultimate.ps1"
$scriptUrl = "https://raw.githubusercontent.com/temkalt/claude-ultimate-hub/main/setup-claude-code-ultimate.ps1"

# Locate or download script
$localSetup = "setup-claude-code-ultimate.ps1"
if (Test-Path $localSetup) {
    Copy-Item $localSetup $scriptPath -Force
} elseif ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot $localSetup))) {
    Copy-Item (Join-Path $PSScriptRoot $localSetup) $scriptPath -Force
} else {
    try {
        Invoke-RestMethod -Uri $scriptUrl -OutFile $scriptPath
    } catch {
        Write-Host "[-] Error loading setup engine: $_" -ForegroundColor Red
        exit 1
    }
}

Show-Header

Write-Host "  [0] ★ LAUNCH WEB CONTROL CENTER IN BROWSER (Recommended)" -ForegroundColor Cyan
Write-Host "  -----------------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "  [1] * Master All-in-One (Calibrated Global Flagship: 34 Core Tools)" -ForegroundColor Green
Write-Host "  [2] > Full-Stack Web (Next.js 15, Playwright, UI/UX Pro, TS LSP, Supabase)" -ForegroundColor White
Write-Host "  [3] > Backend & APIs (PostgreSQL, SQLite, Redis, Python Pyright, Docker)" -ForegroundColor White
Write-Host "  [4] > Core Minimal (11 Tools, Zero-Bloat Foundation, ~480 tokens)" -ForegroundColor White
Write-Host "  [5] > Security Auditor (OWASP, Bulletproof, Opus Reviewer)" -ForegroundColor White
Write-Host "  [6] > Russia / CIS Stack (Telegram, YooKassa, Yandex Cloud, Caveman)" -ForegroundColor Cyan
Write-Host "  [7] > AI & LLMOps Engineer (Qdrant, ChromaDB, Context7, HuggingFace)" -ForegroundColor White
Write-Host "  [8] > Agency Studio Swarm (50+ Specialized AI Roles)" -ForegroundColor White
Write-Host "  [9] > Full Ultimate (All 1,000+ Tools)" -ForegroundColor Magenta
Write-Host "  -----------------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "  [D] # Run 15-Point Health-Check Diagnostics" -ForegroundColor Yellow
Write-Host "  [F] # Auto-Repair Mode (Reset Safety Hooks & Config)" -ForegroundColor Yellow
Write-Host "  [R] < Rollback to Previous Snapshot" -ForegroundColor Red
Write-Host "  [Q] Exit`n" -ForegroundColor DarkGray

$choice = Read-Host "  Enter option [0-9, D, F, R, Q] (default: 0)"
if (-not $choice) { $choice = '0' }

switch ($choice.Trim().ToUpper()) {
    '0' {
        Write-Host "`n[>>] Launching Claude Code Control Center Studio..." -ForegroundColor Cyan
        
        $hubDir = Join-Path $env:USERPROFILE ".claude-ultimate-hub"
        if (-not (Test-Path $hubDir)) {
            New-Item -ItemType Directory -Path $hubDir -Force | Out-Null
        }

        $serverJs = Join-Path $hubDir "server.js"
        $appHtml = Join-Path $hubDir "app.html"

        if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot "server.js"))) {
            $serverJs = Join-Path $PSScriptRoot "server.js"
            $appHtml = Join-Path $PSScriptRoot "app.html"
        } elseif (-not (Test-Path $serverJs)) {
            Write-Host "[>>] Downloading Control Center files from GitHub..." -ForegroundColor DarkGray
            try {
                Invoke-RestMethod -Uri "https://raw.githubusercontent.com/temkalt/claude-ultimate-hub/main/server.js" -OutFile $serverJs
                Invoke-RestMethod -Uri "https://raw.githubusercontent.com/temkalt/claude-ultimate-hub/main/app.html" -OutFile $appHtml
            } catch {
                Write-Host "[-] Warning downloading server: $_" -ForegroundColor DarkGray
            }
        }

        $nodeCmd = Get-Command "node" -ErrorAction SilentlyContinue
        if ($nodeCmd -and (Test-Path $serverJs)) {
            Write-Host "[>>] Starting local execution bridge (node server.js)..." -ForegroundColor Green
            Start-Process -FilePath "node" -ArgumentList "`"$serverJs`"" -WorkingDirectory (Split-Path $serverJs) -WindowStyle Hidden -ErrorAction SilentlyContinue
            Start-Sleep -Milliseconds 800
            $targetUrl = "http://localhost:3456"
        } else {
            $targetUrl = $appHtml
        }

        Write-Host "[OK] Opening Web Control Center: $targetUrl" -ForegroundColor Green
        Start-Process $targetUrl
    }
    '1' {
        Write-Host "`n[>>] Installing Master All-in-One Profile..." -ForegroundColor Green
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Profile Master
    }
    '2' {
        Write-Host "`n[>>] Installing Full-Stack Web Profile..." -ForegroundColor White
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Profile Web
    }
    '3' {
        Write-Host "`n[>>] Installing Backend and APIs Profile..." -ForegroundColor White
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Profile Backend
    }
    '4' {
        Write-Host "`n[>>] Installing Core Minimal Profile..." -ForegroundColor White
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
        Write-Host "`n[>>] Installing AI & LLMOps Profile..." -ForegroundColor White
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Profile AI
    }
    '8' {
        Write-Host "`n[>>] Installing Agency Studio Swarm Profile..." -ForegroundColor White
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Profile Agency
    }
    '9' {
        Write-Host "`n[>>] Installing Full Ultimate Profile..." -ForegroundColor Magenta
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Profile Full
    }
    'D' {
        Write-Host "`n[>>] Running System Diagnostics..." -ForegroundColor Yellow
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -HealthCheck
    }
    'F' {
        Write-Host "`n[>>] Running Auto-Repair Mode..." -ForegroundColor Yellow
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Repair
    }
    'R' {
        Write-Host "`n[>>] Rolling back to previous snapshot..." -ForegroundColor Red
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Rollback
    }
    'Q' {
        Write-Host "`n[!] Setup cancelled by user." -ForegroundColor DarkGray
        exit 0
    }
    Default {
        Write-Host "`n[>>] Launching Web Control Center..." -ForegroundColor Cyan
        Start-Process "http://localhost:3456"
    }
}
