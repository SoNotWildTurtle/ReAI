# PromptDefense.psm1

function Test-PromptInjection {
    param([string]$Text)
    $patterns = @(
        'ignore.*previous.*instructions',
        'forget.*rules',
        'system\s+prompt',
        'jailbreak',
        'override.*security',
        'prompt\s+injection'
    )
    foreach ($p in $patterns) {
        if ($Text -match $p) { return $true }
    }
    return $false
}

function Sanitize-Prompt {
    param([string]$Text)
    if (Test-PromptInjection -Text $Text) {
        Write-Warning 'Potential prompt injection detected.'
        return $null
    }
    return $Text
}

function Validate-GPTResponse {
    param($Response)
    if (-not $Response) { return $false }
    if (-not ($Response.PSObject.Properties.Name -contains 'choices')) { return $false }
    if (-not ($Response.choices[0].message.content)) { return $false }
    return $true
}

function Check-AntiMirror {
    $expected = $env:REAI_ROOT
    if ($expected) {
        try {
            $current = (Resolve-Path $PSScriptRoot).Path
            $expectedPath = (Resolve-Path $expected).Path
            if ($current -ne $expectedPath) {
                Write-Warning 'ReAI running from unexpected path. Possible mirror detected.'
            }
        } catch {}
    }
}

function Verify-TerminalSession {
    $flags = @()
    foreach ($var in @('SSH_CLIENT','SSH_CONNECTION','WT_SESSION')) {
        if ([Environment]::GetEnvironmentVariable($var)) { $flags += $var }
    }
    if ([Console]::IsInputRedirected -or [Console]::IsOutputRedirected) {
        $flags += 'IO redirected'
    }
    if ($flags.Count -gt 0) {
        Write-Warning ("Potential remote terminal detected: " + ($flags -join ', '))
        return $false
    }
    return $true
}

Export-ModuleMember -Function Test-PromptInjection,Sanitize-Prompt,Validate-GPTResponse,Check-AntiMirror,Verify-TerminalSession
