function Invoke-Research {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$Topic
    )
    Write-Host "Conducting research on: $Topic" -ForegroundColor Cyan
    $ddg = Search-Web -Query $Topic -Engine duckduckgo -Tor
    $google = Search-Web -Query $Topic -Engine google
    $results = $ddg + $google | Sort-Object url -Unique
    $notes = @()
    foreach ($r in $results) {
        Write-Host "Summarizing $($r.url)" -ForegroundColor Yellow
        $summary = Get-UrlSummary $r.url
        if ($summary) { $notes += "# $($r.title)`n$summary" }
    }
    $joined = $notes -join "`n"
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
    $reportPath = Join-Path $ReportsDir "${base}_lab_report.md"
    $articlePath = Join-Path $ReportsDir "${base}_article.md"
    $planPath = Join-Path $ReportsDir "${base}_biz_plan.md"
    Set-Content $reportPath $labReport
    Set-Content $articlePath $article
    Set-Content $planPath $bizPlan
    Write-Host "Saved report to $reportPath" -ForegroundColor Green
    Write-Host "Saved article to $articlePath" -ForegroundColor Green
    Write-Host "Saved business plan to $planPath" -ForegroundColor Green
    Update-ScriptCode | Out-Null
}
Export-ModuleMember -Function Invoke-Research
