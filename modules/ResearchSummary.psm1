function Invoke-Research {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$Topic
    )
    Write-Host "Conducting research on: $Topic" -ForegroundColor Cyan
    $ddg = Search-Web -Query $Topic -Engine duckduckgo -Tor
    $google = Search-Web -Query $Topic -Engine google
    $scholar = Search-Web -Query $Topic -Engine scholar
    $arxiv = Search-Web -Query $Topic -Engine arxiv
    $results = $ddg + $google + $scholar + $arxiv | Sort-Object url -Unique
    $notes = @()
    $ratings = @()
    foreach ($r in $results) {
        Write-Host "Summarizing $($r.url)" -ForegroundColor Yellow
        $summary = Get-UrlSummary $r.url
        if ($summary) {
            $rating = Rate-Information -Text $summary
            $ratings += $rating
            $notes += "### $($r.title)`nURL: $($r.url)`nScore: $($rating.Score) ($($rating.Category))`nReason: $($rating.Reason)`n$summary"
        }
    }
    $avg = if ($ratings) { [Math]::Round(($ratings | Measure-Object -Property Score -Average).Average,2) } else { 0 }
    $breakdown = @(
        "Average Score: $avg",
        "High (>=4): $($ratings | Where-Object Score -ge 4 | Measure-Object | Select-Object -ExpandProperty Count)",
        "Medium (2-3): $($ratings | Where-Object { $_.Score -ge 2 -and $_.Score -lt 4 } | Measure-Object | Select-Object -ExpandProperty Count)",
        "Low (<2): $($ratings | Where-Object Score -lt 2 | Measure-Object | Select-Object -ExpandProperty Count)"
    ) -join "`n"
    $joined = $breakdown + "`n`n" + ($notes -join "`n`n")
    $labReport = Invoke-GPT -Messages @(
        @{role='system'; content='Construct a detailed lab report in markdown with sections: Lab Report Structure, Hypothesis, Background and Theory, Methods and Data Collection, Results and Observations, Discussion, Conclusions and Implications, References and Appendices. Base it on the research notes.'},
        @{role='user'; content=$joined}
    ) -Max 1500
    $article = Invoke-GPT -Messages @(
        @{role='system'; content='Write a creative research article summarizing and expanding upon the following lab report.'},
        @{role='user'; content=$labReport}
    ) -Max 1200
    $bizPlan = Invoke-GPT -Messages @(
        @{role='system'; content='Create a business plan using the research findings. Include objectives, market analysis, strategy and financial outlook.'},
        @{role='user'; content=$labReport}
    ) -Max 1000
    $base = $Topic -replace '\s','_'
    $reportPath = Join-Path $global:ReportsDir "${base}_lab_report.md"
    $articlePath = Join-Path $global:ReportsDir "${base}_article.md"
    $planPath = Join-Path $global:ReportsDir "${base}_biz_plan.md"
    Set-Content $reportPath $labReport
    Set-Content $articlePath $article
    Set-Content $planPath $bizPlan
    Protect-File -Path $reportPath | Out-Null
    Protect-File -Path $articlePath | Out-Null
    Protect-File -Path $planPath | Out-Null
    Write-Host "Saved report to $reportPath" -ForegroundColor Green
    Write-Host "Saved article to $articlePath" -ForegroundColor Green
    Write-Host "Saved business plan to $planPath" -ForegroundColor Green
    Update-ScriptCode | Out-Null
}
Export-ModuleMember -Function Invoke-Research
