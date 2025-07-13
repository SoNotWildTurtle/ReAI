# ReAI

ReAI is a PowerShell-based research assistant designed for experimentation with self-evolving scripts and service management.

## Setup
1. Run `scripts/install_and_start.ps1` to install dependencies, configure tokens, install the service and open the terminal automatically.
2. Use `scripts/windows_pipeline.ps1` to run the integrated Windows pipeline after setup.
3. Windows service features require Windows 10 or later.
4. Alternatively on Codex or other Linux environments run `scripts/codex_setup.sh` to install PowerShell and project dependencies.
5. On Windows you may run `scripts/setup.ps1` directly to install required PowerShell modules and create runtime directories.
6. Set an `OPENAI_API_KEY` environment variable with your OpenAI key or run `./ReAI.ps1 -ConfigureTokens` to enter it interactively.
7. Optionally set `REAI_ENC_KEY` with a Base64 AES key for file encryption. If not set, the first run generates a key, saves it to `enc_key.txt`, and sets the environment variable automatically.
8. Optionally set `OPENAI_MAX_RPM` to your OpenAI account's request-per-minute limit. The script waits `240 / OPENAI_MAX_RPM` seconds between calls (or 60 seconds for `gpt-4o`). You can override the interval directly using `OPENAI_RATE_LIMIT`.
9. Execute `./ReAI.ps1 -InstallService` to install the Windows service (Windows 10+ only).
   The service starts `ReAI.ps1` with no arguments so the interactive menu appears in its terminal window. On non-Windows systems use the script directly instead of the service.

## Runtime Controls
 - `-StartService` / `-StopService` / `-RestartService` – manage the background Windows service (Windows 10+ only)
- `-ServiceStatus` – show current service status
- `-Terminal` – open a log-tail terminal for persistent I/O
- `-CloseTerminal` – close the log-tail terminal if open
- `-Monitor` – monitor the service, restart if it stops and reopen the terminal
- `-AddGoal "task"` – add a new research goal
- `-CompleteGoal "task"` – mark a goal as finished
- `-RemoveGoal "task"` – delete a goal without completing it
- `-StartGoal "task"` – move a goal to the in-progress list
- `-PauseGoal "task"` – return an in-progress goal to pending
- `-ListGoals` – display current and completed goals
- `-AnalyzeGoals` – generate subgoals and improvements automatically
- `-ResearchTopic "subject"` – generate a research report and business plan
- `-ProcessGoal "task"` – run goal processing workflow for a specific goal
- `-ProcessAllGoals` – process each active goal sequentially
- `-EnableSecureMode` / `-DisableSecureMode` – toggle network-blocking secure mode
- `-StartForwarding` / `-StopForwarding` – start or stop local port forwarding to the OpenAI API
- `-SelfRefactor` – attempt GPT-driven self refactor of the main script
- `-SelfEvolve` – run self-refactor with tests, integrity checks and an
  evaluation comparing code metrics before and after
- `-ContextSummary "text"` – fetch Google results for the text and return a condensed summary
- `-CompressText "text"` – compress a block of text into a short summary
- `-SummarizeHistory` – compress the log file into a short history summary
- `-AutoPipeline` – run goal analysis, process all goals, self-refactor and summarize history automatically. Combine with `-VerifyIntegrity` to check hashes and `-ProtectLogs`/`-ProtectReports` to secure output files.
- `-WinPipeline` – run the automated pipeline with Windows service integration
- `-RunTests` with optional `-TestAll`, `-TestPortForwarding`, `-TestAPI`, `-TestStateManagement` – execute Pester-based tests
- `-SaveIntegrity` – record current script hashes to `integrity.json`
- `-VerifyIntegrity` – check script hashes to detect tampering
- `-ProtectLogs` – compress and encrypt the log file
- `-ProtectReports` – compress and encrypt all markdown reports
- `-ConfigureTokens` – interactively set environment variables like API keys
 - `-Chat` – open an interactive chatbot session powered by the local Reah model
 - `-ChatGPT` – chat using OpenAI responses instead of the local model
 - `-Help` – display built-in usage information

### Command Reference

| Command | Description |
|---------|-------------|
| `-StartService` / `-StopService` / `-RestartService` | Manage the background Windows 10+ service (Windows 10+ only) |
| `-ServiceStatus` | Display current service status |
| `-Terminal` / `-CloseTerminal` | Open or close the persistent log terminal |
| `-Monitor` | Restart the service automatically if it stops and reopen the terminal |
| `-AddGoal` / `-CompleteGoal` / `-RemoveGoal` / `-StartGoal` / `-PauseGoal` | Add, finish, delete or update goal status |
| `-ListGoals` | Show active and completed goals |
| `-AnalyzeGoals` | Generate new subgoals using GPT |
| `-ResearchTopic` | Produce a research report and business plan |
| `-ProcessGoal` / `-ProcessAllGoals` | Run the research pipeline for one or all goals |
| `-EnableSecureMode` / `-DisableSecureMode` | Toggle network blocking secure mode |
| `-StartForwarding` / `-StopForwarding` | Proxy OpenAI traffic through a local port |
| `-SelfRefactor` | Attempt a GPT-driven self refactor of the codebase |
| `-SelfEvolve` | Run self refactor with tests, integrity checks and code quality evaluation |
| `-ContextSummary` | Condense Google results for quick context |
| `-CompressText` | Summarize provided text to reduce tokens |
| `-SummarizeHistory` | Compress the log file into a short history summary |
| `-AutoPipeline` | Analyze goals, process them, refactor and summarize in one step |
| `-WinPipeline` | Run the automated pipeline with Windows service integration |
| `-RunTests` | Execute the automated test suite |
| `-SaveIntegrity` / `-VerifyIntegrity` | Manage SHA256 integrity profiles |
| `-ProtectLogs` / `-ProtectReports` | Compress and encrypt output files |
| `-ConfigureTokens` | Prompt for any missing environment variables |
| `-Chat` | Open the local Reah chatbot session |
| `-ChatGPT` | Chat with Reah using OpenAI responses |
| `-Help` | Display this help information |

Running `./ReAI.ps1` with no parameters launches an interactive text menu. The menu shows a stylized ASCII **Reah** banner of alien-like letters and groups commands by task category with a short description of each option. The screen clears and the banner is redrawn on each loop for a consistent look. Warning or info messages appear in bordered boxes for better visibility. If no goals are present a yellow box states **"No current goals"**. It also prompts for any missing environment variables such as `OPENAI_API_KEY`.
From the menu you can manage the service, handle goals—including starting or pausing them—perform research, control network features and run development commands.
You can also chat with Reah in a loop that learns from previous conversations to produce increasingly unique replies.

During research, each information source is rated for reliability using GPT to help prioritize trustworthy data. The research summary includes an average reliability score and a breakdown of high, medium and low rated sources. Self-evolution now runs the full test suite before and after refactoring and logs whether the mutation is beneficial or needs review.
Compressed summaries of generated reports are stored as `*_summary.txt` next to the full encrypted files so Reah can recall key points without loading the entire document.
GPT requests are throttled automatically. `OPENAI_MAX_RPM` determines the wait time (`240 / OPENAI_MAX_RPM` seconds, or 60s for `gpt-4o`). `OPENAI_RATE_LIMIT` overrides with an explicit interval. When the API key is missing or network access is disabled, context and text summaries use local fallback processing instead of GPT.

All state is stored in `state.json` in the project directory.
The file is secured with restrictive permissions when first loaded.
Secure mode disables network access for safer experimentation. When enabled it automatically encrypts logs and reports and runs an integrity check.
Integrity checks verify script hashes to ensure the pipeline has not been tampered with. `Initialize-Security` runs at startup to protect the state file and apply the secure mode stored in `state.json`. On non-Windows systems the state file protection step is skipped.
Set the `OPENAI_API_KEY` environment variable so modules can authenticate with OpenAI.

## Directory Layout
- `ReAI.ps1` – main entry script. Loads all modules from `modules/` and exposes CLI commands. Called directly or by the Windows service. It invokes functions from the modules depending on CLI options or launches the menu by default.
- `modules/` – PowerShell modules containing most functionality. Each module is imported by `ReAI` using `Import-AllModules`.
- `scripts/` – helper utilities such as `setup.ps1` for Windows, `codex_setup.sh` for Linux, and `install_and_start.ps1` and `windows_pipeline.ps1` for one-step installation.
 - `reports/` – generated goal reports and business summaries.
 - `notes/` – development notes, goals list and private notes.
 - `data/` – text corpus used to train the local Reah chatbot model.
 - `chat_logs/` – saved transcripts from interactive chatbot sessions.
 - `enc_key.txt` – generated AES key if `REAI_ENC_KEY` is not set.

## Modules
Each module lives under `modules/` and is imported by the main script.

| Module | Purpose | Called From | Calls |
| ------ | ------- | ----------- | ----- |
| `GoalManagement.psm1` | Manage goals with add, start, pause, complete, remove and list commands. | `ReAI` CLI | `Save-State` from `StateManagement.psm1` |
| `ServiceManagement.psm1` | Start/stop/restart the Windows service (Windows 10+ only), check status and manage a log-tail terminal with cross-platform detection. | `ReAI` CLI | Windows `Start-Service`, `Stop-Service`, `Get-Service` |
| `StateManagement.psm1` | Persist `$State` object to disk. | `GoalManagement.psm1`, others | none |
| `OpenAIUtils.psm1` | OpenAI helpers with DuckDuckGo (Tor), Google, Google Scholar and arXiv search plus request throttling via `Set-GPTRateLimit`. Uses `Invoke-RestMethod` and falls back to `curl.exe` when Tor proxies are requested. | `GoalProcessing.psm1`, `SelfRefactor.psm1`, `ResearchSummary.psm1`, tests | `Invoke-RestMethod`, `curl.exe`, `ConvertFrom-Html` |
| `GoalProcessing.psm1` | Generates research scripts and reports for a goal. | `ReAI` when `-ProcessGoal` or `-ProcessAllGoals` is used | `Invoke-GPT`, `Search-Web`, `Get-UrlSummary` |
| `PortForwarding.psm1` | Local port forwarding helpers to proxy OpenAI API. | `ReAI` CLI (`-StartForwarding`, `-StopForwarding`), tests | .NET TCP classes |
| `SelfRefactor.psm1` | Prototype self-refactoring routine. | `ReAI` when `-SelfRefactor` is used or from menu | `Invoke-GPT` |
| `SelfEvolution.psm1` | Measures code metrics, runs self-evolution and evaluates the result. | `ReAI` when `-SelfEvolve` is used | `Update-ScriptCode`, `Invoke-TestSuite`, `Test-Integrity` |
| `TestSuite.psm1` | Collection of Pester-like tests and dependency checks. | `ReAI` when `-RunTests` is specified | functions from other modules |
| `TerminalUI.psm1` | Displays the Reah-branded interactive menu grouped by service, goal, research, network and maintenance tasks. Each entry includes a short description. | `ReAI` | menu invokes various module functions |
| `ResearchSummary.psm1` | Generate lab reports, creative articles and business plans from a topic, store a compressed summary alongside, and compute overall reliability metrics using search results from multiple engines including Google Scholar and arXiv. | `ReAI` when `-ResearchTopic` is used | `Invoke-GPT`, `Search-Web`, `Get-UrlSummary`, `Save-CompressedText`, `Update-ScriptCode` |
| `GoalAnalysis.psm1` | Analyze current goals and generate subgoals for self-improvement. | `ReAI` when `-AnalyzeGoals` is used or from menu | `Invoke-GPT`, `Add-ReAIGoal` |
| `SecurityManagement.psm1` | Handles secure mode toggles, protects the state file, performs integrity verification and encrypts logs/reports when secure mode is enabled. | imported by `ReAI` | Windows security APIs, `Protect-ReAILog`, `Protect-Reports`, `Test-Integrity` |
| `Logging.psm1` | Simple logging helper writing entries to `reai.log`. | used throughout modules | `Add-Content` |
| `LocalProcessing.psm1` | Local keyword extraction and text summarization used when GPT is unavailable. | various modules | none |
| `InformationRating.psm1` | Rates reliability of text snippets during research and returns a numeric score with category. | `ResearchSummary.psm1` and others | `Invoke-GPT` |
| `ContextShortening.psm1` | Identify key terms and build condensed summaries from Google results to reduce token usage. | `ReAI` when `-ContextSummary` is used or by other modules | `Invoke-GPT`, `Search-Web`, `Get-UrlSummary` |
| `ContextCompression.psm1` | Compress arbitrary text or conversation history and save compressed summaries to files. | `ReAI` when `-CompressText` is used or from menu | `Invoke-GPT`, `Save-CompressedText` |
| `IntegrityCheck.psm1` | Save and verify SHA256 hashes of scripts to detect tampering. | `ReAI` CLI (`-SaveIntegrity`, `-VerifyIntegrity`) | `Get-FileHash` |
| `HistorySummary.psm1` | Summarize the log history to minimize token usage. | `ReAI` when `-SummarizeHistory` is used or from menu | `Compress-Text` |
| `PipelineAutomation.psm1` | Run the full research and self-evolution pipeline automatically. | `ReAI` when `-AutoPipeline` is used | `Analyze-ReAIGoals`, `Invoke-GoalProcessing`, `Update-ScriptCode`, `Summarize-History`, `Test-Integrity`, `Protect-ReAILog` |
| `WindowsPipeline.psm1` | Runs the AutoPipeline and ensures the Windows service and terminal are running. | `ReAI` when `-WinPipeline` is used | `Invoke-AutoPipeline`, `Start-Service`, `Open-ReAITerminal` |
| `EnvironmentSetup.psm1` | Prompt for missing environment variables like `OPENAI_API_KEY`. | `ReAI` and menu | `[Environment]::SetEnvironmentVariable` |
| `ReahModel.psm1` | Builds a simple Markov chain model from corpus text and chat history. | `Chatbot.psm1` | `Get-Content`, `Add-Content` |
| `Chatbot.psm1` | Interactive conversation using the local model or GPT with transcripts saved. | `ReAI` when `-Chat` or `-ChatGPT` is used or from menu | `ReahModel.psm1`, `Invoke-GPT` |
| `FileProtection.psm1` | Compresses and encrypts logs and reports for defensive storage. | `ReAI` CLI and `ResearchSummary.psm1` | `Protect-File`, `Unprotect-File` |
| `Help.psm1` | Display usage information for CLI and menu. | `ReAI` and menu | none |
