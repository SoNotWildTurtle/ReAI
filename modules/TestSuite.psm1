function Test-ScriptDependencies {
    [CmdletBinding()]
    param()
    $requiredModules = @{ 'PowerHTML' = @{ RequiredVersion = $null; HelpMessage = 'Install-Module -Name PowerHTML -Force -AllowClobber -Scope CurrentUser' }; 'Pester' = @{ RequiredVersion = '5.3.1'; HelpMessage = 'Install-Module -Name Pester -RequiredVersion 5.3.1 -Force -AllowClobber -Scope CurrentUser -SkipPublisherCheck' } }
    $allRequirementsMet = $true
    Write-Host "`n=== Checking Dependencies ===" -ForegroundColor Cyan
    foreach ($moduleName in $requiredModules.Keys) {
        $moduleInfo = $requiredModules[$moduleName]
        $requiredVersion = $moduleInfo.RequiredVersion
        Write-Host "`nChecking module: $moduleName" -NoNewline
        $module = Get-Module -Name $moduleName -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
        if (-not $module) {
            Write-Host " [MISSING]" -ForegroundColor Red
            Write-Host "  - Required: $moduleName"
            if ($requiredVersion) { Write-Host "  - Minimum Version: $requiredVersion" }
            Write-Host "  - Install with: $($moduleInfo.HelpMessage)"
            $allRequirementsMet = $false
            continue
        }
        if ($requiredVersion) {
            $versionOk = $module.Version -ge [version]$requiredVersion
            $status = if ($versionOk) { "[OK]" } else { "[VERSION MISMATCH]" }
            $color = if ($versionOk) { "Green" } else { "Yellow" }
            Write-Host " $status" -ForegroundColor $color
            Write-Host "  - Installed: $($module.Version)"
            Write-Host "  - Required: >= $requiredVersion"
            if (-not $versionOk) { Write-Host "  - Update with: $($moduleInfo.HelpMessage)"; $allRequirementsMet = $false }
        } else {
            Write-Host " [FOUND]" -ForegroundColor Green
            Write-Host "  - Version: $($module.Version)"
        }
    }
    if (-not $allRequirementsMet) {
        Write-Host "`nSome dependencies are missing or outdated. Please install/update them first." -ForegroundColor Red
        Write-Host "You can install missing modules using the commands shown above.`n"
        return $false
    }
    Write-Host "`nAll dependencies are satisfied.`n" -ForegroundColor Green
    return $true
}

function Assert-Equal {
    param([Parameter(Mandatory=$true)]$Expected, [Parameter(Mandatory=$true)]$Actual, [string]$Message="")
    if ($Expected -eq $Actual) { Write-Host "[PASS] $Message" -ForegroundColor Green; return $true } else { Write-Host "[FAIL] $Message (Expected: $Expected, Actual: $Actual)" -ForegroundColor Red; return $false }
}

function Invoke-TestSuite {
    [CmdletBinding()]
    param([switch]$RunAll,[switch]$TestPortForwarding,[switch]$TestAPI,[switch]$TestStateManagement)
    if (-not (Test-ScriptDependencies)) { Write-Error "Missing required dependencies. Please install them first."; return $false }
    $testResults = @{ Total = 0; Passed = 0; Failed = 0; Tests = @() }
    $anyTestsRequested = $RunAll -or $TestPortForwarding -or $TestAPI -or $TestStateManagement
    if (-not $anyTestsRequested) { $RunAll = $true }
    $testCases = @()
    if ($RunAll -or $TestStateManagement) { $testCases += 'StateManagement' }
    if ($RunAll -or $TestPortForwarding) { $testCases += 'PortForwarding' }
    if ($RunAll -or $TestAPI) { $testCases += 'APITest' }
    if ($RunAll -or $TestAPI) { Test-APIKey -TestResults $testResults }
    if ($testCases.Count -eq 0) { Write-Warning "No test cases selected. Use -RunAll or specific test flags."; return $false }
    Write-Host "`n=== Starting Test Execution ===" -ForegroundColor Cyan
    Write-Host "Running tests: $($testCases -join ', ')" -ForegroundColor Green
    foreach ($testCase in $testCases) {
        switch ($testCase) {
            'StateManagement' { Write-Host "`n[TEST] Running State Management Tests..." -ForegroundColor Cyan; Test-StateManagement -TestResults $testResults }
            'PortForwarding' { Write-Host "`n[TEST] Running Port Forwarding Tests..." -ForegroundColor Cyan; Test-PortForwarding -TestResults $testResults }
            'APITest' { Write-Host "`n[TEST] Running API Connectivity Tests..." -ForegroundColor Cyan; Test-APIConnectivity -TestResults $testResults }
        }
    }
    Write-Host "`n=== Test Results ==="
    Write-Host "Total Tests:  $($testResults.Total)" -ForegroundColor White
    Write-Host "Passed:       $($testResults.Passed)" -ForegroundColor Green
    $failedColor = if ($testResults.Failed -gt 0) { 'Red' } else { 'Green' }
    Write-Host "Failed:       $($testResults.Failed)" -ForegroundColor $failedColor
    Write-Host "=================="
    if ($testResults.Total -gt 0) {
        if ($testResults.Failed -eq 0) { Write-Host "All tests passed successfully!" -ForegroundColor Green; return $true } else { $failedTests = $testResults.Tests | Where-Object { $_.Result -eq 'Failed' }; if ($failedTests) { Write-Host "`nFailed Tests:" -ForegroundColor Red; foreach ($test in $failedTests) { Write-Host "- $($test.Name): $($test.Error)" -ForegroundColor Red } }; return $false }
    } else { Write-Warning "No tests were executed. Please check your test selection."; return $false }
}

function Test-StateManagement {
    [CmdletBinding()] param([hashtable]$TestResults)
    $testState = @{ goals = @('Test Goal 1','Test Goal 2'); completed=@(); iterations=0; versions=@() }
    $testFile = Join-Path $env:TEMP "test_state_$(Get-Random).json"
    Write-Host "Using test state file: $testFile"
    try {
        Write-Host "Saving test state..."; $testState | ConvertTo-Json -Depth 5 | Set-Content $testFile -Force
        Write-Host "Loading test state..."; $loadedState = Get-Content $testFile -Raw | ConvertFrom-Json
        Write-Host "Verifying loaded state..."; $result = Assert-Equal -Expected 2 -Actual $loadedState.goals.Count -Message "State should load goals correctly"
        if ($result) {
            Write-Host "Updating state with completed goal..."; $testState.completed += $testState.goals[0]; $testState | ConvertTo-Json -Depth 5 | Set-Content $testFile -Force
            Write-Host "Verifying updated state..."; $loadedState = Get-Content $testFile -Raw | ConvertFrom-Json; Assert-Equal -Expected 1 -Actual $loadedState.completed.Count -Message "State should save completed goals"
        }
    } catch { Write-Error "Error during state management test: $_"; throw } finally { if (Test-Path $testFile) { Write-Host "Cleaning up test file..."; Remove-Item $testFile -Force } }
    Write-Host "State management tests completed successfully!" -ForegroundColor Green
}

function Test-APIKey {
    param([hashtable]$TestResults)
    $TestResults.Total++
    if (-not [string]::IsNullOrWhiteSpace($env:OPENAI_API_KEY)) {
        Write-Host '[PASS] OPENAI_API_KEY found' -ForegroundColor Green
        $TestResults.Passed++
        $TestResults.Tests += @{Name='APIKeyPresent'; Result='Passed'}
        return $true
    } else {
        Write-Host '[FAIL] OPENAI_API_KEY not set' -ForegroundColor Red
        $TestResults.Failed++
        $TestResults.Tests += @{Name='APIKeyPresent'; Result='Failed'; Error='OPENAI_API_KEY not set'}
        return $false
    }
}

function Test-PortForwarding {
    [CmdletBinding()] param([hashtable]$TestResults)
    $portTest = Test-PortAvailable -Port $PortForwarding.LocalPort
    Assert-Equal -Expected $true -Actual $portTest -Message "Port $($PortForwarding.LocalPort) should be available"
    if ($PortForwarding.Enabled) {
        Write-Host "Initializing port forwarding..."; $forwardingStarted = Start-PortForwarding -LocalPort $PortForwarding.LocalPort -RemoteHost $PortForwarding.RemoteHost -RemotePort $PortForwarding.RemotePort
        if (-not $forwardingStarted) {
            Write-Warning "Port forwarding failed. Falling back to direct connection."
        } elseif (-not (Check-PortForwarding -LocalPort $PortForwarding.LocalPort)) {
            Write-Warning "Port forwarding test failed. Falling back to direct connection."; Stop-PortForwarding
        } else {
            Write-Host "Port forwarding active on port $($PortForwarding.LocalPort)" -ForegroundColor Green
        }
    }
    if ($forwardingStarted) {
        $portTest = Check-PortForwarding -LocalPort $PortForwarding.LocalPort
        Assert-Equal -Expected $true -Actual $portTest -Message "Port forwarding should work"
        Stop-PortForwarding
        Start-Sleep -Seconds 1
        $portTest = Test-PortAvailable -Port $PortForwarding.LocalPort
        Assert-Equal -Expected $true -Actual $portTest -Message "Port should be released after stopping"
    }
}

function Test-APIConnectivity {
    [CmdletBinding()] param([hashtable]$TestResults)
    $testPrompt = @(@{role='system'; content='You are a helpful assistant.'}, @{role='user'; content='Say "test"'})
    Write-Host "`n[TEST] Running Direct API Connectivity Test..." -ForegroundColor Cyan
    $response = Invoke-GPT -Messages $testPrompt -Max 10
    Assert-Equal -Expected 'test' -Actual $response -Message "Direct API test failed"
    if ($PortForwarding.Enabled) {
        Write-Host "`n[TEST] Running API Connectivity Test (with Port Forwarding)..." -ForegroundColor Cyan
        $global:OpenAIEndpoint = "http://localhost:${PortForwarding.LocalPort}"
        $response = Invoke-GPT -Messages $testPrompt -Max 10
        Assert-Equal -Expected 'test' -Actual $response -Message "API test with port forwarding failed"
    }
}

Export-ModuleMember -Function Invoke-TestSuite,Test-ScriptDependencies,Assert-Equal,Test-StateManagement,Test-APIKey,Test-PortForwarding,Test-APIConnectivity