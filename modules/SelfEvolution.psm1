function Get-CodeMetrics {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return $null }
    $content = Get-Content $Path -Raw -ErrorAction SilentlyContinue
    $lines = ($content -split "`n").Count
    $functions = ($content | Select-String -Pattern 'function\s+[A-Za-z0-9_-]+' | Measure-Object).Count
    [pscustomobject]@{ File = (Split-Path $Path -Leaf); Lines = $lines; Functions = $functions }
}

function Measure-CodeBase {
    $files = Get-ChildItem -Path $global:WorkDir -Recurse -Include *.ps1,*.psm1
    $results = foreach ($file in $files) { Get-CodeMetrics -Path $file.FullName }
    $results
}

function Invoke-SelfEvolution {
    [CmdletBinding()]
    param([switch]$RunTests,[switch]$VerifyIntegrity)

    Write-ReAILog -Message 'Starting self‑evolution' -Level 'INFO'

    $beforeMetrics = Measure-CodeBase
    $testsBefore   = $true
    if ($RunTests) { $testsBefore = Invoke-TestSuite -RunAll }
    if ($VerifyIntegrity) { Test-Integrity | Out-Null }

    $refactorSuccess = Update-ScriptCode
    if (-not $refactorSuccess) {
        Write-ReAILog -Message 'Self-refactor failed' -Level 'ERROR'
        return $false
    }

    $afterMetrics  = Measure-CodeBase
    $testsAfter    = $true
    if ($RunTests) { $testsAfter = Invoke-TestSuite -RunAll }

    $beforeLines   = ($beforeMetrics | Measure-Object -Property Lines -Sum).Sum
    $afterLines    = ($afterMetrics  | Measure-Object -Property Lines -Sum).Sum
    $beforeFuncs   = ($beforeMetrics | Measure-Object -Property Functions -Sum).Sum
    $afterFuncs    = ($afterMetrics  | Measure-Object -Property Functions -Sum).Sum
    $diffLines     = $afterLines  - $beforeLines
    $diffFuncs     = $afterFuncs - $beforeFuncs

    $evaluation = 'Needs review'
    if ($testsAfter -and $diffFuncs -ge 0) { $evaluation = 'Beneficial' }
    elseif (-not $testsAfter) { $evaluation = 'Failed tests' }

    $report = @(
        'Self-evolution complete.',
        "Lines before:  $beforeLines",
        "Lines after:   $afterLines",
        "Functions before: $beforeFuncs",
        "Functions after:  $afterFuncs",
        "Evaluation: $evaluation"
    ) -join "`n"

    Write-ReAILog -Message $report -Level 'INFO'

    return [pscustomobject]@{
        Success       = $refactorSuccess
        Evaluation    = $evaluation
        LinesDiff     = $diffLines
        FunctionsDiff = $diffFuncs
    }
}

Export-ModuleMember -Function Get-CodeMetrics,Measure-CodeBase,Invoke-SelfEvolution
