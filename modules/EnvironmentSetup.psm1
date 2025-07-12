function Prompt-EnvVariables {
    param(
        [string[]]$Variables = @('OPENAI_API_KEY')
    )
    foreach ($var in $Variables) {
        $current = [Environment]::GetEnvironmentVariable($var, 'Process')
        if ([string]::IsNullOrWhiteSpace($current)) {
            $value = Read-Host "Enter value for $var (leave blank to skip)"
            if ($value) {
                $env:$var = $value
                [Environment]::SetEnvironmentVariable($var, $value, 'Process')
                if ($var -eq 'OPENAI_API_KEY') { $global:OpenAIKey = $value }
            }
        }
    }
}

Export-ModuleMember -Function Prompt-EnvVariables

