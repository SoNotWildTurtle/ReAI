function Generate-BusinessAdvisory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$Topic,
        [Parameter(Mandatory=$true)][string]$BusinessPlan
    )
    $messages = @(
        @{role='system'; content='Act as a seasoned business advisor. Given a business plan, provide ongoing strategic guidance with sections: Action Items, Growth Opportunities, Risk Monitoring, Key Metrics, and Next Steps.'},
        @{role='user'; content="Topic: $Topic`nBusiness Plan:`n$BusinessPlan"}
    )
    Invoke-GPT -Messages $messages -Max 1200
}
Export-ModuleMember -Function Generate-BusinessAdvisory
