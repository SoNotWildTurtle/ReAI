function Show-ReAIHelp {
    $helpText = @"
ReAI Usage:
  ./ReAI.ps1 [options]

Common Options:
  -StartService      Start the ReAI Windows service
  -StopService       Stop the service
  -RestartService    Restart the service
  -ServiceStatus     Display current service status
  -ViewLog           Display the log file in this terminal
  -Monitor           Restart service automatically if it stops
  -AddGoal "task"     Add a new goal
  -CompleteGoal "task" Mark a goal complete
  -StartGoal "task"   Mark a goal in progress
  -PauseGoal "task"   Return an in-progress goal to pending
  -ListGoals         List active and completed goals
  -AnalyzeGoals      Generate subgoals automatically
  -ResearchTopic "t"  Produce research report and business plan
  -ProcessGoal "t"    Process a specific goal
  -ProcessAllGoals   Process all active goals
  -EnableSecureMode  Disable network access
  -DisableSecureMode Re-enable network access
  -StartForwarding   Start port forwarding to OpenAI
  -StopForwarding    Stop port forwarding
  -SelfRefactor      Attempt GPT-driven refactor
  -SelfEvolve        Run self-refactor with tests and integrity checks
  -ContextSummary "t" Summarize context from Google results
  -CompressText "t"   Compress provided text
  -SummarizeHistory  Summarize log history
  -AutoPipeline      Run analysis, processing, refactor and summary automatically; combine with -VerifyIntegrity and -ProtectLogs/-ProtectReports for extra safety
  -SaveIntegrity     Save script hash profile
  -VerifyIntegrity   Verify script hashes
  -ProtectLogs       Compress and encrypt the log file
  -ProtectReports    Encrypt existing reports
  -ConfigureTokens   Prompt for missing environment variables
  -Chat              Start local chatbot session
  -RunTests          Execute the test suite
  -Help              Display this help message

Running without options launches the interactive menu.
"@
    Write-Host $helpText
}

Export-ModuleMember -Function Show-ReAIHelp
