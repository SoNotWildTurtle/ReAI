function Summarize-History {
    [CmdletBinding()]
    param(
        [string]$File = $global:LogFile,
        [string]$File = $LogFile,
        [int]$MaxWords = 200
    )
    if (-not (Test-Path $File)) {
        Write-Warning "History file not found: $File"
        return ""
    }
    $content = Get-Content $File -Raw -ErrorAction SilentlyContinue
    if (-not $content) { return "" }
    return Compress-Text -Text $content -MaxWords $MaxWords
}
Export-ModuleMember -Function Summarize-History
