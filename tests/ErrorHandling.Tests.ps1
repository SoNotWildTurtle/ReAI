Import-Module "$PSScriptRoot/../modules/Logging.psm1"
Import-Module "$PSScriptRoot/../modules/ErrorHandling.psm1"

Describe 'ErrorHandling module' {
    It 'logs errors and continues' {
        $temp = New-TemporaryFile
        $global:LogFile = $temp
        Invoke-ReAISafely -ScriptBlock { throw 'boom' } -Action 'test'
        $content = Get-Content $temp -Raw
        $content | Should -Match 'Error during test'
        Remove-Item $temp -Force
    }
}
