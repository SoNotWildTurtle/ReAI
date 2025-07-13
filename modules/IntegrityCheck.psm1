function Get-FileHashHex {
    param([string]$Path)
    try {
        return (Get-FileHash -Algorithm SHA256 -Path $Path).Hash
    } catch {
        Write-Warning "Failed to hash ${Path}: $_"
        return $null
    }
}

function Save-IntegrityProfile {
    $files = @(
        (Join-Path $global:WorkDir 'ReAI.ps1'),
        (Get-ChildItem -Path $global:ModulesDir -Filter '*.psm1' -File | ForEach-Object { $_.FullName })
    )
    $profile = @{}
    foreach ($f in $files) {
        $hash = Get-FileHashHex -Path $f
        if ($hash) { $profile[$f] = $hash }
    }
    $profile | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $global:WorkDir 'integrity.json')
    Write-Host 'Integrity profile saved.'
}

function Test-Integrity {
    $file = Join-Path $global:WorkDir 'integrity.json'
    if (-not (Test-Path $file)) { Write-Warning 'Integrity profile not found. Run Save-IntegrityProfile.'; return $false }
    $known = Get-Content $file | ConvertFrom-Json
    $ok = $true
    foreach ($k in $known.PSObject.Properties.Name) {
        $current = Get-FileHashHex -Path $k
        if ($current -ne $known.$k) {
            Write-Warning "Integrity check failed for $k"
            $ok = $false
        }
    }
    if ($ok) { Write-Host 'Integrity verified.' -ForegroundColor Green }
    return $ok
}

Export-ModuleMember -Function Save-IntegrityProfile,Test-Integrity
