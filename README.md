# ReAI

ReAI is a PowerShell-based research assistant designed for experimentation with self-evolving scripts and service management.

## Setup
1. On Codex or other Linux environments run `scripts/codex_setup.sh` to install PowerShell and project dependencies.
2. On Windows, run `scripts/setup.ps1` to install required PowerShell modules and create runtime directories.
3. Set an `OPENAI_API_KEY` environment variable with your OpenAI key.
4. Execute `./ReAI.ps1 -InstallService` to install the Windows service.

## Runtime Controls
- `-StartService` / `-StopService` – manage the background service
- `-ServiceStatus` – show current service status
- `-Terminal` – open a log-tail terminal for persistent I/O
- `-CloseTerminal` – close the log-tail terminal if open
- `-Monitor` – monitor the service, restart if it stops and reopen the terminal
- `-AddGoal "task"` – add a new research goal
- `-CompleteGoal "task"` – mark a goal as finished
- `-ListGoals` – display current and completed goals
- `-AnalyzeGoals` – generate subgoals and improvements automatically
- `-ResearchTopic "subject"` – generate a research report and business plan
- `-ProcessGoal "task"` – run goal processing workflow for a specific goal
- `-ProcessAllGoals` – process each active goal sequentially
- `-EnableSecureMode` / `-DisableSecureMode` – toggle network-blocking secure mode
- `-StartForwarding` / `-StopForwarding` – start or stop local port forwarding to the OpenAI API
- `-SelfRefactor` – attempt GPT-driven self refactor of the main script
- `-ContextSummary "text"` – fetch Google results for the text and return a condensed summary
- `-CompressText "text"` – compress a block of text into a short summary
- `-SummarizeHistory` – compress the log file into a short history summary
- `-AutoPipeline` – run goal analysis, process all goals, summarize history and self-refactor automatically
- `-RunTests` with optional `-TestAll`, `-TestPortForwarding`, `-TestAPI`, `-TestStateManagement` – execute Pester-based tests
- `-SaveIntegrity` – record current script hashes to `integrity.json`
- `-VerifyIntegrity` – check script hashes to detect tampering

Running `./ReAI.ps1` with no parameters launches an interactive text menu for these actions.
The menu also lets you check service status, trigger research reports, obtain context summaries, compress text, summarize history, and toggle secure mode interactively.

During research, each information source is rated for reliability using GPT to help prioritize trustworthy data. The research summary includes an average reliability score and a breakdown of high, medium and low rated sources.

All state is stored in `state.json` in the project directory.
The file is secured with restrictive permissions when first loaded.
Secure mode disables network access for safer experimentation.
Integrity checks verify script hashes to ensure the pipeline has not been tampered with.
Set the `OPENAI_API_KEY` environment variable so modules can authenticate with OpenAI.

## Directory Layout
- `ReAI.ps1` – main entry script. Loads all modules from `modules/` and exposes CLI commands. Called directly or by the Windows service. It invokes functions from the modules depending on CLI options or launches the menu by default.
- `modules/` – PowerShell modules containing most functionality. Each module is imported by `ReAI` using `Import-AllModules`.
- `scripts/` – helper utilities such as `setup.ps1` for Windows and `codex_setup.sh` for Linux environments.
- `reports/` – generated goal reports and business summaries.
- `notes/` – development notes, goals list and private notes.

## Modules
Each module lives under `modules/` and is imported by the main script.

| Module | Purpose | Called From | Calls |
| ------ | ------- | ----------- | ----- |
| `GoalManagement.psm1` | Add, complete and list research goals. | `ReAI` CLI | `Save-State` from `StateManagement.psm1` |
| `ServiceManagement.psm1` | Start/stop the Windows service, check status and manage a log-tail terminal with cross-platform detection. | `ReAI` CLI | Windows `Start-Service`, `Stop-Service`, `Get-Service` |
| `StateManagement.psm1` | Persist `$State` object to disk. | `GoalManagement.psm1`, others | none |
| `OpenAIUtils.psm1` | OpenAI helpers with DuckDuckGo (Tor), Google, Google Scholar and arXiv search. | `GoalProcessing.psm1`, `SelfRefactor.psm1`, `ResearchSummary.psm1`, tests | `Invoke-RestMethod`, `curl`, `ConvertFrom-Html` |
| `GoalProcessing.psm1` | Generates research scripts and reports for a goal. | `ReAI` when `-ProcessGoal` or `-ProcessAllGoals` is used | `Invoke-GPT`, `Search-Web`, `Get-UrlSummary` |
| `PortForwarding.psm1` | Local port forwarding helpers to proxy OpenAI API. | `ReAI` CLI (`-StartForwarding`, `-StopForwarding`), tests | .NET TCP classes |
| `SelfRefactor.psm1` | Prototype self-refactoring routine. | `ReAI` when `-SelfRefactor` is used or from menu | `Invoke-GPT` |
| `TestSuite.psm1` | Collection of Pester-like tests and dependency checks. | `ReAI` when `-RunTests` is specified | functions from other modules |
| `TerminalUI.psm1` | Presents interactive CLI menu when no arguments are passed, including port forwarding, secure mode toggles, history summaries and research commands. | `ReAI` | menu invokes various module functions |
| `ResearchSummary.psm1` | Generate lab reports, creative articles and business plans from a topic and compute overall reliability metrics using search results from multiple engines including Google Scholar and arXiv. | `ReAI` when `-ResearchTopic` is used | `Invoke-GPT`, `Search-Web`, `Get-UrlSummary`, `Update-ScriptCode` |
| `GoalAnalysis.psm1` | Analyze current goals and generate subgoals for self-improvement. | `ReAI` when `-AnalyzeGoals` is used or from menu | `Invoke-GPT`, `Add-ReAIGoal` |
| `SecurityManagement.psm1` | Provides secure mode, state file protection and admin checks. | imported by `ReAI` | Windows security APIs |
| `Logging.psm1` | Simple logging helper writing entries to `reai.log`. | used throughout modules | `Add-Content` |
| `InformationRating.psm1` | Rates reliability of text snippets during research and returns a numeric score with category. | `ResearchSummary.psm1` and others | `Invoke-GPT` |
| `ContextShortening.psm1` | Identify key terms and build condensed summaries from Google results to reduce token usage. | `ReAI` when `-ContextSummary` is used or by other modules | `Invoke-GPT`, `Search-Web`, `Get-UrlSummary` |
| `ContextCompression.psm1` | Compress arbitrary text or conversation history to meet word limits. | `ReAI` when `-CompressText` is used or from menu | `Invoke-GPT` |
| `IntegrityCheck.psm1` | Save and verify SHA256 hashes of scripts to detect tampering. | `ReAI` CLI (`-SaveIntegrity`, `-VerifyIntegrity`) | `Get-FileHash` |
| `HistorySummary.psm1` | Summarize the log history to minimize token usage. | `ReAI` when `-SummarizeHistory` is used or from menu | `Compress-Text` |
| `PipelineAutomation.psm1` | Run the full research and self-evolution pipeline automatically. | `ReAI` when `-AutoPipeline` is used | `Analyze-ReAIGoals`, `Invoke-GoalProcessing`, `Update-ScriptCode`, `Summarize-History` |
