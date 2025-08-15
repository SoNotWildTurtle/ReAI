function Generate-BusinessPlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$Topic,
        [Parameter(Mandatory=$true)][string]$ResearchSummary
    )
    $messages = @(
        @{role='system'; content='Produce a comprehensive business plan with sections: Executive Summary, Market Opportunity, SWOT Analysis, Marketing Strategy, Operations Plan, Financial Projections, Risk Assessment, Implementation Timeline.'},
        @{role='user'; content="Topic: $Topic`nResearch Summary:`n$ResearchSummary"}
    )
    Invoke-GPT -Messages $messages -Max 1500
}
Export-ModuleMember -Function Generate-BusinessPlan
