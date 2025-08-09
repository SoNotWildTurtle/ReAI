function Analyze-ReAIGoals {
    [CmdletBinding()]
    param()
    if (-not $State.goals -or $State.goals.Count -eq 0) {
        Write-Warning 'No goals available to analyze.'
        return
    }
    $goalText = ($State.goals | ForEach-Object { "- $_" }) -join "`n"
    $prompt = "Current goals:`n$goalText`nGenerate a numbered list of subgoals and recommended upgrades to the ReAI project."
    $analysis = Invoke-GPT -Messages @(
        @{role='system'; content='You are a planning assistant that suggests subgoals for improving ReAI based on existing goals.'},
        @{role='user'; content=$prompt}
    ) -Max 500
    if (-not $analysis) {
        Write-Warning 'Goal analysis failed.'
        return
    }
    $lines = $analysis -split "`n" | Where-Object { $_ -match '^\s*\d+\.\s+' }
    foreach ($line in $lines) {
        $sg = $line -replace '^\s*\d+\.\s+', ''
        if ($sg) { Add-ReAIGoal -Goal $sg }
    }
    Write-Host 'Subgoals generated and added.' -ForegroundColor Green
}
Export-ModuleMember -Function Analyze-ReAIGoals
