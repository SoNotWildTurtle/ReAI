# Helper script to run the Windows-integrated pipeline
param([switch]$ProtectFiles,[switch]$VerifyIntegrity)
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptPath = Join-Path (Join-Path $root '..') 'ReAI.ps1'
& $scriptPath -WinPipeline -ProtectFiles:$ProtectFiles -VerifyIntegrity:$VerifyIntegrity

