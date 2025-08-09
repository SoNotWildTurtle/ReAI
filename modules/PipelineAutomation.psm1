function Invoke-AutoPipeline {
    [CmdletBinding()]
    param(
        [switch]$RunTests,
        [switch]$VerifyIntegrity,
        [switch]$ProtectFiles
    )

    Write-Host "Starting automated pipeline..." -ForegroundColor Cyan

    if ($VerifyIntegrity) {
        try {
            Test-Integrity | Out-Null
        } catch {
            Write-Warning "Integrity verification failed: $($_.Exception.Message)"
        }
    }

    Analyze-ReAIGoals

    foreach ($goal in $State.goals) {
        Invoke-GoalProcessing -Goal $goal
    }

    if ($RunTests) {
        Import-Module (Join-Path $PSScriptRoot 'TestSuite.psm1') -Force
        Invoke-TestSuite -RunAll
    }

    Invoke-SelfEvolution -RunTests:$false -VerifyIntegrity:$VerifyIntegrity | Out-Null
    Summarize-History | Out-Null
    Save-State

    if ($ProtectFiles) {
        Protect-ReAILog
        Protect-Reports
    }

    if ($VerifyIntegrity) {
        Save-IntegrityProfile
    }

    Write-Host "Pipeline complete." -ForegroundColor Green
}

Export-ModuleMember -Function Invoke-AutoPipeline
