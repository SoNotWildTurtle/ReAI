Import-Module "$PSScriptRoot/../modules/Logging.psm1"

Describe 'Logging module' {
    It 'writes messages to the log file' {
        $temp = New-TemporaryFile
        $global:LogFile = $temp
        Write-ReAILog -Message 'test entry'
        $content = Get-Content $temp -Raw
        $content | Should -Match 'test entry'
        Remove-Item $temp -Force
    }
}
