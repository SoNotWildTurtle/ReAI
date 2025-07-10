# Development Notes

The repository is organized into an entry script and a set of modules.
All persistent state is stored in `state.json` at the project root.

## Directory Overview
- `ReAI` – main entry point invoked from the CLI or by the Windows service.
- `modules/` – reusable PowerShell modules loaded by `ReAI`.
- `scripts/` – helper scripts such as `setup.ps1` and any generated scripts.
- `reports/` – markdown reports produced by goal processing.
- `notes/` – this folder (development notes, goals and private notes).

## File Relationships
- **ReAI** imports every `.psm1` under `modules/` via `Import-AllModules`. CLI switches invoke module functions.
- **modules/GoalManagement.psm1** – goal tracking commands that modify `$State` and call `Save-State` from `StateManagement.psm1`.
 - **modules/ServiceManagement.psm1** – service start/stop helpers and monitoring terminal. The monitor function restarts the service if it stops and automatically reopens the terminal. Used by `ReAI` when the related CLI options are specified.
- **modules/StateManagement.psm1** – provides `Save-State` for persisting the global state object.
- **modules/OpenAIUtils.psm1** – OpenAI helpers plus DuckDuckGo (Tor) and Google search utilities used by multiple modules.
- **modules/GoalProcessing.psm1** – creates research plans and scripts using the API utilities; future automation will call this module.
- **modules/PortForwarding.psm1** – TCP port forwarding for optional API proxying; mainly used in tests.
- **modules/SelfRefactor.psm1** – prototype routine that asks GPT to rewrite the script and saves new versions.
- **modules/TestSuite.psm1** – dependency checks and simple test cases invoked with the `-RunTests` CLI switch.
- **modules/TerminalUI.psm1** – interactive text menu displayed when `ReAI` is run without parameters.
- **modules/ResearchSummary.psm1** – generates lab reports, creative articles and business plans from a topic using API utilities and self-refactor. Invoked with the `-ResearchTopic` CLI switch.
- **modules/GoalAnalysis.psm1** – analyzes current goals and adds new subgoals to improve ReAI. Used when `-AnalyzeGoals` is specified or from the menu.
- **modules/SecurityManagement.psm1** – enables secure mode, protects the state file and checks admin privileges.
- **scripts/setup.ps1** – installs required PowerShell modules (PowerHTML, Pester) and prepares runtime directories.
- **notes/goals.md** – list of project goals with completion checkboxes.
- **notes/private_notes.txt** – obfuscated personal notes stored in base64.
\n- Research pipeline now pulls results from Tor-based DuckDuckGo search and Google search for broader coverage.
- Service monitor now reopens the terminal after restarting the service to maintain persistent I/O.
- New security module adds secure mode to block network access and protects the state file with ACLs.
