function Update-ScriptCode {
    try {
        $scriptPath = if ($MyInvocation.MyCommand.Path) { $MyInvocation.MyCommand.Path } else { $PSCommandPath }
        if (-not $scriptPath) { Write-Warning "Cannot determine script path. Self-refactoring skipped."; return $false }
        $src = Get-Content -Path $scriptPath -Raw -ErrorAction Stop
        $testResponse = Invoke-GPT -Messages @(
            @{role='system'; content='You are a helpful assistant.'},
            @{role='user'; content='Say "test"'}
        ) -Max 10
        if (-not $testResponse) { Write-Warning "API call failed. Check your API key and quota. Self-refactoring skipped."; return $false }
        $new = Invoke-GPT -Messages @(
            @{role='system'; content='Refactor for modularity, add restart loop, dynamic modules; tag MINC_MUTATION.'},
            @{role='user';   content=$src}
        ) -Max 200
        if (-not $new) { Write-Warning "Failed to generate new script content. Self-refactoring aborted."; return $false }
        $ver = $State.iterations + 1
        $file = $scriptPath -replace '\.ps1$', "_v$ver.ps1"
        Set-Content -Path $file -Value $new -Force
        Write-Host "Self-refactor version saved: $file"
        $State.versions += $file
        return $true
    } catch {
        Write-Warning "Error during self-refactoring: $_"
        return $false
    }
}

Export-ModuleMember -Function Update-ScriptCode