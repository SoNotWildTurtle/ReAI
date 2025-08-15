function List-ResearchTopics {
    [CmdletBinding()]
    param()
    $files = Get-ChildItem -Path $global:ReportsDir -Filter '*_sources.json' -ErrorAction SilentlyContinue
    if (-not $files) {
        Write-Host 'No research topics found.' -ForegroundColor Yellow
        return
    }
    foreach ($f in $files) {
        $topic = ($f.BaseName -replace '_sources$','') -replace '_',' '
        Write-Host "- $topic"
    }
}

function Show-ResearchSources {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$Topic
    )
    $base = $Topic -replace '\s','_'
    $path = Join-Path $global:ReportsDir "${base}_sources.json"
    if (-not (Test-Path $path)) {
        Write-Host 'No sources saved for that topic.' -ForegroundColor Yellow
        return
    }
    $data = Get-Content $path -Raw | ConvertFrom-Json
    $avg = [Math]::Round((($data | Measure-Object -Property Score -Average).Average),2)
    Write-Host "Average Score: $avg" -ForegroundColor Cyan
    foreach ($s in $data) {
        Write-Host "- $($s.Title) [$($s.Score) $($s.Category)] - $($s.Url)" -ForegroundColor Green
    }
}

Export-ModuleMember -Function List-ResearchTopics,Show-ResearchSources
