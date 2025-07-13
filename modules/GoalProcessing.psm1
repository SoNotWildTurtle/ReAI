function Invoke-GoalProcessing {
    param([string]$Goal)
    Write-Host "Iteration $($State.iterations): Goal -> $Goal"
    $plan = Invoke-GPT -Messages @(
        @{role='system'; content='Plan research steps for this goal.'},
        @{role='user';   content=$Goal}
    ) -Max 2000
    $webnotes = (Search-Web $Goal | ForEach-Object { "$($_.title): $(Get-UrlSummary $_.url)" }) -join "`n"
    $code = Invoke-GPT -Messages @(
        @{role='system'; content='Convert plan and research into a runnable PowerShell script.'},
        @{role='user';   content="$plan`n$webnotes"}
    ) -Max 200
    $scriptFile = Join-Path $global:ScriptsDir ([guid]::NewGuid().ToString() + '.ps1')
    Set-Content $scriptFile $code
    if ($IsWindows) {
        Start-Process -FilePath "$PSHOME\powershell.exe" -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',"$scriptFile") -WindowStyle Hidden -Wait
    } else {
        Start-Process -FilePath "$PSHOME/pwsh" -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',"$scriptFile") -Wait
    }
    $reportName = ($Goal -replace '\s','_') + '.md'
    $report  = Join-Path $global:ReportsDir $reportName
    $summary = Invoke-GPT -Messages @(
        @{role='system'; content='Summarize findings and propose next steps.'},
        @{role='user';   content="$plan`n$webnotes"}
    ) -Max 150
    Set-Content $report $summary
    $summaryPath = $report -replace '\.md$', '_summary.txt'
    Save-CompressedText -Text $summary -Path $summaryPath -MaxWords 100 | Out-Null
    $biz = Invoke-GPT -Messages @(
        @{role='system'; content='Generate executive summary: goals, timeline, budget.'},
        @{role='user';   content=$summary}
    ) -Max 1000
    $bizReport = $report -replace '\.md$', '_biz.md'
    Set-Content $bizReport $biz
    Write-Host "Report saved to: $report" -ForegroundColor Green
    Write-Host "Saved summary to $summaryPath" -ForegroundColor Green
    Write-Host "Business summary saved to: $bizReport" -ForegroundColor Green
}

Export-ModuleMember -Function Invoke-GoalProcessing
