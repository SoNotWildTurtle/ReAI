<#
MINC – Professional Self-Evolving Research AI Agent v1.8
- Bulletproofed for PowerShell 5.1, Windows 10+
- No emojis. No pipe/ForEach-Object misuse. All object props robust.
#>

param(
    [switch]$InstallService,
    [switch]$RunTests,
    [switch]$TestAll,
    [switch]$TestPortForwarding,
    [switch]$TestAPI,
    [switch]$TestStateManagement,
    [switch]$StartService,
    [switch]$StopService,
    [switch]$RestartService,
    [switch]$ServiceStatus,
    [switch]$ViewLog,
    [switch]$OpenTerminal,
    [switch]$CloseTerminal,
    [switch]$Monitor,
    [string]$AddGoal,
    [string]$CompleteGoal,
    [string]$RemoveGoal,
    [string]$StartGoal,
    [string]$PauseGoal,
    [switch]$ListGoals,
    [switch]$AnalyzeGoals,
    [string]$ResearchTopic,
    [string]$ProcessGoal,
    [switch]$ProcessAllGoals,
    [switch]$EnableSecureMode,
    [switch]$DisableSecureMode,
    [switch]$StartForwarding,
    [switch]$StopForwarding,
    [switch]$SelfRefactor,
    [switch]$SelfEvolve,
    [string]$ContextSummary,
    [string]$CompressText,
    [switch]$SummarizeHistory,
    [switch]$AutoPipeline,
    [switch]$WinPipeline,
    [switch]$SaveIntegrity,
    [switch]$VerifyIntegrity,
    [switch]$ProtectLogs,
    [switch]$ProtectReports,
    [switch]$ClearCache,
    [string]$ExportConfig,
    [string]$ImportConfig,
    [switch]$ConfigureTokens,
    [switch]$Chat,
    [switch]$ChatGPT,
    [switch]$Help
)

# ===== SCRIPT METADATA =====
# MINC – Professional Self-Evolving Research AI Agent v1.8
# - Enhanced with port forwarding and comprehensive testing
# - Bulletproofed for PowerShell 5.1, Windows 10+
# - No emojis. No pipe/ForEach-Object misuse. All object props robust.
# ===== PLATFORM DETECTION =====
if (-not (Get-Variable -Name IsWindows -Scope Global -ErrorAction SilentlyContinue)) {
    $global:IsWindows = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)
}
$global:Windows10OrHigher = $false
if ($IsWindows) {
    $ver = [Environment]::OSVersion.Version
    if ($ver.Major -ge 10) { $global:Windows10OrHigher = $true }
}


# ===== CONFIGURATION =====
# API and Model Configuration
$global:OpenAIKey = $env:OPENAI_API_KEY
if (-not $global:OpenAIKey) {
    Write-Warning 'OPENAI_API_KEY environment variable not found. API calls will fail.'
    $global:OpenAIKey = ''
}
$global:Model        = "gpt-3.5-turbo"

# Port Forwarding Configuration
$global:PortForwarding = @{
    Enabled    = $false;
    LocalPort  = 8080;
    RemoteHost = "api.openai.com";
    RemotePort = 443
}

# File System Configuration
$global:WorkDir      = $PSScriptRoot
$null = Set-Location $global:WorkDir
$global:StateFile    = Join-Path $global:WorkDir "state.json"
$global:ModulesDir   = Join-Path $global:WorkDir "modules"
$global:ScriptsDir   = Join-Path $global:WorkDir "scripts"
$global:ReportsDir   = Join-Path $global:WorkDir "reports"
$global:ChatLogsDir  = Join-Path $global:WorkDir "chat_logs"
$global:ScriptName   = Split-Path -Leaf $PSCommandPath
$global:ServiceName  = "MINC_ResearchAI"
$global:LogFile      = Join-Path $global:WorkDir "reai.log"
$exe = if (Test-Path (Join-Path $PSHOME 'pwsh')) { Join-Path $PSHOME 'pwsh' } else { Join-Path $PSHOME 'powershell.exe' }
$global:ServicePath = "`"$exe`" -NoProfile -ExecutionPolicy Bypass -File `"$global:WorkDir\$global:ScriptName`""
try { Start-Transcript -Path $global:LogFile -Append -ErrorAction Stop } catch {}


foreach ($dir in @($global:ModulesDir, $global:ScriptsDir, $global:ReportsDir, $global:ChatLogsDir)) {
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
}

# Load persistent state before importing modules so security routines can access it
if (Test-Path $global:StateFile) {
    try {
        $json = Get-Content $global:StateFile -Raw
        $global:State = $json | ConvertFrom-Json
        $global:State = [PSCustomObject]$global:State
    } catch {
        Write-Warning "Failed to parse state file. Starting with defaults."
        $global:State = $null
    }
}

if (-not $global:State) {
    $global:State = [PSCustomObject]@{
        goals      = @(
            "Research quantum mind-uploading",
            "Draft business platform proposal",
            "Virtualization of human brain based on next gen research using any methods",
            "Become a superior research-intelligence with a 'do no harm' mentality"
        )
        inProgress = @()
        completed  = @()
        iterations = 0
        versions   = @()
        secure     = $false
    }
}

if (-not ($global:State.PSObject.Properties.Name -contains 'inProgress')) {
    $global:State | Add-Member -Name inProgress -Value @() -MemberType NoteProperty
}
if (-not ($global:State.PSObject.Properties.Name -contains 'secure')) {
    $global:State | Add-Member -Name secure -Value $false -MemberType NoteProperty
}

# Load any local modules for extended functionality
function Import-AllModules {
    $mods = Get-ChildItem -Path $global:ModulesDir -Filter '*.psm1'
    $logging = $mods | Where-Object { $_.Name -eq 'Logging.psm1' }
    if ($logging) {
        Import-Module $logging.FullName -Force
        Write-Host "Loaded module: $($logging.Name)"
    }
    foreach ($mod in $mods) {
        if ($logging -and $mod.FullName -eq $logging.FullName) { continue }
        try {
            Import-Module $mod.FullName -Force
            Write-ReAILog -Message "Module loaded: $($mod.Name)" -Level 'INFO'
        } catch {
            Write-ReAILog -Message "Module failed to load: $($mod.Name)" -Level 'ERROR'
        }
    }
}

Import-AllModules
if (Get-Command Setup-ReAIEnvironment -ErrorAction SilentlyContinue) {
    Setup-ReAIEnvironment
}
if (Get-Command Initialize-Security -ErrorAction SilentlyContinue) {
    Initialize-Security
} elseif (Test-Path (Join-Path $global:ModulesDir 'IntegrityCheck.psm1')) {
    try { Test-Integrity | Out-Null } catch {}
}
Write-ReAILog -Message "ReAI launched with parameters: $($PSBoundParameters.Keys -join ', ')" -Level 'INFO'

if ($InstallService) {
    if (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue) {
        Write-Host "Removing existing service..."
        sc.exe delete $ServiceName | Out-Null
        Start-Sleep -Seconds 2
    }
    Write-Host "Installing service '$ServiceName'..."
    New-Service -Name $ServiceName `
        -BinaryPathName $ServicePath `
        -DisplayName "MINC Research AI Agent" `
        -StartupType Automatic `
        -Description "Self-evolving autonomous research AI agent"
    Start-Service -Name $ServiceName
    Write-Host "Service installed and started."
    return
}

try { Import-Module PowerHTML -ErrorAction Stop }
catch { Write-Warning 'PowerHTML module not found. Some features may be unavailable.' }


# === CLI Entry Points ===
if ($StartService) { Write-ReAILog -Message 'StartService requested'; Start-ReAIService; return }
if ($StopService) { Write-ReAILog -Message 'StopService requested'; Stop-ReAIService; return }
if ($RestartService) { Write-ReAILog -Message 'RestartService requested'; Restart-ReAIService; return }
if ($ServiceStatus) { Write-ReAILog -Message 'ServiceStatus requested'; $status = Get-ReAIServiceStatus; Write-Host "Service status: $status"; return }
if ($ViewLog) { Write-ReAILog -Message 'ViewLog requested'; View-ReAILog; return }
if ($OpenTerminal) { Write-ReAILog -Message 'OpenTerminal requested'; Open-ReAITerminal; return }
if ($CloseTerminal) { Write-ReAILog -Message 'CloseTerminal requested'; Close-ReAITerminal; return }
if ($Monitor) { Write-ReAILog -Message 'Monitor mode started'; Monitor-ReAI; return }
if ($AddGoal) { Write-ReAILog -Message "AddGoal: $AddGoal"; Add-ReAIGoal -Goal $AddGoal; return }
if ($CompleteGoal) { Write-ReAILog -Message "CompleteGoal: $CompleteGoal"; Complete-ReAIGoal -Goal $CompleteGoal; return }
if ($RemoveGoal) { Write-ReAILog -Message "RemoveGoal: $RemoveGoal"; Remove-ReAIGoal -Goal $RemoveGoal; return }
if ($StartGoal) { Write-ReAILog -Message "StartGoal: $StartGoal"; Start-ReAIGoal -Goal $StartGoal; return }
if ($PauseGoal) { Write-ReAILog -Message "PauseGoal: $PauseGoal"; Pause-ReAIGoal -Goal $PauseGoal; return }
if ($ListGoals) { Write-ReAILog -Message 'ListGoals invoked'; List-ReAIGoals; return }
if ($AnalyzeGoals) { Write-ReAILog -Message 'AnalyzeGoals invoked'; Analyze-ReAIGoals; return }
if ($ResearchTopic) { Write-ReAILog -Message "ResearchTopic: $ResearchTopic"; Invoke-Research -Topic $ResearchTopic; return }
if ($ProcessGoal) { Write-ReAILog -Message "ProcessGoal: $ProcessGoal"; Invoke-GoalProcessing -Goal $ProcessGoal; return }
if ($ProcessAllGoals) { foreach ($g in $State.goals) { Write-ReAILog -Message "Processing goal: $g"; Invoke-GoalProcessing -Goal $g }; return }
if ($EnableSecureMode) { Write-ReAILog -Message 'Enabling secure mode'; Enable-SecureMode; return }
if ($DisableSecureMode) { Write-ReAILog -Message 'Disabling secure mode'; Disable-SecureMode; return }
if ($StartForwarding) { Write-ReAILog -Message 'Start port forwarding'; Start-PortForwarding -LocalPort $PortForwarding.LocalPort -RemoteHost $PortForwarding.RemoteHost -RemotePort $PortForwarding.RemotePort; return }
if ($StopForwarding) { Write-ReAILog -Message 'Stop port forwarding'; Stop-PortForwarding; return }
if ($SelfRefactor) { Write-ReAILog -Message 'Self refactor invoked'; Update-ScriptCode; return }
if ($SelfEvolve) {
    Write-ReAILog -Message 'Self evolve invoked'
    Invoke-SelfEvolution -RunTests:$RunTests -VerifyIntegrity:$VerifyIntegrity
    return
}
if ($ContextSummary) { Write-ReAILog -Message "ContextSummary: $ContextSummary"; Get-CondensedContext -Text $ContextSummary | Write-Output; return }
if ($CompressText) { Write-ReAILog -Message "CompressText invoked"; Compress-Text -Text $CompressText | Write-Output; return }
if ($SummarizeHistory) { Write-ReAILog -Message 'SummarizeHistory invoked'; Summarize-History | Write-Output; return }
if ($AutoPipeline) {
    Write-ReAILog -Message 'AutoPipeline invoked'
    $protect = $ProtectLogs -or $ProtectReports
    Invoke-AutoPipeline -RunTests:$RunTests -VerifyIntegrity:$VerifyIntegrity -ProtectFiles:$protect
    return
}
if ($SaveIntegrity) { Write-ReAILog -Message 'Saving integrity profile'; Save-IntegrityProfile; return }
if ($WinPipeline) {
    Write-ReAILog -Message 'WinPipeline invoked'
    $protect = $ProtectLogs -or $ProtectReports
    Invoke-WindowsPipeline -ProtectFiles:$protect -VerifyIntegrity:$VerifyIntegrity
    return
}
if ($VerifyIntegrity) { Write-ReAILog -Message 'Verifying integrity'; Test-Integrity; return }
if ($ProtectLogs) { Write-ReAILog -Message 'Protecting log file'; Protect-ReAILog; return }
if ($ProtectReports) { Write-ReAILog -Message 'Protecting reports'; Protect-Reports; return }
if ($ClearCache) { Write-ReAILog -Message 'Clearing GPT cache'; Clear-GPTCache; Write-Host 'GPT cache cleared.'; return }
if ($ExportConfig) { Export-ReAIConfig -Path $ExportConfig; return }
if ($ImportConfig) { Import-ReAIConfig -Path $ImportConfig; return }
if ($ConfigureTokens) { Prompt-EnvVariables; return }
if ($ChatGPT) { Start-ReAIChat -UseGPT; return }
if ($Chat) { Start-ReAIChat; return }
if ($Help) { Show-ReAIHelp; return }

if ($RunTests -or $TestAll -or $TestPortForwarding -or $TestAPI -or $TestStateManagement) {
    $params = @{}
    if ($TestAll) { $params.RunAll = $true }
    if ($TestPortForwarding) { $params.TestPortForwarding = $true }
    if ($TestAPI) { $params.TestAPI = $true }
    if ($TestStateManagement) { $params.TestStateManagement = $true }
    if (-not $params) { $params.RunAll = $true }
    Import-Module (Join-Path $global:ModulesDir 'TestSuite.psm1') -Force
    Invoke-TestSuite @params
    return
}


if (-not $PSBoundParameters.Count) {
    Prompt-EnvVariables
    Show-ReAIMenu
}
