Describe 'ReahModel' {
    It 'generates a non-empty response' {
        Import-Module "$PSScriptRoot/../modules/ReahModel.psm1" -DisableNameChecking
        Reset-ReahModel
        Update-ReahCorpus -Line 'Reah enjoys creative exploration'
        Train-ReahModel
        $response = Get-ReahResponse -Prompt 'Reah enjoys'
        $response | Should -Not -BeNullOrEmpty
    }
}

Describe 'Chatbot command dispatch' {
    It 'handles listgoals command' {
        Import-Module "$PSScriptRoot/../modules/Chatbot.psm1" -DisableNameChecking
        Import-Module "$PSScriptRoot/../modules/GoalManagement.psm1" -DisableNameChecking
        $global:State = [PSCustomObject]@{ goals=@('alpha'); inProgress=@(); completed=@() }
        Invoke-ChatCommand -Input '!listgoals' | Should -BeTrue
    }
    It 'switches mood with !mood' {
        Import-Module "$PSScriptRoot/../modules/Chatbot.psm1" -DisableNameChecking
        Import-Module "$PSScriptRoot/../modules/MoodManager.psm1" -DisableNameChecking
        Invoke-ChatCommand -Input '!mood functional' | Should -BeTrue
        Get-ReahMood | Should -Be 'functional'
    }
}
