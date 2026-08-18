# ==============================================================================
#  CLAUDE CODE ULTIMATE HUB — 1-CLICK TERMINAL WIZARD (TUI & INSTALLER)
#  Repository: https://github.com/temkalt/claude-ultimate-hub
#  Usage: irm https://raw.githubusercontent.com/temkalt/claude-ultimate-hub/main/install.ps1 | iex
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = 'Stop'

function Show-Header {
    Clear-Host
    Write-Host @"

  ██████╗██╗      █████╗ ██╗   ██╗██████╗ ███████╗     ██╗  ██╗██╗   ██╗██████╗ 
 ██╔════╝██║     ██╔══██╗██║   ██║██╔══██╗██╔════╝     ██║  ██║██║   ██║██╔══██╗
 ██║     ██║     ███████║██║   ██║██║  ██║█████╗       ███████║██║   ██║██████╔╝
 ██║     ██║     ██╔══██║██║   ██║██║  ██║██╔══╝       ██╔══██║██║   ██║██╔══██╗
 ╚██████╗███████╗██║  ██║╚██████╔╝██████╔╝███████╗     ██║  ██║╚██████╔╝██████╔╝
  ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝     ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
                 CLAUDE CODE ULTIMATE HUB — ONYX EDITION (120+ TOOLS)
"@ -ForegroundColor White

    Write-Host "  ─────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "  Репозиторий: https://github.com/temkalt/claude-ultimate-hub" -ForegroundColor DarkGray
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
        Write-Host "[-] Ошибка загрузки установочного движка: $_" -ForegroundColor Red
        exit 1
    }
}

Show-Header

Write-Host "  Выберите действие или профиль установки:`n" -ForegroundColor Yellow

Write-Host "  [1] 🌟 Master All-in-One (Флагман: Web + Backend + РФ Стек + Память + TDD)" -ForegroundColor Green
Write-Host "  [2] 🇷🇺 РФ / СНГ Стек (Telegram, ЮKassa, Yandex Cloud, Caveman)" -ForegroundColor Cyan
Write-Host "  [3] 🌐 Full-Stack Web (Next.js 15, Playwright, UI/UX Pro, TS LSP)" -ForegroundColor White
Write-Host "  [4] ⚙️ Backend & APIs (PostgreSQL, SQLite, Redis, Python Pyright, AST-Grep)" -ForegroundColor White
Write-Host "  [5] 🔒 Security Auditor (OWASP, Bulletproof, Opus Reviewer)" -ForegroundColor White
Write-Host "  [6] 💎 Full Ultimate (Все 120+ инструментов)" -ForegroundColor Magenta
Write-Host "  ─────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host "  [7] 🩺 Запустить полную диагностику системы (Health-Check)" -ForegroundColor Yellow
Write-Host "  [8] 🔧 Режим восстановления и сброса схемы хуков (Repair)" -ForegroundColor Yellow
Write-Host "  [9] ⏪ Откатить изменения назад (Rollback)" -ForegroundColor Red
Write-Host "  [0] 🌐 Открыть интерактивный Web Hub в браузере" -ForegroundColor Blue
Write-Host "  [Q] Выход`n" -ForegroundColor DarkGray

$choice = Read-Host "  Введите номер [1-0/Q] (по умолчанию: 1)"
if (-not $choice) { $choice = '1' }

switch ($choice.Trim().ToUpper()) {
    '1' {
        Write-Host "`n[>>] Запуск установки Master All-in-One..." -ForegroundColor Green
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Profile Master
    }
    '2' {
        Write-Host "`n[>>] Запуск установки РФ / СНГ Стека..." -ForegroundColor Cyan
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Profile Russia
    }
    '3' {
        Write-Host "`n[>>] Запуск установки Full-Stack Web..." -ForegroundColor White
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Profile Web
    }
    '4' {
        Write-Host "`n[>>] Запуск установки Backend & APIs..." -ForegroundColor White
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Profile Backend
    }
    '5' {
        Write-Host "`n[>>] Запуск установки Security Auditor..." -ForegroundColor White
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Profile Security
    }
    '6' {
        Write-Host "`n[>>] Запуск установки Full Ultimate (120+)..." -ForegroundColor Magenta
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Profile Full
    }
    '7' {
        Write-Host "`n[>>] Запуск диагностики системы..." -ForegroundColor Yellow
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -HealthCheck
    }
    '8' {
        Write-Host "`n[>>] Запуск режима восстановления (Repair)..." -ForegroundColor Yellow
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Repair
    }
    '9' {
        Write-Host "`n[>>] Откат к предыдущему снимку (Rollback)..." -ForegroundColor Red
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Rollback
    }
    '0' {
        $webUrl = "https://temkalt.github.io/claude-ultimate-hub/"
        if (Test-Path "$PSScriptRoot\index.html") { $webUrl = "$PSScriptRoot\index.html" }
        Write-Host "`n[>>] Открытие веб-панели управления..." -ForegroundColor Blue
        Start-Process $webUrl
    }
    'Q' {
        Write-Host "`nВыход." -ForegroundColor DarkGray
        exit 0
    }
    Default {
        Write-Host "`n[>>] Выбран профиль Master All-in-One..." -ForegroundColor Green
        powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -Profile Master
    }
}

Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
