$global:ReahModel = @{}
$global:ReahCorpusPath = Join-Path $PSScriptRoot '../data/reah_corpus.txt'

function Train-ReahModel {
    [CmdletBinding()]
    param([string]$Path = $global:ReahCorpusPath)
    if (-not (Test-Path $Path)) { return }
    $text = Get-Content $Path -Raw
    $words = $text -split '\s+'
    for ($i = 0; $i -lt $words.Length - 1; $i++) {
        $w1 = $words[$i].ToLower()
        $w2 = $words[$i+1].ToLower()
        if (-not $global:ReahModel.ContainsKey($w1)) { $global:ReahModel[$w1] = @() }
        $global:ReahModel[$w1] += $w2
    }
}

function Get-ReahResponse {
    [CmdletBinding()]
    param([string]$Prompt)
    if ($global:ReahModel.Count -eq 0) { Train-ReahModel }
    $seed = ($Prompt -split '\s+')[0].ToLower()
    if (-not $global:ReahModel.ContainsKey($seed)) { $seed = ($global:ReahModel.Keys | Get-Random) }
    $response = @($seed)
    for ($i=0; $i -lt 25; $i++) {
        $last = $response[-1]
        $next = $null
        if ($global:ReahModel.ContainsKey($last)) { $next = $global:ReahModel[$last] | Get-Random }
        if (-not $next) { break }
        $response += $next
    }
    ($response -join ' ').Trim() + '.'
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
