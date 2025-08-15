Import-Module "$PSScriptRoot/../modules/ResearchManagement.psm1" -Force
Describe 'ResearchManagement' {
    It 'handles missing summaries gracefully' {
        { Manage-Research } | Should -Not -Throw
    }
}
