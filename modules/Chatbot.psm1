function Start-ReAIChat {
    [CmdletBinding()]
    param(
        [string]$Greeting = 'Hello, I''m Reah. Let''s explore together!'
    )
    Train-ReahModel
    Write-Host $Greeting -ForegroundColor Cyan
    Write-Host "Type 'exit' to quit." -ForegroundColor DarkGray
    while ($true) {
        $input = Read-Host 'You'
        if ($input -eq 'exit') { break }
        Update-ReahCorpus -Line $input
        $reply = Get-ReahResponse -Prompt $input
        Write-Host "Reah: $reply" -ForegroundColor Green
        Update-ReahCorpus -Line $reply
    }
}

Export-ModuleMember -Function Start-ReAIChat
