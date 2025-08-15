function Invoke-WindowsPipeline {
    [CmdletBinding()]
    param(
        [switch]$ProtectFiles,
        [switch]$VerifyIntegrity
    )
    if (-not $IsWindows) {
        Write-Warning 'Windows pipeline is only supported on Windows.'
        return
    }
    $scriptPath = Join-Path $global:WorkDir $global:ScriptName
    if (-not (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue)) {
        Write-Host "Installing service '$ServiceName'..." -ForegroundColor Cyan
        & $scriptPath -InstallService
    } elseif ((Get-Service -Name $ServiceName).Status -ne 'Running') {
        Start-Service -Name $ServiceName
    }
    Invoke-AutoPipeline -ProtectFiles:$ProtectFiles -VerifyIntegrity:$VerifyIntegrity
}

Export-ModuleMember -Function Invoke-WindowsPipeline
