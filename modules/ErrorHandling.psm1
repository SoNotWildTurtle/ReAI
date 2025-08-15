function Invoke-ReAISafely {
    param(
        [Parameter(Mandatory=$true)][scriptblock]$ScriptBlock,
        [string]$Action = 'operation'
    )
    try {
        & $ScriptBlock
    } catch {
        $message = "Error during $Action: $($_.Exception.Message)"
        if (Get-Command Write-ReAILog -ErrorAction SilentlyContinue) {
            Write-ReAILog -Message $message -Level 'ERROR'
        } else {
            Write-Warning $message
        }
        return $null
    }
}

function Set-ReAIErrorHandler {
    $global:ErrorActionPreference = 'Stop'
}

Export-ModuleMember -Function Invoke-ReAISafely,Set-ReAIErrorHandler
