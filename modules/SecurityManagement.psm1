# SecurityManagement.psm1

$Global:SecureMode = $false

function Set-SecureMode {
    param([bool]$Enabled)
    $Global:SecureMode = $Enabled
    if ($global:State -and $global:State.PSObject.Properties.Name -contains 'secure') {
        $global:State.secure = $Enabled
    }
    if ($Enabled) {
        Write-Host 'Secure mode enabled. Network operations blocked.' -ForegroundColor Yellow
        if (Get-Command Protect-ReAILog -ErrorAction SilentlyContinue) { Protect-ReAILog }
        if (Get-Command Protect-Reports -ErrorAction SilentlyContinue) { Protect-Reports }
        if (Get-Command Test-Integrity -ErrorAction SilentlyContinue) { Test-Integrity | Out-Null }
    } else {
        Write-Host 'Secure mode disabled.' -ForegroundColor Yellow
    }
}

function Enable-SecureMode { Set-SecureMode -Enabled:$true }

function Disable-SecureMode { Set-SecureMode -Enabled:$false }

function Test-SecureNetworkAccess {
    if ($Global:SecureMode) {
        Write-Warning 'Secure mode active. Network access denied.'
        return $false
    }
    return $true
}

function Ensure-StateProtection {
    param([string]$File = $global:StateFile)
    if (-not $IsWindows) { return }
    try {
        if (-not (Test-Path $File)) { return }
        Import-Module Microsoft.PowerShell.Security -ErrorAction SilentlyContinue
        $acl = Get-Acl $File
        $user = [System.Security.Principal.NTAccount]::new($env:USERNAME)
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($user,'FullControl','Allow')
        $acl.SetAccessRuleProtection($true,$false)
        $acl.SetAccessRule($rule)
        Set-Acl -Path $File -AclObject $acl
    } catch { Write-Warning "Failed to secure state file: $_" }
}

function Test-AdminPrivileges {
    try {
        $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [System.Security.Principal.WindowsPrincipal]::new($identity)
        return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch { return $false }
}

function Initialize-Security {
    Ensure-StateProtection
    if (-not $global:State.PSObject.Properties.Name -contains 'secure') {
        $global:State | Add-Member -Name secure -Value $false -MemberType NoteProperty
    }
    if ($global:State.secure) { Set-SecureMode -Enabled:$true }
    elseif ($env:REAI_SECURE_MODE -eq '1') { Set-SecureMode -Enabled:$true }
    else { $Global:SecureMode = $false }
}

Export-ModuleMember -Function Enable-SecureMode,Disable-SecureMode,Set-SecureMode,Test-SecureNetworkAccess,Ensure-StateProtection,Test-AdminPrivileges,Initialize-Security
