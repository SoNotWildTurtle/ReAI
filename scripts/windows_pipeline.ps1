# Helper script to run the Windows-integrated pipeline
param([switch]$ProtectFiles,[switch]$VerifyIntegrity)
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$script = Join-Path $root '..' 'ReAI.ps1'
& $script -WinPipeline -ProtectFiles:$ProtectFiles -VerifyIntegrity:$VerifyIntegrity

