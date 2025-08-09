function Show-InfoBox {
    param(
        [string]$Message,
        [ConsoleColor]$Color = 'Green'
    )
    $pad = 2
    $width = $Message.Length + ($pad * 2)
    $border = '+' + ('-' * $width) + '+'
    Write-Host $border -ForegroundColor $Color
    Write-Host ('|' + (' ' * $pad) + $Message + (' ' * $pad) + '|') -ForegroundColor $Color
    Write-Host $border -ForegroundColor $Color
}

function Show-WarningBox {
    param([string]$Message)
    Show-InfoBox -Message $Message -Color 'Yellow'
}

function Show-ReahBanner {
    $lines = @(
        '  ___   _____       _        _    _',
        ' |  _ \ |  ___|    / \      | |__| |',
        ' | | |.)| .|__    / . \     | -. - |',
        ' |  _ < | ___|   /  _  \   |  /\\  |',
        ' |_| \_|_____|  /__/ \__\ |_|  |_|'
    )
    $width  = ($lines | Measure-Object Length -Maximum).Maximum
    $border = '+' + ('-' * ($width + 2)) + '+'
    Write-Host $border -ForegroundColor Cyan
    foreach ($l in $lines) {
        Write-Host ('| ' + $l.PadRight($width) + ' |') -ForegroundColor Cyan
    }
    Write-Host $border -ForegroundColor Cyan
}

function Show-ReAIMenu {
    $sections = @(
        @{Title='Service Tasks'; Items=@(
            @{Name='Start Service'; Action={Start-ReAIService}; Description='Launch the Reah background service'},
            @{Name='Stop Service'; Action={Stop-ReAIService}; Description='Stop the running service'},
            @{Name='Restart Service'; Action={Restart-ReAIService}; Description='Restart the service'},
            @{Name='Service Status'; Action={$s=Get-ReAIServiceStatus; Write-Host "Status: $s"}; Description='Show if the service is active'},
            @{Name='Monitor Service'; Action={Monitor-ReAI}; Description='Restart service automatically if it stops'},
            @{Name='View Log'; Action={View-ReAILog}; Description='Display the log file here'}
        )},
        @{Title='Goal Tasks'; Items=@(
            @{Name='List Goals'; Action={List-ReAIGoals}; Description='Display active and completed goals'},
            @{Name='Add Goal'; Action={$g=Read-Host 'Enter goal'; if($g){Add-ReAIGoal -Goal $g}}; Description='Add a new goal to the list'},
            @{Name='Complete Goal'; Action={$g=Read-Host 'Goal to complete'; if($g){Complete-ReAIGoal -Goal $g}}; Description='Mark a goal as finished'},
            @{Name='Remove Goal'; Action={$g=Read-Host 'Goal to remove'; if($g){Remove-ReAIGoal -Goal $g}}; Description='Delete a goal without completing'},
            @{Name='Start Goal'; Action={$g=Read-Host 'Goal to start'; if($g){Start-ReAIGoal -Goal $g}}; Description='Move a goal to in-progress'},
            @{Name='Pause Goal'; Action={$g=Read-Host 'Goal to pause'; if($g){Pause-ReAIGoal -Goal $g}}; Description='Move an in-progress goal back to pending'},
            @{Name='Analyze Goals'; Action={Analyze-ReAIGoals}; Description='Generate subgoals using GPT'},
            @{Name='Process Goal'; Action={$g=Read-Host 'Goal to process'; if($g){Invoke-GoalProcessing -Goal $g}}; Description='Run the research pipeline for a goal'},
            @{Name='Process All Goals'; Action={foreach($g in $State.goals){Invoke-GoalProcessing -Goal $g}}; Description='Process every goal sequentially'}
        )},
        @{Title='Research & Context'; Items=@(
            @{Name='Research Topic'; Action={$t=Read-Host 'Topic'; if($t){Invoke-Research -Topic $t}}; Description='Create research report and business plan'},
            @{Name='Manage Research'; Action={Manage-Research}; Description='Aggregate past research and suggest new goals'},
            @{Name='List Research Topics'; Action={List-ResearchTopics}; Description='Show topics with saved sources'},
            @{Name='Show Research Sources'; Action={$t=Read-Host 'Topic'; if($t){Show-ResearchSources -Topic $t}}; Description='Display saved source details'},
            @{Name='Context Summary'; Action={$t=Read-Host 'Text or topic'; if($t){Get-CondensedContext -Text $t | Write-Host}}; Description='Condense Google results into short summary'},
            @{Name='Compress Text'; Action={$t=Read-Host 'Text'; if($t){Compress-Text -Text $t | Write-Host}}; Description='Summarize provided text'},
            @{Name='Summarize History'; Action={Summarize-History | Write-Host}; Description='Compress log history for context'}
        )},
        @{Title='Chatbot'; Items=@(
            @{Name='Chat with ReAI'; Action={Start-ReAIChat}; Description='Interactive conversation using local model'},
            @{Name='Chat with ReAI (GPT)'; Action={Start-ReAIChat -UseGPT}; Description='Chat using OpenAI responses'}
        )},
        @{Title='Network & Security'; Items=@(
            @{Name='Start Port Forwarding'; Action={Start-PortForwarding -LocalPort $PortForwarding.LocalPort -RemoteHost $PortForwarding.RemoteHost -RemotePort $PortForwarding.RemotePort}; Description='Proxy OpenAI traffic through local port'},
            @{Name='Stop Port Forwarding'; Action={Stop-PortForwarding}; Description='Disable the port forwarding proxy'},
            @{Name='Enable Secure Mode'; Action={Enable-SecureMode}; Description='Block external network access'},
            @{Name='Disable Secure Mode'; Action={Disable-SecureMode}; Description='Restore normal network access'}
        )},
        @{Title='Development Tools'; Items=@(
            @{Name='Run Tests'; Action={Invoke-TestSuite -RunAll}; Description='Execute the automated test suite'},
            @{Name='Self Refactor'; Action={Update-ScriptCode}; Description='Attempt GPT-driven refactor'},
            @{Name='Self Evolve'; Action={Invoke-SelfEvolution -RunTests}; Description='Run refactor with tests and metrics'},
            @{Name='Save Integrity Profile'; Action={Save-IntegrityProfile}; Description='Record script hashes for tamper detection'},
            @{Name='Verify Integrity'; Action={Test-Integrity}; Description='Compare hashes to ensure files are intact'},
            @{Name='Configure Tokens'; Action={Prompt-EnvVariables}; Description='Interactively set environment variables'},
            @{Name='Protect Logs'; Action={Protect-ReAILog}; Description='Compress and encrypt the log file'},
            @{Name='Protect Reports'; Action={Protect-Reports}; Description='Encrypt all markdown reports'},
            @{Name='Export Config'; Action={$f=Read-Host 'File path'; if($f){Export-ReAIConfig -Path $f}}; Description='Save configuration to file'},
            @{Name='Import Config'; Action={$f=Read-Host 'File path'; if($f){Import-ReAIConfig -Path $f}}; Description='Load configuration from file'},
            @{Name='Run Auto Pipeline'; Action={Invoke-AutoPipeline}; Description='Analyze goals, process and refactor automatically'},
            @{Name='Show Help'; Action={Show-ReAIHelp}; Description='Display built-in help information'}
        )}
    )
    do {
        Clear-Host
        Show-ReahBanner
        if (-not $State.goals -or $State.goals.Count -eq 0) {
            Show-WarningBox 'No current goals'
        }
        $options = @{}
        $num = 1
        foreach($sec in $sections){
            foreach($item in $sec.Items){
                $options[$num.ToString()] = $item + @{Section=$sec.Title}
                $num++
            }
        }
        $options[$num.ToString()] = @{Name='Exit'; Action={return $true}; Section=''}

        Write-Host "`n=== Reah Menu ===" -ForegroundColor Magenta
        $current=''
        foreach($key in $options.Keys | Sort-Object {[int]$_}){
            $sec=$options[$key].Section
            if($sec -ne $current -and $sec){ Write-Host "`n[$sec]" -ForegroundColor Cyan; $current=$sec }
            $item=$options[$key]
            Write-Host -NoNewline " [" -ForegroundColor DarkGray
            Write-Host -NoNewline "$key" -ForegroundColor Green
            Write-Host -NoNewline "] " -ForegroundColor DarkGray
            Write-Host "$($item.Name) - $($item.Description)" -ForegroundColor White
        }
        $choice = Read-Host 'Enter option number (or Q to quit)'
        if ($choice -match '^[Qq]$') { $exit = $true }
        elseif ($options[$choice]) {
            $exit = & $options[$choice].Action
            if (-not $exit) { Read-Host 'Press Enter to continue' | Out-Null }
        } else {
            Write-Warning 'Invalid selection.'
        }
    } until ($exit)
}

Export-ModuleMember -Function Show-ReAIMenu,Show-InfoBox,Show-WarningBox,Show-ReahBanner

