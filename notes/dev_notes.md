# Development Notes

The repository is organized into an entry script and a set of modules.
All persistent state is stored in `state.json` at the project root.

## Directory Overview
- `ReAI.ps1` – main entry point invoked from the CLI or by the Windows service (Windows only).
- `modules/` – reusable PowerShell modules loaded by `ReAI.ps1`.
- `scripts/` – helper scripts such as `setup.ps1` and any generated scripts.
- `reports/` – markdown reports produced by goal processing.
- `notes/` – this folder (development notes, goals and private notes).
- `data/` – corpus text used to train Reah's local language model.
- `chat_logs/` – transcripts from chatbot sessions.

## File Relationships
- **ReAI.ps1** imports every `.psm1` under `modules/` via `Import-AllModules`. CLI switches invoke module functions.
- **modules/GoalManagement.psm1** - goal tracking commands (add, complete, remove, list) that modify `$State` and call `Save-State` from `StateManagement.psm1`.
 - **modules/ServiceManagement.psm1** – service start/stop helpers, status query and monitoring terminal. The monitor function restarts the service if it stops and automatically reopens the terminal. Used by `ReAI.ps1` when the related CLI options are specified.
- **modules/StateManagement.psm1** – provides `Save-State` for persisting the global state object.
 - **modules/OpenAIUtils.psm1** – OpenAI helpers plus DuckDuckGo (Tor), Google, Google Scholar and arXiv search utilities used by multiple modules.
- **modules/GoalProcessing.psm1** – creates research plans and scripts using the API utilities. Invoked from the CLI with `-ProcessGoal` or `-ProcessAllGoals`.
 - **modules/PortForwarding.psm1** – TCP port forwarding for optional API proxying; now started and stopped via CLI.
 - **modules/SelfRefactor.psm1** – prototype routine that asks GPT to rewrite the script and saves new versions; callable from the CLI and menu.
- **modules/TestSuite.psm1** – dependency checks and simple test cases invoked with the `-RunTests` CLI switch.
- **modules/TerminalUI.psm1** – interactive text menu displayed when `ReAI.ps1` is run without parameters.
   Added close-terminal option and cross-platform PowerShell detection for the terminal window.
   Menu now exposes research topic reports and secure mode toggles.
   Warning and info messages are displayed in ASCII boxes for better feedback.
   When no goals exist a yellow "No current goals" box appears at menu launch.
   The screen clears each loop and `Show-ReahBanner` redraws the ASCII banner for a clean UI.
- **modules/ResearchSummary.psm1** – generates lab reports, creative articles and business plans from a topic using API utilities and self-refactor. It aggregates reliability ratings to produce an overall score summary. Invoked with the `-ResearchTopic` CLI switch.
- **modules/GoalAnalysis.psm1** – analyzes current goals and adds new subgoals to improve ReAI. Used when `-AnalyzeGoals` is specified or from the menu.
- **modules/SecurityManagement.psm1** – manages secure mode, protects the state file, verifies integrity and encrypts logs/reports when active.
- **modules/Logging.psm1** – provides `Write-ReAILog` for standardized log output to `reai.log`.
- **modules/ContextShortening.psm1** – extracts keywords, summarizes Google search results and condenses context to reduce token usage.
- **modules/ContextCompression.psm1** – compresses arbitrary text or conversations into short summaries for token savings.
- **modules/ReahModel.psm1** – maintains a Markov chain built from corpus text and past chats.
- **modules/Chatbot.psm1** – provides local or GPT-based conversation and saves transcripts to `chat_logs/`. Invoked via the `-Chat` or `-ChatGPT` flags and menu.
- **scripts/setup.ps1** – installs required PowerShell modules (PowerHTML, Pester) and prepares runtime directories.
- **scripts/codex_setup.sh** – installs PowerShell and then runs `setup.ps1` for Codex/Linux environments.
- **notes/goals.md** – list of project goals with completion checkboxes.
- **notes/private_notes.txt** – obfuscated personal notes stored in base64.
- The main script now reads the OpenAI key from the `OPENAI_API_KEY` environment variable and warns if it is missing.
\n- Research pipeline now pulls results from Tor-based DuckDuckGo search and Google search for broader coverage.
- Service monitor now reopens the terminal after restarting the service to maintain persistent I/O.
 - The Windows service (Windows only) launches `ReAI.ps1` without parameters so the interactive menu appears in the service terminal for user commands.
 - New security module adds secure mode to block network access and protects the state file with ACLs. State file protection now runs only on Windows to avoid errors on Linux.
- New logging module standardizes log output across commands.
- Goal processing module now callable via -ProcessGoal or -ProcessAllGoals.
- Port forwarding can be controlled with -StartForwarding and -StopForwarding.
- Self-refactor routine accessible via -SelfRefactor or from the menu.
- InformationRating module rates reliability of research snippets using GPT and returns a score, category and reason.
  ResearchSummary now aggregates these ratings with an average score and High/Medium/Low breakdown for all sources.
- ContextShortening module condenses Google search context and user text to keep prompts small.
- New CLI option -ContextSummary uses the module to output a concise summary from Google results.
- ServiceManagement now exposes Get-ReAIServiceStatus for status reporting via CLI and menu.
- IntegrityCheck module stores SHA256 hashes for each script to detect tampering. It is invoked via -SaveIntegrity and -VerifyIntegrity.
  The terminal menu exposes options to save/verify integrity profiles and compress arbitrary text.
  New ContextCompression module compresses text or conversations for token savings and is called via -CompressText or the "Compress Text" menu entry.
- HistorySummary module summarizes reai.log to trim old conversation for minimal token use. Accessible via -SummarizeHistory and a menu entry.
- PipelineAutomation module runs goal analysis, goal processing, self-refactor and history summarization in one command via -AutoPipeline. It can also verify integrity and protect logs/reports when -VerifyIntegrity or -ProtectLogs/-ProtectReports are provided.
- Research pipeline extended with Google Scholar and arXiv sources for deeper academic coverage.
- EnvironmentSetup module prompts for required environment variables like OPENAI_API_KEY when missing.
- Terminal menu reorganized into categories and includes an option to configure tokens.
- Menu now shows a stylized ASCII "Reah" banner made of alien-like letters and describes each command under Service, Goal, Research, Network and Maintenance sections.
 - FileProtection module compresses and encrypts logs and reports. If REAI_ENC_KEY is unset a key is generated and saved to `enc_key.txt` for reuse. Invoked automatically by ResearchSummary and via -ProtectLogs/-ProtectReports.
- Help module displays built-in usage information via the -Help flag and menu option.
- Added install_and_start.ps1 script for a single-step installation and service startup.
- ServiceManagement and menu now support restarting the service.
- Maintenance section in the menu was renamed to **Development Tools** and now includes a **Run Auto Pipeline** option for one-step analysis and self-refactor.
- README now provides a detailed command reference table for developers.
- LocalProcessing module provides basic keyword extraction and summarization when GPT is unavailable. OpenAIUtils throttles API calls automatically: set `OPENAI_MAX_RPM` to your account's request limit and the module waits `240 / OPENAI_MAX_RPM` seconds between requests (60 seconds for `gpt-4o`). `OPENAI_RATE_LIMIT` still overrides or can be adjusted via `Set-GPTRateLimit`.
- GoalManagement now provides Remove-ReAIGoal and CLI flag -RemoveGoal for deleting goals.
- GoalManagement now supports Start-ReAIGoal and Pause-ReAIGoal to move goals between pending and in-progress states. The menu now includes "Start Goal" and "Pause Goal" options.
- ResearchSummary and GoalProcessing now save compressed summaries (`*_summary.txt`) using Save-CompressedText for quick reference.
- SelfEvolution module measures code metrics and runs self-refactor plus tests when -SelfEvolve is used. The routine now compares metrics before and after to decide if the change is beneficial.
- CLI flag -SelfEvolve triggers Invoke-SelfEvolution from SelfEvolution module and logs the evaluation result.
- Initialize-Security runs at startup to secure the state file, apply secure mode from state.json and automatically verify integrity and encrypt logs/reports when secure mode is active.
