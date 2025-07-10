# ReAI

ReAI is a PowerShell-based research assistant designed for experimentation with self-evolving scripts and service management.

## Setup
1. Run `scripts/setup.ps1` to install required PowerShell modules and create runtime directories.
2. Execute `./ReAI -InstallService` to install the Windows service.

## Runtime Controls
- `-StartService` / `-StopService` – manage the background service
- `-Terminal` – open a log-tail terminal for persistent I/O
- `-Monitor` – monitor the service, restart if it stops and reopen the terminal
- `-AddGoal "task"` – add a new research goal
- `-CompleteGoal "task"` – mark a goal as finished
- `-ListGoals` – display current and completed goals
- `-AnalyzeGoals` – generate subgoals and improvements automatically
- `-ResearchTopic "subject"` – generate a research report and business plan
- `-RunTests` with optional `-TestAll`, `-TestPortForwarding`, `-TestAPI`, `-TestStateManagement` – execute Pester-based tests

Running `./ReAI` with no parameters launches an interactive text menu for these actions.

All state is stored in `state.json` in the project directory.

## Directory Layout
- `ReAI` – main entry script. Loads all modules from `modules/` and exposes CLI commands. Called directly or by the Windows service. It invokes functions from the modules depending on CLI options or launches the menu by default.
- `modules/` – PowerShell modules containing most functionality. Each module is imported by `ReAI` using `Import-AllModules`.
- `scripts/` – dynamically generated scripts and helper utilities. Contains `setup.ps1` for dependency installation.
- `reports/` – generated goal reports and business summaries.
- `notes/` – development notes, goals list and private notes.

## Modules
Each module lives under `modules/` and is imported by the main script.

| Module | Purpose | Called From | Calls |
| ------ | ------- | ----------- | ----- |
| `GoalManagement.psm1` | Add, complete and list research goals. | `ReAI` CLI | `Save-State` from `StateManagement.psm1` |
| `ServiceManagement.psm1` | Start/stop Windows service and provide terminal monitoring with auto-reopen. | `ReAI` CLI | Windows `Start-Service`, `Stop-Service` |
| `StateManagement.psm1` | Persist `$State` object to disk. | `GoalManagement.psm1`, others | none |
| `OpenAIUtils.psm1` | OpenAI helpers with DuckDuckGo (Tor) and Google search. | `GoalProcessing.psm1`, `SelfRefactor.psm1`, `ResearchSummary.psm1`, tests | `Invoke-RestMethod`, `curl`, `ConvertFrom-Html` |
| `GoalProcessing.psm1` | Generates research scripts and reports for a goal. | future workflow (not yet invoked) | `Invoke-GPT`, `Search-Web`, `Get-UrlSummary` |
| `PortForwarding.psm1` | Local port forwarding helpers to proxy OpenAI API. | tests | .NET TCP classes |
| `SelfRefactor.psm1` | Prototype self-refactoring routine. | manual invocation | `Invoke-GPT` |
| `TestSuite.psm1` | Collection of Pester-like tests and dependency checks. | `ReAI` when `-RunTests` is specified | functions from other modules |
| `TerminalUI.psm1` | Presents interactive CLI menu when no arguments are passed. | `ReAI` | menu invokes various module functions |
| `ResearchSummary.psm1` | Generate lab reports, creative articles and business plans from a topic. | `ReAI` when `-ResearchTopic` is used | `Invoke-GPT`, `Search-Web`, `Get-UrlSummary`, `Update-ScriptCode` |
| `GoalAnalysis.psm1` | Analyze current goals and generate subgoals for self-improvement. | `ReAI` when `-AnalyzeGoals` is used or from menu | `Invoke-GPT`, `Add-ReAIGoal` |
