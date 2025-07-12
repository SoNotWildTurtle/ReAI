# SecurityManagement.psm1

$Global:SecureMode = $false

function Enable-SecureMode {
    $Global:SecureMode = $true
    Write-Host 'Secure mode enabled. Network operations blocked.' -ForegroundColor Yellow
}

function Disable-SecureMode {
    $Global:SecureMode = $false
    Write-Host 'Secure mode disabled.' -ForegroundColor Yellow
}

function Test-SecureNetworkAccess {
    if ($Global:SecureMode) {
        Write-Warning 'Secure mode active. Network access denied.'
        return $false
    }
    return $true
}

function Ensure-StateProtection {
    param([string]$File = $global:StateFile)
    try {
        if (-not (Test-Path $File)) { return }
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

Export-ModuleMember -Function Enable-SecureMode,Disable-SecureMode,Test-SecureNetworkAccess,Ensure-StateProtection,Test-AdminPrivileges
