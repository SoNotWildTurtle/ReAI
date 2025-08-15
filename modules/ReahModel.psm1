$global:ReahModel = @{}
$global:ReahCorpusPath = if ($global:ReahCorpusPath) { $global:ReahCorpusPath } else { Join-Path $PSScriptRoot '../data/reah_corpus.txt' }
$dir = Split-Path $global:ReahCorpusPath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
if (-not (Test-Path $global:ReahCorpusPath)) { New-Item -ItemType File -Path $global:ReahCorpusPath | Out-Null }

function Train-ReahModel {
    [CmdletBinding()]
    param([string]$Path = $global:ReahCorpusPath)
    if (-not (Test-Path $Path)) { return }
    $text  = Get-Content $Path -Raw
    $words = $text -split '\s+'
    for ($i = 0; $i -lt $words.Length - 2; $i++) {
        $w1 = $words[$i].ToLower()
        $w2 = $words[$i+1].ToLower()
        $w3 = $words[$i+2].ToLower()
        $key = "$w1 $w2"
        if (-not $global:ReahModel.ContainsKey($key)) { $global:ReahModel[$key] = @() }
        $global:ReahModel[$key] += $w3
    }
}

function Get-ReahResponse {
    [CmdletBinding()]
    param([string]$Prompt)
    if ($global:ReahModel.Count -eq 0) { Train-ReahModel }
    $words = $Prompt -split '\s+'
    if ($words.Length -ge 2) {
        $seed = "$($words[-2].ToLower()) $($words[-1].ToLower())"
    } else {
        $seed = ($global:ReahModel.Keys | Get-Random)
    }
    if (-not $global:ReahModel.ContainsKey($seed)) { $seed = ($global:ReahModel.Keys | Get-Random) }
    $response = @($seed -split ' ')
    for ($i = 0; $i -lt 25; $i++) {
        $key = "$($response[-2]) $($response[-1])"
        $next = $null
        if ($global:ReahModel.ContainsKey($key)) { $next = $global:ReahModel[$key] | Get-Random }
        if (-not $next) { break }
        $response += $next
    }
    $text = ($response -join ' ').Trim()
    $text = $text.Substring(0,1).ToUpper() + $text.Substring(1)
    if (-not $text.EndsWith('.')) { $text += '.' }
    $text
}

function Update-ReahCorpus {
    param([string]$Line)
    if (-not $Line) { return }
    Add-Content -Path $global:ReahCorpusPath -Value $Line
}

function Import-ReahCorpus {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return }
    Get-Content $Path | ForEach-Object { Update-ReahCorpus -Line $_ }
    Train-ReahModel
}

function Reset-ReahModel {
    $global:ReahModel = @{}
    if (Test-Path $global:ReahCorpusPath) { Remove-Item $global:ReahCorpusPath }
}

Export-ModuleMember -Function Train-ReahModel,Get-ReahResponse,Update-ReahCorpus,Import-ReahCorpus,Reset-ReahModel

