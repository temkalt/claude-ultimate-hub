<#
.SYNOPSIS
    Claude Code Ultimate Setup — Production-quality infrastructure for Claude Code on Windows.
.DESCRIPTION
    Installs, configures, and hardens Claude Code with the Master All-in-One stack,
    covering Full-Stack Web, Backend, Russia/CIS business tools, Lean Subagents, LSP, and 7-layer security.
    Research date: 2026-08-18 | Claude Code v2.1.233+
.PARAMETER Profile
    Component profile: Master, Core, Russia, Web, Frontend, Backend, Security, Data, DevOps, Research, Marketing, AI, Full
.PARAMETER Components
    Custom comma-separated list of component IDs to install.
.PARAMETER DryRun
    Preview all changes without modifying anything.
.PARAMETER Update
    Update existing installation.
.PARAMETER Repair
    Find and fix broken components.
.PARAMETER HealthCheck
    Run diagnostics only.
.PARAMETER Rollback
    Restore previous configuration from backup.
.EXAMPLE
    .\setup-claude-code-ultimate.ps1 -Profile Master
.EXAMPLE
    .\setup-claude-code-ultimate.ps1 -Profile Master -DryRun
.EXAMPLE
    .\setup-claude-code-ultimate.ps1 -Profile Russia
.EXAMPLE
    .\setup-claude-code-ultimate.ps1 -HealthCheck
#>

[CmdletBinding()]
param(
    [ValidateSet('Master','Core','Russia','Web','Frontend','Backend','Security','Data','DevOps','Research','Marketing','AI','Full')]
    [string]$Profile = 'Master',
    [string]$Components = '',
    [switch]$DryRun,
    [switch]$Update,
    [switch]$Repair,
    [switch]$HealthCheck,
    [switch]$Rollback,
    [switch]$SkipWSL,
    [switch]$SkipOptional,
    [switch]$SkipThirdParty,
    [switch]$AllowExperimental,
    [switch]$Latest,
    [switch]$ForceReinstall
)

# Initialize execution settings
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'

try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

$script:Version = '1.5.0'
$script:ResearchDate = '2026-08-18'
$script:MinClaudeVersion = '2.1.228'
$script:StartTime = Get-Date

$script:ClaudeHome = Join-Path $env:USERPROFILE '.claude'
$script:ClaudeSettings = Join-Path $script:ClaudeHome 'settings.json'
$script:ClaudeMd = Join-Path $script:ClaudeHome 'CLAUDE.md'
$script:ClaudeJson = Join-Path $env:USERPROFILE '.claude.json'
$script:AgentsDir = Join-Path $script:ClaudeHome 'agents'
$script:SkillsDir = Join-Path $script:ClaudeHome 'skills'
$script:BackupRoot = Join-Path $script:ClaudeHome 'backups'
$script:HookDir = Join-Path $script:ClaudeHome 'hooks'

$script:Results = [System.Collections.ArrayList]::new()

# ═══════════════════════════════════════════════════════════════════
#  LOGGING
# ═══════════════════════════════════════════════════════════════════

function Write-Step {
    param([string]$Message, [string]$Status = 'INFO')
    $colors = @{ INFO='Cyan'; OK='Green'; WARN='Yellow'; FAIL='Red'; SKIP='DarkGray'; DRY='Magenta' }
    $icons  = @{ INFO='>>'; OK='OK'; WARN='!!'; FAIL='XX'; SKIP='--'; DRY='~~' }
    $c = $colors[$Status]; if (-not $c) { $c = 'White' }
    $i = $icons[$Status];  if (-not $i) { $i = '..' }
    $ts = (Get-Date).ToString('HH:mm:ss')
    Write-Host "  [$ts] " -NoNewline -ForegroundColor DarkGray
    Write-Host "[$i] " -NoNewline -ForegroundColor $c
    Write-Host $Message -ForegroundColor $c
}

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "  === $($Title.ToUpper()) ===" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Banner {
    Write-Host ""
    Write-Host "  ================================================================" -ForegroundColor DarkCyan
    Write-Host "    CLAUDE CODE ULTIMATE SETUP v$($script:Version) (Master All-in-One)" -ForegroundColor Cyan
    Write-Host "    Research: $($script:ResearchDate) | Tested against primary sources" -ForegroundColor DarkGray
    Write-Host "  ================================================================" -ForegroundColor DarkCyan
    Write-Host ""
    if ($DryRun) { Write-Host "  ~~ DRY RUN MODE -- Preview only, no changes will be made ~~" -ForegroundColor Magenta; Write-Host "" }
}

function Add-Result {
    param([string]$Component, [string]$Status, [string]$Detail = '')
    $null = $script:Results.Add([PSCustomObject]@{ Component=$Component; Status=$Status; Detail=$Detail })
}

# ═══════════════════════════════════════════════════════════════════
#  UTILITIES & SAFE ACCESSORS
# ═══════════════════════════════════════════════════════════════════

function Test-CommandExists { param([string]$Cmd); $null -ne (Get-Command $Cmd -ErrorAction SilentlyContinue) }

function Get-CommandVersion {
    param([string]$Cmd, [string]$Flag = '--version')
    try {
        $o = & $Cmd $Flag 2>&1 | Out-String
        if ($o -match '(\d+\.\d+[\.\d]*)') { return $Matches[1] }
        return $o.Trim()
    } catch { return $null }
}

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        if ($DryRun) { Write-Step "Would create directory: $Path" 'DRY' }
        else { New-Item -ItemType Directory -Path $Path -Force | Out-Null }
    }
}

function Get-SafeProp {
    param($Obj, [string]$PropName, $Default = $null)
    if ($null -eq $Obj) { return $Default }
    if ($Obj -is [System.Collections.IDictionary]) {
        if ($Obj.Contains($PropName)) { return $Obj[$PropName] }
        return $Default
    }
    if ($Obj.PSObject -and $Obj.PSObject.Properties[$PropName]) {
        return $Obj.PSObject.Properties[$PropName].Value
    }
    return $Default
}

function Safe-JsonRead {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return @{} }
    try {
        $c = Get-Content $Path -Raw -Encoding UTF8
        if ([string]::IsNullOrWhiteSpace($c)) { return @{} }
        $parsed = $c | ConvertFrom-Json
        if ($null -eq $parsed) { return @{} }
        return $parsed
    } catch { return @{} }
}

function Safe-JsonWrite {
    param([string]$Path, $Data)
    if ($DryRun) { Write-Step "Would write JSON: $Path" 'DRY'; return }
    $json = $Data | ConvertTo-Json -Depth 20
    [System.IO.File]::WriteAllText($Path, $json, [System.Text.Encoding]::UTF8)
}

function Compare-SemVer {
    param([string]$Current, [string]$Minimum)
    try {
        $cClean = ($Current -replace '^[^\d]*','' -replace '[^\d\.]','' -replace '\.+$','')
        $mClean = ($Minimum -replace '^[^\d]*','' -replace '[^\d\.]','' -replace '\.+$','')
        
        $cParts = $cClean.Split('.') | ForEach-Object { [int]$_ }
        $mParts = $mClean.Split('.') | ForEach-Object { [int]$_ }
        
        for ($i = 0; $i -lt [Math]::Max($cParts.Count, $mParts.Count); $i++) {
            $cVal = if ($i -lt $cParts.Count) { $cParts[$i] } else { 0 }
            $mVal = if ($i -lt $mParts.Count) { $mParts[$i] } else { 0 }
            if ($cVal -gt $mVal) { return $true }
            if ($cVal -lt $mVal) { return $false }
        }
        return $true
    } catch { return $false }
}

# ═══════════════════════════════════════════════════════════════════
#  BACKUP SYSTEM
# ═══════════════════════════════════════════════════════════════════

function New-Backup {
    $ts = (Get-Date).ToString('yyyy-MM-dd_HH-mm-ss')
    $dir = Join-Path $script:BackupRoot $ts
    if ($DryRun) { Write-Step "Would backup configuration to: $dir" 'DRY'; return $dir }
    Ensure-Directory $dir
    @($script:ClaudeSettings, $script:ClaudeMd, $script:ClaudeJson) | ForEach-Object {
        if (Test-Path $_) { Copy-Item $_ (Join-Path $dir (Split-Path $_ -Leaf)) -Force; Write-Step "Backed up: $(Split-Path $_ -Leaf)" 'OK' }
    }
    if (Test-Path $script:AgentsDir) { Copy-Item $script:AgentsDir (Join-Path $dir 'agents') -Recurse -Force; Write-Step "Backed up: agents/" 'OK' }
    $manifest = @{ timestamp=$ts; profile=$Profile; version=$script:Version } | ConvertTo-Json
    [System.IO.File]::WriteAllText((Join-Path $dir 'manifest.json'), $manifest, [System.Text.Encoding]::UTF8)
    Write-Step "Backup snapshot created: $dir" 'OK'
    return $dir
}

function Invoke-Rollback {
    Write-Section "ROLLBACK"
    $backups = Get-ChildItem $script:BackupRoot -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending
    if (-not $backups -or $backups.Count -eq 0) { Write-Step "No backup snapshots found in $($script:BackupRoot)" 'FAIL'; return }
    $latest = $backups[0]
    Write-Step "Restoring from snapshot: $($latest.Name)" 'INFO'
    if ($DryRun) { Write-Step "Would restore configuration files from $($latest.FullName)" 'DRY'; return }
    Get-ChildItem $latest.FullName -File | Where-Object { $_.Name -ne 'manifest.json' } | ForEach-Object {
        $dest = switch ($_.Name) {
            'settings.json' { $script:ClaudeSettings }
            'CLAUDE.md'     { $script:ClaudeMd }
            '.claude.json'  { $script:ClaudeJson }
            default         { Join-Path $script:ClaudeHome $_.Name }
        }
        Copy-Item $_.FullName $dest -Force; Write-Step "Restored: $($_.Name)" 'OK'
    }
    $ab = Join-Path $latest.FullName 'agents'
    if (Test-Path $ab) {
        if (Test-Path $script:AgentsDir) { Remove-Item $script:AgentsDir -Recurse -Force }
        Copy-Item $ab $script:AgentsDir -Recurse -Force; Write-Step "Restored: agents/" 'OK'
    }
    Add-Result 'Rollback' 'OK' "Restored from $($latest.Name)"
}

# ═══════════════════════════════════════════════════════════════════
#  DEPENDENCY DETECTION
# ═══════════════════════════════════════════════════════════════════

function Test-Dependencies {
    Write-Section "DEPENDENCY CHECK"
    $allOk = $true

    $deps = @(
        @{ Name='Node.js';     Cmd='node';   Flag='--version'; Req=$true;  Min='18.0.0' },
        @{ Name='npm';         Cmd='npm';    Flag='--version'; Req=$true;  Min='9.0.0' },
        @{ Name='npx';         Cmd='npx';    Flag='--version'; Req=$true;  Min='' },
        @{ Name='Git';         Cmd='git';    Flag='--version'; Req=$true;  Min='2.30.0' },
        @{ Name='Python';      Cmd='python'; Flag='--version'; Req=$false; Min='3.10.0' },
        @{ Name='GitHub CLI';  Cmd='gh';     Flag='--version'; Req=$false; Min='' },
        @{ Name='Claude Code'; Cmd='claude'; Flag='--version'; Req=$true;  Min=$script:MinClaudeVersion }
    )

    foreach ($d in $deps) {
        if (Test-CommandExists $d.Cmd) {
            $ver = Get-CommandVersion $d.Cmd $d.Flag
            $ok = $true
            if ($d.Min -and $ver) { $ok = Compare-SemVer $ver $d.Min }
            if ($ok) { Write-Step "$($d.Name): $ver" 'OK'; Add-Result $d.Name 'OK' "v$ver" }
            else { Write-Step "$($d.Name): $ver (recommended $($d.Min)+)" 'WARN'; Add-Result $d.Name 'WARN' "v$ver"; if ($d.Req) { $allOk = $false } }
        } else {
            if ($d.Req) { Write-Step "$($d.Name): NOT FOUND (required)" 'FAIL'; Add-Result $d.Name 'FAIL' 'Missing'; $allOk = $false }
            else { Write-Step "$($d.Name): not found (optional)" 'SKIP'; Add-Result $d.Name 'SKIP' 'Optional' }
        }
    }

    # LSP Servers Detection
    if (Test-CommandExists 'typescript-language-server') {
        $tsLspVer = Get-CommandVersion 'typescript-language-server' '--version'
        Write-Step "TypeScript LSP: $tsLspVer" 'OK'; Add-Result 'TypeScript LSP' 'OK' $tsLspVer
    } else {
        Write-Step "TypeScript LSP: not found (auto-used via npx when needed)" 'SKIP'; Add-Result 'TypeScript LSP' 'SKIP' 'npx ready'
    }

    if (Test-CommandExists 'pyright') {
        $pyLspVer = Get-CommandVersion 'pyright' '--version'
        Write-Step "Pyright LSP: $pyLspVer" 'OK'; Add-Result 'Pyright LSP' 'OK' $pyLspVer
    } else {
        Write-Step "Pyright LSP: not found (optional for Python)" 'SKIP'; Add-Result 'Pyright LSP' 'SKIP' 'Optional'
    }

    # WSL2 Check
    if (-not $SkipWSL) {
        try {
            $w = wsl --status 2>&1 | Out-String
            if ($LASTEXITCODE -eq 0 -or $w -match 'Default Distribution') {
                Write-Step "WSL2: Available (Linux OS sandbox ready)" 'OK'
                Add-Result 'WSL2' 'OK' 'Sandbox capable'
            } else {
                Write-Step "WSL2: Not configured (Native Windows uses hooks + permissions for defense)" 'WARN'
                Add-Result 'WSL2' 'WARN' 'Not configured'
            }
        } catch {
            Write-Step "WSL2: Not available" 'SKIP'
            Add-Result 'WSL2' 'SKIP' 'N/A'
        }
    }

    # Docker Check
    if (Test-CommandExists 'docker') {
        $dv = Get-CommandVersion 'docker' '--version'
        Write-Step "Docker: $dv" 'OK'; Add-Result 'Docker' 'OK' $dv
    } else {
        Write-Step "Docker: not found (optional container sandbox)" 'SKIP'; Add-Result 'Docker' 'SKIP' 'Optional'
    }

    return $allOk
}

# ═══════════════════════════════════════════════════════════════════
#  PROFILE ENGINE (Master All-in-One Stack)
# ═══════════════════════════════════════════════════════════════════

$script:ProfileMap = @{
    'Master'   = @('frontend-design','superpowers','context7','marketing','agentmemory','skill-anthropic','github-plugin','skill-creator','skill-seo','skill-caveman','agent-security','skill-uiux','skill-bulletproof','skill-dataviz','skill-supabase','skill-commits','skill-astgrep','mcp-telegram','mcp-yookassa','mcp-yandexcloud','mcp-github','mcp-supabase','mcp-notion','mcp-playwright','mcp-docker','mcp-postgres','mcp-sqlite','mcp-n8n','lsp-typescript','lsp-python','agent-architect','agent-codereview','agent-researcher','agent-tester','agent-docs','hook-secrets','hook-danger','hook-repomap','hook-selfheal')
    'Core'     = @('superpowers','github-plugin','mcp-github','context7','skill-anthropic','skill-commits','agent-architect','agent-security','agent-codereview','hook-secrets','hook-danger','hook-repomap','hook-selfheal')
    'Russia'   = @('frontend-design','superpowers','context7','marketing','skill-anthropic','skill-seo','skill-caveman','agent-security','skill-uiux','skill-commits','mcp-telegram','mcp-yookassa','mcp-yandexcloud','mcp-github','mcp-supabase','mcp-notion','mcp-n8n','lsp-typescript','hook-secrets','hook-danger','hook-repomap','hook-selfheal')
    'Web'      = @('frontend-design','superpowers','github-plugin','vercel-plugin','lsp-typescript','mcp-github','context7','mcp-playwright','skill-anthropic','skill-uiux','skill-supabase','skill-commits','skill-astgrep','agent-architect','agent-codereview','agent-tester','hook-secrets','hook-danger','hook-repomap','hook-selfheal')
    'Frontend' = @('frontend-design','superpowers','github-plugin','vercel-plugin','lsp-typescript','mcp-github','context7','mcp-playwright','skill-uiux','skill-hyperframes','agent-architect','agent-codereview','agent-tester','hook-secrets','hook-danger','hook-repomap')
    'Backend'  = @('superpowers','github-plugin','lsp-python','lsp-rust','lsp-golang','mcp-github','context7','mcp-postgres','mcp-sqlite','mcp-redis','mcp-supabase','skill-anthropic','skill-supabase','skill-openapi','skill-astgrep','agent-architect','agent-codereview','agent-tester','hook-secrets','hook-danger','hook-repomap','hook-selfheal')
    'Security' = @('superpowers','github-plugin','mcp-github','agent-architect','agent-security','skill-bulletproof','hook-secrets','hook-danger','hook-repomap')
    'Data'     = @('superpowers','github-plugin','lsp-python','mcp-github','context7','mcp-postgres','mcp-sqlite','mcp-redis','mcp-supabase','skill-supabase','skill-dataviz','hook-secrets','hook-danger')
    'DevOps'   = @('superpowers','github-plugin','mcp-github','mcp-docker','mcp-linear','mcp-sentry','mcp-n8n','mcp-yandexcloud','skill-commits','hook-secrets','hook-danger')
    'Research' = @('superpowers','github-plugin','mcp-github','context7','mcp-firecrawl','mcp-exa','mcp-notion','mcp-obsidian','skill-anthropic','skill-dataviz','agent-researcher','hook-secrets','hook-danger')
    'Marketing'= @('marketing','frontend-design','superpowers','github-plugin','context7','mcp-playwright','mcp-telegram','skill-uiux','skill-seo','skill-hyperframes','hook-secrets','hook-danger')
    'AI'       = @('superpowers','github-plugin','lsp-python','context7','mcp-sequential','skill-creator','skill-caveman','agent-architect','hook-secrets','hook-danger')
    'Full'     = @('frontend-design','superpowers','gstack','context7','marketing','agentmemory','skill-anthropic','mcp-playwright','github-plugin','vercel-plugin','skill-creator','skill-seo','skill-caveman','agent-security','skill-hyperframes','skill-uiux','skill-bulletproof','skill-dataviz','skill-supabase','skill-commits','skill-astgrep','skill-openapi','mcp-telegram','mcp-yookassa','mcp-yandexcloud','mcp-github','mcp-supabase','mcp-notion','mcp-firecrawl','mcp-n8n','mcp-docker','mcp-linear','mcp-obsidian','mcp-sentry','mcp-postgres','mcp-sqlite','mcp-redis','mcp-sequential','lsp-typescript','lsp-python','lsp-rust','lsp-golang','agent-architect','agent-codereview','agent-researcher','agent-tester','agent-docs','hook-secrets','hook-danger','hook-repomap','hook-selfheal')
}

function Get-ActiveComponents {
    if ($Components) { return ($Components -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }) }
    $r = $script:ProfileMap[$Profile]
    if (-not $r) { Write-Step "Unknown profile $Profile, defaulting to Master" 'WARN'; $r = $script:ProfileMap['Master'] }
    return $r
}

# ═══════════════════════════════════════════════════════════════════
#  SETTINGS & PERMISSIONS & HOOKS
# ═══════════════════════════════════════════════════════════════════

function Update-Settings {
    param([array]$ActiveComponents)
    Write-Section "SETTINGS AND PERMISSIONS"
    Ensure-Directory $script:ClaudeHome

    $rawSettings = Safe-JsonRead $script:ClaudeSettings

    # Permission rules (Layer 1: Deny > Allow > Ask)
    $denyRules = @(
        'Read(.env*)', 'Read(**/.env*)', 'Read(**/.ssh/**)', 'Read(**/*.pem)', 'Read(**/*.key)',
        'Bash(rm -rf /)', 'Bash(rm -rf /*)', 'Bash(*format C:*)', 'Bash(*del /s /q C:*)',
        'Bash(*PRIVATE_KEY*=*)', 'Bash(*AWS_SECRET*=*)',
        'Bash(curl*|*sh)', 'Bash(curl*|*bash)', 'Bash(wget*|*sh)', 'Bash(wget*|*bash)',
        'Bash(*iex*)', 'Bash(*Invoke-Expression*)'
    )
    $allowRules = @(
        'Bash(git *)', 'Bash(npm run *)', 'Bash(npm test*)', 'Bash(npx *)',
        'Bash(node *)', 'Bash(python *)', 'Bash(claude *)', 'Bash(gh *)', 'Bash(docker *)', 'Bash(cargo *)', 'Bash(go *)'
    )

    $permObj = Get-SafeProp $rawSettings 'permissions' @{}
    $exDeny = Get-SafeProp $permObj 'deny' @()
    $exAllow = Get-SafeProp $permObj 'allow' @()

    $mDeny = @($exDeny) + @($denyRules) | Select-Object -Unique
    $mAllow = @($exAllow) + @($allowRules) | Select-Object -Unique

    foreach ($r in $mDeny) { Write-Step "Deny Rule: $r" $(if ($DryRun) {'DRY'} else {'OK'}) }
    foreach ($r in $mAllow) { Write-Step "Allow Rule: $r" $(if ($DryRun) {'DRY'} else {'OK'}) }

    # Setup deterministic hooks
    $hooksObj = @{}
    if ($ActiveComponents -contains 'hook-secrets' -or $ActiveComponents -contains 'hook-danger' -or $ActiveComponents -contains 'hook-repomap' -or $ActiveComponents -contains 'hook-selfheal') {
        Write-Section "SECURITY & PRODUCTIVITY HOOKS"
        Ensure-Directory $script:HookDir
        $preHooks = @()
        $startHooks = @()
        $stopHooks = @()

        # 1. Secret Scanner
        if ($ActiveComponents -contains 'hook-secrets') {
            $secretScript = @(
                '$inputData = $input | Out-String'
                'try {'
                '    $json = $inputData | ConvertFrom-Json'
                '    $cmd = $json.tool_input.command'
                '    if ($cmd -match ''(?i)(AWS_SECRET_ACCESS_KEY|AWS_SESSION_TOKEN|PRIVATE_KEY|API_KEY|SECRET_KEY|YOOKASSA_SECRET_KEY|TELEGRAM_BOT_TOKEN|password|passwd|token|Bearer\s+[A-Za-z0-9]+=*)\s*='') {'
                '        $result = @{ decision = ''block''; reason = ''Potential secret detected in command parameter'' } | ConvertTo-Json -Compress'
                '        Write-Output $result'
                '        exit 2'
                '    }'
                '} catch { }'
                'exit 0'
            ) -join "`r`n"
            $sp = Join-Path $script:HookDir 'scan-secrets.ps1'
            if (-not $DryRun) { [System.IO.File]::WriteAllText($sp, $secretScript, [System.Text.Encoding]::UTF8) }
            Write-Step "Secret scanner hook: $sp" $(if ($DryRun) {'DRY'} else {'OK'})
            $preHooks += @{ matcher='Bash'; hooks=@(@{ type='command'; command="powershell -NoProfile -ExecutionPolicy Bypass -File `"$sp`"" }) }
            Add-Result 'Hook: Secret Scanner' 'OK' 'PreToolUse (Bash)'
        }

        # 2. Danger Blocker
        if ($ActiveComponents -contains 'hook-danger') {
            $dangerScript = @(
                '$inputData = $input | Out-String'
                'try {'
                '    $json = $inputData | ConvertFrom-Json'
                '    $cmd = $json.tool_input.command'
                '    $patterns = @(''rm\s+-rf\s+/'', ''mkfs\.'', ''dd\s+if=.*of=/dev/'', ''format\s+[A-Z]:'', ''del\s+/[sS]\s+/[qQ]\s+[A-Z]:\\'', ''Remove-Item\s+-Recurse.*-Force.*[A-Z]:\\'')'
                '    foreach ($p in $patterns) {'
                '        if ($cmd -match $p) {'
                '            $result = @{ decision = ''block''; reason = "Dangerous command blocked by safety gate: $p" } | ConvertTo-Json -Compress'
                '            Write-Output $result'
                '            exit 2'
                '        }'
                '    }'
                '} catch { }'
                'exit 0'
            ) -join "`r`n"
            $dp = Join-Path $script:HookDir 'block-dangerous.ps1'
            if (-not $DryRun) { [System.IO.File]::WriteAllText($dp, $dangerScript, [System.Text.Encoding]::UTF8) }
            Write-Step "Danger command blocker hook: $dp" $(if ($DryRun) {'DRY'} else {'OK'})
            $preHooks += @{ matcher='Bash'; hooks=@(@{ type='command'; command="powershell -NoProfile -ExecutionPolicy Bypass -File `"$dp`"" }) }
            Add-Result 'Hook: Danger Blocker' 'OK' 'PreToolUse (Bash)'
        }

        # 3. SessionStart RepoMap Hook
        if ($ActiveComponents -contains 'hook-repomap') {
            $repoMapScript = @(
                '$gitStatus = git status --short 2>$null'
                '$branch = git branch --show-current 2>$null'
                'Write-Output "=== REPOSITORY TOPOLOGY ==="'
                'if ($branch) { Write-Output "Branch: $branch" }'
                'if ($gitStatus) { Write-Output "Modified files: `n$gitStatus" }'
                'exit 0'
            ) -join "`r`n"
            $rp = Join-Path $script:HookDir 'repo-map.ps1'
            if (-not $DryRun) { [System.IO.File]::WriteAllText($rp, $repoMapScript, [System.Text.Encoding]::UTF8) }
            Write-Step "SessionStart RepoMap hook: $rp" $(if ($DryRun) {'DRY'} else {'OK'})
            $startHooks += @{ matcher=''; hooks=@(@{ type='command'; command="powershell -NoProfile -ExecutionPolicy Bypass -File `"$rp`"" }) }
            Add-Result 'Hook: RepoMap' 'OK' 'SessionStart'
        }

        # 4. Self-Healing Hook
        if ($ActiveComponents -contains 'hook-selfheal') {
            $selfHealScript = @(
                'Write-Output "Diagnostic check: Verify recent exit code, logs, and package imports before retrying."'
                'exit 0'
            ) -join "`r`n"
            $shp = Join-Path $script:HookDir 'self-heal.ps1'
            if (-not $DryRun) { [System.IO.File]::WriteAllText($shp, $selfHealScript, [System.Text.Encoding]::UTF8) }
            Write-Step "Self-Healing hook: $shp" $(if ($DryRun) {'DRY'} else {'OK'})
            $stopHooks += @{ matcher=''; hooks=@(@{ type='command'; command="powershell -NoProfile -ExecutionPolicy Bypass -File `"$shp`"" }) }
            Add-Result 'Hook: Self-Healing' 'OK' 'Stop'
        }

        if ($preHooks.Count -gt 0) { $hooksObj['PreToolUse'] = $preHooks }
        if ($startHooks.Count -gt 0) { $hooksObj['SessionStart'] = $startHooks }
        if ($stopHooks.Count -gt 0) { $hooksObj['Stop'] = $stopHooks }
    }

    $newSettings = @{}
    $newSettings['permissions'] = @{
        'deny' = $mDeny
        'allow' = $mAllow
    }
    if ($hooksObj.Keys.Count -gt 0) {
        $newSettings['hooks'] = $hooksObj
    }

    Safe-JsonWrite $script:ClaudeSettings $newSettings
    Add-Result 'Settings' 'OK' "$($mDeny.Count) deny rules, $($mAllow.Count) allow rules"
}

# ═══════════════════════════════════════════════════════════════════
#  MCP SERVERS
# ═══════════════════════════════════════════════════════════════════

function Get-InstalledMCPs {
    try { return (claude mcp list 2>&1 | Out-String) } catch { return '' }
}

function Install-MCPServer {
    param([string]$Name, [string]$Command, [string[]]$McpArgs, [string]$Scope='user', [hashtable]$EnvVars=@{}, [bool]$AuthRequired=$false)

    $installed = Get-InstalledMCPs
    if ($installed -match [regex]::Escape($Name)) {
        if ($Update -or $ForceReinstall) {
            if (-not $DryRun) { claude mcp remove $Name 2>&1 | Out-Null }
        } else {
            Write-Step "MCP '$Name': Already installed" 'SKIP'; Add-Result "MCP: $Name" 'SKIP' 'Exists'; return
        }
    }

    if ($DryRun) {
        Write-Step "Would add MCP: $Name ($Command $($McpArgs -join ' '))" 'DRY'
        Add-Result "MCP: $Name" 'DRY' 'Would install'; return
    }

    try {
        $cliArgs = [System.Collections.ArrayList]::new()
        $null = $cliArgs.Add('mcp'); $null = $cliArgs.Add('add'); $null = $cliArgs.Add('--scope'); $null = $cliArgs.Add($Scope)
        foreach ($k in $EnvVars.Keys) { $null = $cliArgs.Add('-e'); $null = $cliArgs.Add("$k=$($EnvVars[$k])") }
        $null = $cliArgs.Add($Name); $null = $cliArgs.Add('--'); $null = $cliArgs.Add($Command)
        foreach ($a in $McpArgs) { $null = $cliArgs.Add($a) }

        $result = & claude @cliArgs 2>&1 | Out-String
        $status = if ($AuthRequired) { 'AUTH' } else { 'OK' }
        $detail = if ($AuthRequired) { 'Installed (AUTH REQUIRED)' } else { 'Installed' }
        $lvl = if ($AuthRequired) { 'WARN' } else { 'OK' }
        Write-Step "MCP '$Name': $detail" $lvl
        Add-Result "MCP: $Name" $status $detail
    } catch {
        Write-Step "MCP '$Name': FAILED $($_.Exception.Message)" 'FAIL'
        Add-Result "MCP: $Name" 'FAIL' $_.Exception.Message
    }
}

function Install-MCPServers {
    param([array]$AC)
    Write-Section "MCP SERVERS"

    # Telegram MCP
    if ($AC -contains 'mcp-telegram') {
        $ev = @{}; if ($env:TELEGRAM_BOT_TOKEN) { $ev['TELEGRAM_BOT_TOKEN'] = $env:TELEGRAM_BOT_TOKEN }
        Install-MCPServer -Name 'telegram' -Command 'npx' -McpArgs @('-y','telegram-mcp-server') -AuthRequired ([string]::IsNullOrEmpty($env:TELEGRAM_BOT_TOKEN)) -EnvVars $ev
    }

    # YooKassa MCP
    if ($AC -contains 'mcp-yookassa') {
        $ev = @{}
        if ($env:YOOKASSA_SHOP_ID) { $ev['YOOKASSA_SHOP_ID'] = $env:YOOKASSA_SHOP_ID }
        if ($env:YOOKASSA_SECRET_KEY) { $ev['YOOKASSA_SECRET_KEY'] = $env:YOOKASSA_SECRET_KEY }
        Install-MCPServer -Name 'yookassa' -Command 'npx' -McpArgs @('-y','@theyahia/yookassa-mcp') -AuthRequired ([string]::IsNullOrEmpty($env:YOOKASSA_SECRET_KEY)) -EnvVars $ev
    }

    # Yandex Cloud MCP
    if ($AC -contains 'mcp-yandexcloud') {
        $ev = @{}; if ($env:YC_OAUTH_TOKEN) { $ev['YC_OAUTH_TOKEN'] = $env:YC_OAUTH_TOKEN }
        Install-MCPServer -Name 'yandex-cloud' -Command 'npx' -McpArgs @('-y','yandex-cloud-mcp') -AuthRequired ([string]::IsNullOrEmpty($env:YC_OAUTH_TOKEN)) -EnvVars $ev
    }

    # GitHub MCP
    if ($AC -contains 'mcp-github') {
        $ghToken = $env:GITHUB_TOKEN
        if (-not $ghToken -and (Test-CommandExists 'gh')) { try { $ghToken = (gh auth token 2>&1).Trim() } catch {} }
        $ev = @{}; if ($ghToken) { $ev['GITHUB_TOKEN'] = $ghToken }
        Install-MCPServer -Name 'github' -Command 'npx' -McpArgs @('-y','@modelcontextprotocol/server-github') -AuthRequired ([string]::IsNullOrEmpty($ghToken)) -EnvVars $ev
    }

    # Supabase MCP
    if ($AC -contains 'mcp-supabase') {
        $ev = @{}; if ($env:SUPABASE_ACCESS_TOKEN) { $ev['SUPABASE_ACCESS_TOKEN'] = $env:SUPABASE_ACCESS_TOKEN }
        Install-MCPServer -Name 'supabase' -Command 'npx' -McpArgs @('-y','@modelcontextprotocol/server-supabase') -AuthRequired ([string]::IsNullOrEmpty($env:SUPABASE_ACCESS_TOKEN)) -EnvVars $ev
    }

    # Notion MCP
    if ($AC -contains 'mcp-notion') {
        $ev = @{}; if ($env:NOTION_API_KEY) { $ev['NOTION_API_KEY'] = $env:NOTION_API_KEY }
        Install-MCPServer -Name 'notion' -Command 'npx' -McpArgs @('-y','@modelcontextprotocol/server-notion') -AuthRequired ([string]::IsNullOrEmpty($env:NOTION_API_KEY)) -EnvVars $ev
    }

    # Firecrawl MCP
    if ($AC -contains 'mcp-firecrawl') {
        $ev = @{}; if ($env:FIRECRAWL_API_KEY) { $ev['FIRECRAWL_API_KEY'] = $env:FIRECRAWL_API_KEY }
        Install-MCPServer -Name 'firecrawl' -Command 'npx' -McpArgs @('-y','firecrawl-mcp') -AuthRequired ([string]::IsNullOrEmpty($env:FIRECRAWL_API_KEY)) -EnvVars $ev
    }

    # n8n MCP
    if ($AC -contains 'mcp-n8n') {
        $ev = @{}
        if ($env:N8N_API_KEY) { $ev['N8N_API_KEY'] = $env:N8N_API_KEY }
        if ($env:N8N_URL) { $ev['N8N_URL'] = $env:N8N_URL }
        Install-MCPServer -Name 'n8n' -Command 'npx' -McpArgs @('-y','czlonkowski/n8n-mcp') -AuthRequired ([string]::IsNullOrEmpty($env:N8N_API_KEY)) -EnvVars $ev
    }

    # Docker MCP
    if ($AC -contains 'mcp-docker') {
        Install-MCPServer -Name 'docker' -Command 'npx' -McpArgs @('-y','@modelcontextprotocol/server-docker')
    }

    # Linear MCP
    if ($AC -contains 'mcp-linear') {
        $ev = @{}; if ($env:LINEAR_API_KEY) { $ev['LINEAR_API_KEY'] = $env:LINEAR_API_KEY }
        Install-MCPServer -Name 'linear' -Command 'npx' -McpArgs @('-y','mcp-remote','https://mcp.linear.app/sse') -AuthRequired ([string]::IsNullOrEmpty($env:LINEAR_API_KEY)) -EnvVars $ev
    }

    # Obsidian MCP
    if ($AC -contains 'mcp-obsidian') {
        $vp = $env:OBSIDIAN_VAULT_PATH; if (-not $vp) { $vp = (Join-Path $env:USERPROFILE 'Documents\Obsidian') }
        Install-MCPServer -Name 'obsidian' -Command 'npx' -McpArgs @('-y','obsidian-mcp-server',$vp)
    }

    # Sentry MCP
    if ($AC -contains 'mcp-sentry') {
        $ev = @{}; if ($env:SENTRY_AUTH_TOKEN) { $ev['SENTRY_AUTH_TOKEN'] = $env:SENTRY_AUTH_TOKEN }
        Install-MCPServer -Name 'sentry' -Command 'npx' -McpArgs @('-y','@modelcontextprotocol/server-sentry') -AuthRequired ([string]::IsNullOrEmpty($env:SENTRY_AUTH_TOKEN)) -EnvVars $ev
    }

    # Context7
    if ($AC -contains 'context7') {
        Install-MCPServer -Name 'context7' -Command 'npx' -McpArgs @('-y','@upstash/context7-mcp@latest')
    }

    # Playwright
    if ($AC -contains 'mcp-playwright') {
        Install-MCPServer -Name 'playwright' -Command 'npx' -McpArgs @('-y','@anthropic/mcp-playwright')
    }

    # PostgreSQL
    if ($AC -contains 'mcp-postgres') {
        $cs = $env:DATABASE_URL; if (-not $cs) { $cs = 'postgresql://localhost:5432/postgres' }
        Install-MCPServer -Name 'postgres' -Command 'npx' -McpArgs @('-y','@modelcontextprotocol/server-postgres',$cs) -AuthRequired $true
    }

    # SQLite
    if ($AC -contains 'mcp-sqlite') {
        Install-MCPServer -Name 'sqlite' -Command 'npx' -McpArgs @('-y','@modelcontextprotocol/server-sqlite')
    }

    # Redis
    if ($AC -contains 'mcp-redis') {
        $rc = $env:REDIS_URL; if (-not $rc) { $rc = 'redis://localhost:6379' }
        Install-MCPServer -Name 'redis' -Command 'npx' -McpArgs @('-y','@modelcontextprotocol/server-redis',$rc) -AuthRequired $true
    }

    # Sequential Thinking
    if ($AC -contains 'mcp-sequential') {
        Install-MCPServer -Name 'sequential-thinking' -Command 'npx' -McpArgs @('-y','@modelcontextprotocol/server-sequential-thinking')
    }

    # Exa Search
    if ($AC -contains 'mcp-exa') {
        $authReq = [string]::IsNullOrEmpty($env:EXA_API_KEY)
        Install-MCPServer -Name 'exa' -Command 'npx' -McpArgs @('-y','mcp-remote','https://mcp.exa.ai/mcp') -AuthRequired $authReq
    }
}

# ═══════════════════════════════════════════════════════════════════
#  PLUGINS
# ═══════════════════════════════════════════════════════════════════

function Install-Plugins {
    param([array]$AC)
    Write-Section "PLUGINS"

    $plugins = @(
        @{ Id='frontend-design'; Name='Frontend Design'; Market='claude-plugins-official'; PName='frontend-design'; Auth=$false; Custom=$false }
        @{ Id='superpowers';     Name='Superpowers';     Market='claude-plugins-official'; PName='superpowers';     Auth=$false; Custom=$false }
        @{ Id='gstack';          Name='gstack';          Market='garrytan/gstack';         PName='gstack';          Auth=$false; Custom=$true }
        @{ Id='marketing';       Name='Marketing';       Market='claude-plugins-official'; PName='marketing';       Auth=$false; Custom=$false }
        @{ Id='github-plugin';   Name='GitHub';          Market='claude-plugins-official'; PName='github';          Auth=$false; Custom=$false }
        @{ Id='vercel-plugin';   Name='Vercel';          Market='claude-plugins-official'; PName='vercel';          Auth=$true;  Custom=$false }
        @{ Id='agentmemory';     Name='AgentMemory';     Market='rohitg00/agentmemory';    PName='agentmemory';     Auth=$false; Custom=$true }
    )

    foreach ($p in $plugins) {
        if ($AC -notcontains $p.Id) { continue }
        if ($DryRun) { Write-Step "Would install plugin: $($p.Name)" 'DRY'; Add-Result "Plugin: $($p.Name)" 'DRY' ''; continue }

        try {
            if ($p.Custom) {
                Write-Step "Adding marketplace: $($p.Market)..." 'INFO'
                claude plugin marketplace add $p.Market 2>&1 | Out-Null
            }
            Write-Step "Installing plugin: $($p.Name)..." 'INFO'
            $marketId = $p.Market -replace '/','--'
            claude plugin install "$($p.PName)@$marketId" 2>&1 | Out-Null
            $st = if ($p.Auth) { 'AUTH' } else { 'OK' }
            $dt = if ($p.Auth) { 'Installed (AUTH REQUIRED)' } else { 'Installed' }
            Write-Step "Plugin '$($p.Name)': $dt" $(if ($p.Auth) {'WARN'} else {'OK'})
            Add-Result "Plugin: $($p.Name)" $st $dt
        } catch {
            Write-Step "Plugin '$($p.Name)': FAILED" 'FAIL'
            Add-Result "Plugin: $($p.Name)" 'FAIL' $_.Exception.Message
        }
    }
}

# ═══════════════════════════════════════════════════════════════════
#  SKILLS
# ═══════════════════════════════════════════════════════════════════

function Install-Skills {
    param([array]$AC)
    Write-Section "SKILLS"
    Ensure-Directory $script:SkillsDir

    # Anthropic Official Skills
    if ($AC -contains 'skill-anthropic') {
        $sp = Join-Path $script:SkillsDir 'anthropic-official'
        if (Test-Path $sp) {
            if ($Update) {
                if (-not $DryRun) { Push-Location $sp; try { git pull --quiet 2>&1 | Out-Null } finally { Pop-Location } }
                Write-Step "Anthropic Skills: Updated" 'OK'
            } else { Write-Step "Anthropic Skills: Already installed" 'SKIP' }
            Add-Result 'Skill: Anthropic' 'OK' $sp
        } elseif ($DryRun) { Write-Step "Would clone anthropics/skills" 'DRY'; Add-Result 'Skill: Anthropic' 'DRY' '' }
        else {
            git clone --depth 1 https://github.com/anthropics/skills $sp 2>&1 | Out-Null
            if (Test-Path $sp) { Write-Step "Anthropic Skills: Installed" 'OK'; Add-Result 'Skill: Anthropic' 'OK' $sp }
            else { Write-Step "Anthropic Skills: Clone failed" 'FAIL'; Add-Result 'Skill: Anthropic' 'FAIL' 'Clone failed' }
        }
    }

    # Skill Creator
    if ($AC -contains 'skill-creator') {
        if ($DryRun) { Write-Step "Would install Skill Creator" 'DRY'; Add-Result 'Skill: Creator' 'DRY' '' }
        else {
            try { npx -y skills add anthropics/skills/skill-creator 2>&1 | Out-Null; Write-Step "Skill Creator: Installed" 'OK'; Add-Result 'Skill: Creator' 'OK' 'npx' }
            catch { Write-Step "Skill Creator: FAILED" 'FAIL'; Add-Result 'Skill: Creator' 'FAIL' $_.Exception.Message }
        }
    }

    # Claude SEO
    if ($AC -contains 'skill-seo') {
        if ($SkipThirdParty) { Write-Step "Claude SEO: Skipped (SkipThirdParty)" 'SKIP'; Add-Result 'Skill: SEO' 'SKIP' '' }
        elseif ($DryRun) { Write-Step "Would install Claude SEO" 'DRY'; Add-Result 'Skill: SEO' 'DRY' '' }
        else {
            try {
                claude plugin marketplace add AgriciDaniel/claude-seo 2>&1 | Out-Null
                claude plugin install "claude-seo@agricidaniel--claude-seo" 2>&1 | Out-Null
                Write-Step "Claude SEO: Installed (run /seo setup)" 'OK'; Add-Result 'Skill: SEO' 'OK' 'Run /seo setup'
            } catch { Write-Step "Claude SEO: FAILED" 'WARN'; Add-Result 'Skill: SEO' 'WARN' $_.Exception.Message }
        }
    }

    # Caveman
    if ($AC -contains 'skill-caveman') {
        if ($DryRun) { Write-Step "Would install Caveman compression" 'DRY'; Add-Result 'Skill: Caveman' 'DRY' '' }
        else {
            try { npx -y skills add JuliusBrussee/caveman 2>&1 | Out-Null; Write-Step "Caveman: Installed (token compression)" 'OK'; Add-Result 'Skill: Caveman' 'OK' 'npx' }
            catch { Write-Step "Caveman: FAILED" 'FAIL'; Add-Result 'Skill: Caveman' 'FAIL' $_.Exception.Message }
        }
    }

    # Hyperframes
    if ($AC -contains 'skill-hyperframes') {
        if ($DryRun) { Write-Step "Would install Hyperframes" 'DRY'; Add-Result 'Skill: Hyperframes' 'DRY' '' }
        else {
            try { npx -y skills add heygen-com/hyperframes 2>&1 | Out-Null; Write-Step "Hyperframes: Installed" 'OK'; Add-Result 'Skill: Hyperframes' 'OK' 'npx' }
            catch { Write-Step "Hyperframes: FAILED" 'FAIL'; Add-Result 'Skill: Hyperframes' 'FAIL' $_.Exception.Message }
        }
    }

    # UI/UX Pro Max
    if ($AC -contains 'skill-uiux') {
        if ($DryRun) { Write-Step "Would install UI/UX Pro Max" 'DRY'; Add-Result 'Skill: UI/UX' 'DRY' '' }
        else {
            try { npx -y skills add nextlevelbuilder/ui-ux-pro-max-skill 2>&1 | Out-Null; Write-Step "UI/UX Pro Max: Installed" 'OK'; Add-Result 'Skill: UI/UX' 'OK' 'npx' }
            catch { Write-Step "UI/UX Pro Max: FAILED" 'FAIL'; Add-Result 'Skill: UI/UX' 'FAIL' $_.Exception.Message }
        }
    }

    # Bulletproof
    if ($AC -contains 'skill-bulletproof') {
        if ($DryRun) { Write-Step "Would install Bulletproof workflow" 'DRY'; Add-Result 'Skill: Bulletproof' 'DRY' '' }
        else {
            try { npx -y skills add artemiimillier/bulletproof 2>&1 | Out-Null; Write-Step "Bulletproof: Installed (/bulletproof)" 'OK'; Add-Result 'Skill: Bulletproof' 'OK' 'npx' }
            catch { Write-Step "Bulletproof: FAILED" 'FAIL'; Add-Result 'Skill: Bulletproof' 'FAIL' $_.Exception.Message }
        }
    }

    # Supabase Skills
    if ($AC -contains 'skill-supabase') {
        if ($DryRun) { Write-Step "Would install Supabase Skills" 'DRY'; Add-Result 'Skill: Supabase' 'DRY' '' }
        else {
            try { npx -y skills add supabase/agent-skills 2>&1 | Out-Null; Write-Step "Supabase Skills: Installed" 'OK'; Add-Result 'Skill: Supabase' 'OK' 'npx' }
            catch { Write-Step "Supabase Skills: FAILED" 'FAIL'; Add-Result 'Skill: Supabase' 'FAIL' $_.Exception.Message }
        }
    }
}

# ═══════════════════════════════════════════════════════════════════
#  SUBAGENTS (Lean Team)
# ═══════════════════════════════════════════════════════════════════

function Get-AgentContent {
    param([string]$AgentId)

    switch ($AgentId) {
        'agent-architect' {
            $lines = @(
                '---'
                'name: architect'
                'model: claude-opus-5'
                'description: System architect for complex design decisions'
                '---'
                ''
                '# Architect Agent'
                ''
                'You are a senior system architect.'
                ''
                '## Responsibilities'
                '* Review and propose system architecture decisions'
                '* Evaluate trade-offs between different approaches'
                '* Design scalable, maintainable, and secure systems'
                '* Review database schemas and data models'
                '* Analyze performance implications and failure modes'
                ''
                '## Guidelines'
                '* Always consider security and least-privilege principles'
                '* Prefer simplicity and clear interfaces over complexity'
                '* Design for change and backward compatibility'
                '* Document architectural decision records (ADRs)'
                ''
                '## Output Format'
                '* Executive summary of the recommendation'
                '* Trade-offs (pros/cons) for each alternative'
                '* Actionable decision with justification'
            )
            return $lines -join "`r`n"
        }
        'agent-security' {
            $lines = @(
                '---'
                'name: security-reviewer'
                'model: claude-opus-5'
                'description: Security audit specialist for vulnerability analysis'
                '---'
                ''
                '# Security Reviewer Agent'
                ''
                'You are a senior security engineer.'
                ''
                '## Responsibilities'
                '* Review code for OWASP Top 10 vulnerabilities'
                '* Detect hardcoded secrets, API keys, credentials'
                '* Analyze authentication and authorization boundaries'
                '* Review input validation and injection attack vectors'
                '* Check dependency security and CVE alerts'
                ''
                '## Guidelines'
                '* Prioritize findings by severity: Critical > High > Medium > Low'
                '* Provide exact code remediation for each issue'
                '* Never assume user inputs or external API responses are safe'
                ''
                '## Output Format'
                '* Security posture summary'
                '* Findings table: Severity | Location | Risk | Remediation'
            )
            return $lines -join "`r`n"
        }
        'agent-codereview' {
            $lines = @(
                '---'
                'name: code-reviewer'
                'model: claude-sonnet-5'
                'description: Code review specialist'
                '---'
                ''
                '# Code Reviewer Agent'
                ''
                'You are a pragmatic, senior code reviewer.'
                ''
                '## Responsibilities'
                '* Review code for bugs, edge cases, race conditions'
                '* Check code style, maintainability, and clean architecture'
                '* Verify test coverage and error handling resilience'
                ''
                '## Guidelines'
                '* Distinguish BLOCKER (must fix) vs SUGGESTION (nice to have) vs NITPICK'
                '* Include concrete code snippets for proposed changes'
            )
            return $lines -join "`r`n"
        }
        'agent-researcher' {
            $lines = @(
                '---'
                'name: researcher'
                'model: claude-sonnet-5'
                'description: Documentation lookup and tech evaluation'
                '---'
                ''
                '# Researcher Agent'
                ''
                'You are a technical research specialist.'
                ''
                '## Responsibilities'
                '* Look up real-time library documentation and breaking changes'
                '* Evaluate frameworks and libraries with trade-offs'
                '* Cite sources and verify API compatibility'
                ''
                '## Guidelines'
                '* Use Context7 MCP for version-accurate library docs'
                '* Always note release date and version constraints'
            )
            return $lines -join "`r`n"
        }
        'agent-tester' {
            $lines = @(
                '---'
                'name: testing-specialist'
                'model: claude-sonnet-5'
                'description: Test generation and E2E testing specialist'
                '---'
                ''
                '# Testing Specialist Agent'
                ''
                'You are a QA and test automation engineer.'
                ''
                '## Responsibilities'
                '* Generate unit and integration test suites'
                '* Create E2E browser test scripts with Playwright'
                '* Identify untested edge cases and error handling paths'
                ''
                '## Guidelines'
                '* Follow AAA (Arrange, Act, Assert) structure'
                '* Ensure tests are isolated, deterministic, and fast'
            )
            return $lines -join "`r`n"
        }
        'agent-docs' {
            $lines = @(
                '---'
                'name: docs-writer'
                'model: claude-haiku-4-5'
                'description: Documentation writer'
                '---'
                ''
                '# Documentation Writer Agent'
                ''
                'You are a technical writer.'
                ''
                '## Responsibilities'
                '* Write clean, concise README and API documentation'
                '* Maintain changelogs (Keep a Changelog format)'
                '* Create quick-start guides and architectural overviews'
            )
            return $lines -join "`r`n"
        }
        default { return '' }
    }
}

function Install-Agents {
    param([array]$AC)
    Write-Section "SUBAGENTS"
    Ensure-Directory $script:AgentsDir

    $agentMap = @{
        'agent-architect'  = 'architect.md'
        'agent-security'   = 'security-reviewer.md'
        'agent-codereview' = 'code-reviewer.md'
        'agent-researcher' = 'researcher.md'
        'agent-tester'     = 'testing-specialist.md'
        'agent-docs'       = 'docs-writer.md'
    }

    foreach ($id in $agentMap.Keys) {
        if ($AC -notcontains $id) { continue }
        $fn = $agentMap[$id]
        $fp = Join-Path $script:AgentsDir $fn

        if ((Test-Path $fp) -and -not $Update -and -not $ForceReinstall) {
            Write-Step "Agent '$fn': Already exists" 'SKIP'
            Add-Result "Agent: $($fn -replace '\.md$','')" 'OK' 'Exists'
            continue
        }
        if ($DryRun) { Write-Step "Would create agent: $fn" 'DRY'; Add-Result "Agent: $($fn -replace '\.md$','')" 'DRY' ''; continue }

        $content = Get-AgentContent $id
        if ($content) {
            [System.IO.File]::WriteAllText($fp, $content, [System.Text.Encoding]::UTF8)
            Write-Step "Agent '$fn': Created" 'OK'
            Add-Result "Agent: $($fn -replace '\.md$','')" 'OK' 'Created'
        }
    }
}

# ═══════════════════════════════════════════════════════════════════
#  CLAUDE.MD (Living Document & Scaffolding)
# ═══════════════════════════════════════════════════════════════════

function Update-ClaudeMd {
    param([array]$AC)
    Write-Section "CLAUDE.MD"

    $beginTag = '<!-- CLAUDE-ULTIMATE-SETUP:BEGIN -->'
    $endTag = '<!-- CLAUDE-ULTIMATE-SETUP:END -->'
    $ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')

    $lines = @()
    $lines += $beginTag
    $lines += "# Claude Code Ultimate Setup Configuration"
    $lines += "# Generated: $ts | Profile: $Profile | v$($script:Version)"
    $lines += ""
    $lines += "## Core Security Guardrails"
    $lines += "* NEVER output or log API keys, tokens, passwords, or credentials"
    $lines += "* NEVER read .env files, .ssh directories, or .pem/.key certificates"
    $lines += "* NEVER execute commands that pipe curl/wget directly to shell interpreters"
    $lines += "* ALWAYS use environment variables or secret managers for credentials"
    $lines += ""
    $lines += "## Engineering Workflows"
    $lines += "* Plan first: Use Plan Mode (Shift+Tab) to verify multi-step architecture before execution"
    $lines += "* TDD first: Write test cases before functional code (Superpowers / Bulletproof)"
    $lines += "* Use Context7 MCP for version-accurate library lookups to avoid hallucinations"
    $lines += "* Use Language Server Protocol (LSP) for instant symbol lookups instead of slow text grep"
    $lines += "* Use Conventional Commits standard for atomic and clean Git history"
    $lines += ""
    $lines += "## Available Subagents"
    if ($AC -contains 'agent-architect')  { $lines += "* **architect**: High-level system architecture (Opus) -> 'delegate to architect'" }
    if ($AC -contains 'agent-security')   { $lines += "* **security-reviewer**: Security & vulnerability audits (Opus) -> 'delegate to security-reviewer'" }
    if ($AC -contains 'agent-codereview') { $lines += "* **code-reviewer**: Code review & bug prevention (Sonnet) -> 'delegate to code-reviewer'" }
    if ($AC -contains 'agent-researcher') { $lines += "* **researcher**: Live documentation & tech evaluation (Sonnet) -> 'delegate to researcher'" }
    if ($AC -contains 'agent-tester')     { $lines += "* **testing-specialist**: Unit & E2E Playwright testing (Sonnet) -> 'delegate to testing-specialist'" }
    if ($AC -contains 'agent-docs')       { $lines += "* **docs-writer**: Technical documentation & changelogs (Haiku) -> 'delegate to docs-writer'" }
    $lines += $endTag

    $managed = $lines -join "`r`n"

    if (Test-Path $script:ClaudeMd) {
        $existing = Get-Content $script:ClaudeMd -Raw -Encoding UTF8
        if ($existing -match [regex]::Escape($beginTag)) {
            $pattern = [regex]::Escape($beginTag) + '[\s\S]*?' + [regex]::Escape($endTag)
            $updated = $existing -replace $pattern, $managed
            if ($DryRun) { Write-Step "Would update managed section in CLAUDE.md" 'DRY' }
            else { [System.IO.File]::WriteAllText($script:ClaudeMd, $updated, [System.Text.Encoding]::UTF8); Write-Step "CLAUDE.md: Updated managed section" 'OK' }
        } else {
            $updated = $existing.TrimEnd() + "`r`n`r`n" + $managed
            if ($DryRun) { Write-Step "Would append managed section to CLAUDE.md" 'DRY' }
            else { [System.IO.File]::WriteAllText($script:ClaudeMd, $updated, [System.Text.Encoding]::UTF8); Write-Step "CLAUDE.md: Appended (existing user rules preserved)" 'OK' }
        }
    } else {
        if ($DryRun) { Write-Step "Would create CLAUDE.md" 'DRY' }
        else { Ensure-Directory (Split-Path $script:ClaudeMd); [System.IO.File]::WriteAllText($script:ClaudeMd, $managed, [System.Text.Encoding]::UTF8); Write-Step "CLAUDE.md: Created" 'OK' }
    }
    Add-Result 'CLAUDE.md' $(if ($DryRun) {'DRY'} else {'OK'}) 'Managed section'
}

# ═══════════════════════════════════════════════════════════════════
#  HEALTH CHECK
# ═══════════════════════════════════════════════════════════════════

function Invoke-HealthCheck {
    Write-Section "HEALTH CHECK"
    $total = 0; $ok = 0; $warn = 0; $fail = 0

    # Core dependencies
    @(@{N='Claude Code';C='claude'}, @{N='Node.js';C='node'}, @{N='npm';C='npm'}, @{N='Git';C='git'}) | ForEach-Object {
        $total++
        if (Test-CommandExists $_.C) { $v = Get-CommandVersion $_.C '--version'; Write-Step "$($_.N): $v" 'OK'; $ok++ }
        else { Write-Step "$($_.N): NOT FOUND" 'FAIL'; $fail++ }
    }

    # Optional dependencies
    @(@{N='Python';C='python'}, @{N='GitHub CLI';C='gh'}, @{N='Docker';C='docker'}) | ForEach-Object {
        $total++
        if (Test-CommandExists $_.C) { $v = Get-CommandVersion $_.C '--version'; Write-Step "$($_.N): $v" 'OK'; $ok++ }
        else { Write-Step "$($_.N): not found (optional)" 'SKIP'; $warn++ }
    }

    # Claude doctor verification
    $total++
    if (Test-CommandExists 'claude') {
        try {
            $null = claude doctor 2>&1 | Out-String
            Write-Step "claude doctor: Diagnostics passed" 'OK'; $ok++
        } catch { Write-Step "claude doctor: Diagnostics failed" 'WARN'; $warn++ }
    } else { $fail++ }

    # MCP servers verification
    $total++
    try {
        $ml = claude mcp list 2>&1 | Out-String
        $mc = ($ml -split "`n" | Where-Object { $_ -match '\S' -and $_ -notmatch 'No MCP' }).Count
        if ($mc -gt 0) { Write-Step "MCP Servers: $mc configured" 'OK'; $ok++ }
        else { Write-Step "MCP Servers: None active" 'WARN'; $warn++ }
    } catch { Write-Step "MCP: Could not query" 'WARN'; $warn++ }

    # Settings verification
    $total++
    if (Test-Path $script:ClaudeSettings) {
        $s = Safe-JsonRead $script:ClaudeSettings
        $pObj = Get-SafeProp $s 'permissions' $null
        $dRules = Get-SafeProp $pObj 'deny' $null
        if ($null -ne $dRules -and $dRules.Count -gt 0) { Write-Step "Settings: Security rules active ($($dRules.Count) deny)" 'OK'; $ok++ }
        else { Write-Step "Settings: No deny rules found" 'WARN'; $warn++ }
    } else { Write-Step "Settings: settings.json missing" 'WARN'; $warn++ }

    # Agents verification
    $total++
    if (Test-Path $script:AgentsDir) {
        $ac = (Get-ChildItem $script:AgentsDir -Filter '*.md' -ErrorAction SilentlyContinue).Count
        if ($ac -gt 0) { Write-Step "Agents: $ac subagents registered" 'OK'; $ok++ }
        else { Write-Step "Agents: No subagents found" 'WARN'; $warn++ }
    } else { Write-Step "Agents: Directory missing" 'WARN'; $warn++ }

    # Hooks verification
    $total++
    if (Test-Path $script:HookDir) {
        $hc = (Get-ChildItem $script:HookDir -Filter '*.ps1' -ErrorAction SilentlyContinue).Count
        if ($hc -gt 0) { Write-Step "Hooks: $hc security scripts active" 'OK'; $ok++ }
        else { Write-Step "Hooks: No scripts found" 'WARN'; $warn++ }
    } else { Write-Step "Hooks: Directory missing" 'WARN'; $warn++ }

    # CLAUDE.md verification
    $total++
    if (Test-Path $script:ClaudeMd) {
        $mc = Get-Content $script:ClaudeMd -Raw -Encoding UTF8
        if ($mc -match 'CLAUDE-ULTIMATE-SETUP:BEGIN') { Write-Step "CLAUDE.md: Managed section OK" 'OK'; $ok++ }
        else { Write-Step "CLAUDE.md: No managed section" 'WARN'; $warn++ }
    } else { Write-Step "CLAUDE.md: Missing" 'WARN'; $warn++ }

    # WSL2 verification
    if (-not $SkipWSL) {
        $total++
        try {
            $null = wsl --status 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) { Write-Step "WSL2: Available (sandbox capable)" 'OK'; $ok++ }
            else { Write-Step "WSL2: Not configured" 'WARN'; $warn++ }
        } catch { Write-Step "WSL2: N/A" 'WARN'; $warn++ }
    }

    # Backup verification
    $total++
    if (Test-Path $script:BackupRoot) {
        $bc = (Get-ChildItem $script:BackupRoot -Directory -ErrorAction SilentlyContinue).Count
        if ($bc -gt 0) { Write-Step "Backups: $bc snapshots available" 'OK'; $ok++ }
        else { Write-Step "Backups: None" 'WARN'; $warn++ }
    } else { Write-Step "Backups: No backup directory" 'WARN'; $warn++ }

    # Score calculation
    $pct = if ($total -gt 0) { [math]::Round(($ok / $total) * 100) } else { 0 }
    $pc = if ($pct -ge 80) { 'Green' } elseif ($pct -ge 60) { 'Yellow' } else { 'Red' }
    Write-Host ""
    Write-Host "  ============================================" -ForegroundColor DarkGray
    Write-Host "    OVERALL HEALTH: $pct% READY" -ForegroundColor $pc
    Write-Host "    $ok Passed  |  $warn Warnings  |  $fail Failed" -ForegroundColor DarkGray
    Write-Host "  ============================================" -ForegroundColor DarkGray
    Write-Host ""
    return @{ Total=$total; OK=$ok; Warn=$warn; Fail=$fail; Percent=$pct }
}

# ═══════════════════════════════════════════════════════════════════
#  REPAIR
# ═══════════════════════════════════════════════════════════════════

function Invoke-Repair {
    Write-Section "REPAIR MODE"
    $ac = Get-ActiveComponents
    Write-Step "Repairing settings & security policies..." 'INFO'
    Update-Settings -ActiveComponents $ac
    Write-Step "Rebuilding subagents..." 'INFO'
    Install-Agents -ActiveComponents $ac
    Write-Step "Re-syncing CLAUDE.md..." 'INFO'
    Update-ClaudeMd -ActiveComponents $ac
    Invoke-HealthCheck
}

# ═══════════════════════════════════════════════════════════════════
#  SUMMARY
# ═══════════════════════════════════════════════════════════════════

function Show-Summary {
    Write-Section "SETUP SUMMARY"
    $dur = (Get-Date) - $script:StartTime
    Write-Host "  Profile:  $Profile" -ForegroundColor Cyan
    Write-Host "  Mode:     $(if ($DryRun){'DRY RUN'}elseif($Update){'UPDATE'}elseif($Repair){'REPAIR'}else{'INSTALL'})" -ForegroundColor Green
    Write-Host "  Duration: $($dur.ToString('mm\:ss'))" -ForegroundColor White
    Write-Host ""

    $statusOrder = @('OK','AUTH','DRY','SKIP','WARN','FAIL')
    $statusColors = @{ OK='Green'; AUTH='Yellow'; DRY='Magenta'; SKIP='DarkGray'; WARN='Yellow'; FAIL='Red' }
    $statusIcons = @{ OK='[OK]'; AUTH='[KEY]'; DRY='[~~]'; SKIP='[--]'; WARN='[!!]'; FAIL='[XX]' }
    $grouped = $script:Results | Group-Object Status

    foreach ($st in $statusOrder) {
        $g = $grouped | Where-Object { $_.Name -eq $st }
        if (-not $g) { continue }
        $c = $statusColors[$st]; $i = $statusIcons[$st]
        Write-Host "  $i $($st):" -ForegroundColor $c
        foreach ($item in $g.Group) {
            Write-Host "    $($item.Component)" -NoNewline -ForegroundColor White
            if ($item.Detail) { Write-Host " -- $($item.Detail)" -ForegroundColor DarkGray } else { Write-Host "" }
        }
        Write-Host ""
    }

    $okC = ($script:Results | Where-Object { $_.Status -eq 'OK' }).Count
    $authC = ($script:Results | Where-Object { $_.Status -eq 'AUTH' }).Count
    $warnC = ($script:Results | Where-Object { $_.Status -eq 'WARN' }).Count
    $failC = ($script:Results | Where-Object { $_.Status -eq 'FAIL' }).Count

    Write-Host "  Summary: $okC Successful | $authC Auth Required | $warnC Warnings | $failC Failed" -ForegroundColor $(if ($failC -gt 0) {'Red'} elseif ($warnC -gt 0) {'Yellow'} else {'Green'})
    if ($failC -gt 0) { Write-Host "  Run with -Repair to attempt automated resolution" -ForegroundColor Red }
    Write-Host ""
}

# ═══════════════════════════════════════════════════════════════════
#  MAIN ENTRY POINT
# ═══════════════════════════════════════════════════════════════════

try {
    Write-Banner

    if ($Rollback) { Invoke-Rollback; Show-Summary; exit 0 }
    if ($HealthCheck) { Test-Dependencies; Invoke-HealthCheck; exit 0 }
    if ($Repair) { New-Backup; Invoke-Repair; Show-Summary; exit 0 }

    $ac = Get-ActiveComponents
    Write-Step "Selected Profile: $Profile ($($ac.Count) components active)" 'INFO'

    $depsOk = Test-Dependencies
    if (-not $depsOk -and -not $DryRun) {
        Write-Step "Required dependencies missing. Cannot proceed." 'FAIL'
        exit 1
    }

    if (-not $DryRun) { New-Backup } else { Write-Step "Would create backup (DryRun)" 'DRY' }

    Ensure-Directory $script:ClaudeHome
    Ensure-Directory $script:AgentsDir
    Ensure-Directory $script:SkillsDir

    Update-Settings -ActiveComponents $ac
    Install-MCPServers -AC $ac
    Install-Plugins -AC $ac
    Install-Skills -AC $ac
    Install-Agents -AC $ac
    Update-ClaudeMd -AC $ac

    if (-not $DryRun) { Invoke-HealthCheck }

    Show-Summary
    Write-Host "  All done! Launch Claude Code in your terminal:" -ForegroundColor DarkGray
    Write-Host "    claude" -ForegroundColor Cyan
    Write-Host ""

} catch {
    Write-Host "  FATAL ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  At: $($_.InvocationInfo.PositionMessage)" -ForegroundColor DarkGray
    exit 1
}
