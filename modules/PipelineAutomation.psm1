function Invoke-AutoPipeline {
    [CmdletBinding()]
    param([switch]$RunTests)
    Write-Host "Starting automated pipeline..." -ForegroundColor Cyan
    Analyze-ReAIGoals
    foreach ($goal in $State.goals) {
        Invoke-GoalProcessing -Goal $goal
    }
    if ($RunTests) {
        Import-Module (Join-Path $PSScriptRoot 'TestSuite.psm1') -Force
        Invoke-TestSuite -RunAll
    }
    Update-ScriptCode | Out-Null
    Summarize-History | Out-Null
    Save-State
    Write-Host "Pipeline complete." -ForegroundColor Green
}
Export-ModuleMember -Function Invoke-AutoPipeline
