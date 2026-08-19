# ==============================================================================
#  Claude Code Ultimate Hub — 1-Click Interactive Launcher v3.0.0
#  Repository: https://github.com/temkalt/claude-ultimate-hub
# ==============================================================================

[CmdletBinding()]
param(
    [string]$Profile = '',
    [string]$Components = '',
    [switch]$HealthCheck,
    [switch]$Repair,
    [switch]$Rollback,
    [switch]$DryRun
)

try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
} catch {}

Clear-Host
Write-Host @"
  ██████╗██╗      █████╗ ██╗   ██╗██████╗ ███████╗    ██╗  ██╗██╗   ██╗██████╗ 
 ██╔════╝██║     ██╔══██╗██║   ██║██╔══██╗██╔════╝    ██║  ██║██║   ██║██╔══██╗
 ██║     ██║     ███████║██║   ██║██║  ██║█████╗      ███████║██║   ██║██████╔╝
 ██║     ██║     ██╔══██║██║   ██║██║  ██║██╔══╝      ██╔══██║██║   ██║██╔══██╗
 ╚██████╗███████╗██║  ██║╚██████╔╝██████╔╝███████╗    ██║  ██║╚██████╔╝██████╔╝
  ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
                 CLAUDE CODE ULTIMATE HUB v3.0.0 (Masterpiece)
"@ -ForegroundColor Cyan

Write-Host "  -----------------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "  Web Control Center: http://localhost:3456/ | GitHub: temkalt/claude-ultimate-hub" -ForegroundColor DarkGray
Write-Host "  -----------------------------------------------------------------------------`n" -ForegroundColor DarkGray

# 1. Prepare Local Hub Directory
$hubDir = Join-Path $env:USERPROFILE ".claude-ultimate-hub"
if (-not (Test-Path $hubDir)) {
    New-Item -ItemType Directory -Path $hubDir -Force | Out-Null
}

$serverJs = Join-Path $hubDir "server.js"
$appHtml = Join-Path $hubDir "app.html"
$setupPs1 = Join-Path $hubDir "setup-claude-code-ultimate.ps1"

# If running from cloned repo, use local files
if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot "server.js"))) {
    $hubDir = $PSScriptRoot
    $serverJs = Join-Path $PSScriptRoot "server.js"
    $appHtml = Join-Path $PSScriptRoot "app.html"
    $setupPs1 = Join-Path $PSScriptRoot "setup-claude-code-ultimate.ps1"
} else {
    Write-Host "  [>>] Synchronizing latest ecosystem files from GitHub..." -ForegroundColor DarkGray
    $baseUrl = "https://raw.githubusercontent.com/temkalt/claude-ultimate-hub/main"
    try {
        Invoke-RestMethod -Uri "$baseUrl/server.js" -OutFile $serverJs
        Invoke-RestMethod -Uri "$baseUrl/app.html" -OutFile $appHtml
        Invoke-RestMethod -Uri "$baseUrl/setup-claude-code-ultimate.ps1" -OutFile $setupPs1
    } catch {
        Write-Host "  [-] Notice: Using cached ecosystem files ($($_.Exception.Message))" -ForegroundColor DarkGray
    }
}

# 2. Check Node.js
$nodeCmd = Get-Command "node" -ErrorAction SilentlyContinue
if (-not $nodeCmd) {
    Write-Host "  [XX] Node.js is required to run the Control Center." -ForegroundColor Red
    Write-Host "  Please install Node.js from https://nodejs.org/ and run this command again.`n" -ForegroundColor Yellow
    
    # Fallback to static app.html
    if (Test-Path $appHtml) {
        Write-Host "  [>>] Opening standalone Web UI in your browser..." -ForegroundColor Cyan
        Start-Process $appHtml
    }
    exit 1
}

$nodeVer = & node -v
Write-Host "  [OK] Node.js Runtime: $nodeVer" -ForegroundColor Green

# 3. Direct CLI Mode execution (if parameters provided)
if ($Profile -or $HealthCheck -or $Repair -or $Rollback -or $DryRun) {
    Write-Host "  [>>] Executing CLI configuration..." -ForegroundColor Cyan
    $argsList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $setupPs1)
    if ($Profile) { $argsList += @('-Profile', $Profile) }
    if ($Components) { $argsList += @('-Components', $Components) }
    if ($HealthCheck) { $argsList += '-HealthCheck' }
    if ($Repair) { $argsList += '-Repair' }
    if ($Rollback) { $argsList += '-Rollback' }
    if ($DryRun) { $argsList += '-DryRun' }

    & powershell @argsList
    exit $LASTEXITCODE
}

# 4. Interactive Web Control Center Launch (Default Mode)
Write-Host "  [>>] Starting Local Execution Bridge on http://localhost:3456/..." -ForegroundColor Green
Write-Host "  [>>] Opening Web Control Center in your default browser...`n" -ForegroundColor Cyan

# Open browser after short delay
Start-Process "http://localhost:3456/"

# Run the node server in this console to keep live logs streaming
Set-Location $hubDir
& node "$serverJs"
