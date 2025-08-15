function Manage-Research {
    [CmdletBinding()]
    param()
    $summaries = Get-ChildItem -Path $global:ReportsDir -Filter '*_summary.txt' -ErrorAction SilentlyContinue
    if (-not $summaries) {
        Write-Host 'No research summaries found.' -ForegroundColor Yellow
        return
    }
    $topics = foreach ($s in $summaries) {
        $topic = ($s.BaseName -replace '_summary$','') -replace '_',' '
        $content = Get-Content $s.FullName -Raw
        [PSCustomObject]@{Topic=$topic; Summary=$content}
    }
    Write-Host 'Existing research topics:' -ForegroundColor Cyan
    foreach ($t in $topics) { Write-Host "- $($t.Topic)" }
    $topicsList = ($topics | Select-Object -ExpandProperty Topic) -join ', '
    $suggest = Invoke-GPT -Messages @(
        @{role='system'; content='Given a list of completed research topics, suggest up to three follow-up areas that would extend this work and highlight gaps.'},
        @{role='user'; content=$topicsList}
    ) -Max 300
    Write-Host 'Suggested research gaps:' -ForegroundColor Green
    $lines = $suggest -split "`n" | Where-Object { $_ -match '\w' }
    foreach ($line in $lines) {
        Write-Host "* $line"
        try { Add-ReAIGoal -Goal $line } catch {}
    }
    Save-CompressedResearchContext | Out-Null
}

function Save-CompressedResearchContext {
    [CmdletBinding()]
    param([int]$MaxWords = 500)
    $summaries = Get-ChildItem -Path $global:ReportsDir -Filter '*_summary.txt' -ErrorAction SilentlyContinue
    if (-not $summaries) { return }
    $content = foreach ($s in $summaries) { Get-Content $s.FullName -Raw }
    $joined = $content -join "`n`n"
    $path = Join-Path $global:ReportsDir 'compressed_context.txt'
    Save-CompressedText -Text $joined -Path $path -MaxWords $MaxWords | Out-Null
    return $path
}

Export-ModuleMember -Function Manage-Research,Save-CompressedResearchContext
