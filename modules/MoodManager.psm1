$script:ReahMood = 'friendly'

function Get-ReahMood {
    <#
        .SYNOPSIS
        Returns the current conversational mood.
    #>
    [CmdletBinding()]
    param()
    return $script:ReahMood
}

function Set-ReahMood {
    <#
        .SYNOPSIS
        Sets the conversational mood.
        .PARAMETER Mood
        Allowed values: friendly, functional
    #>
    [CmdletBinding()]
    param(
        [ValidateSet('friendly','functional')]
        [string]$Mood
    )
    $script:ReahMood = $Mood
    Write-ReAILog -Message "Mood set to $Mood" -Level 'INFO'
    return $script:ReahMood
}

function Get-MoodSystemPrompt {
    <#
        .SYNOPSIS
        Provides a system prompt based on current mood for GPT replies.
    #>
    [CmdletBinding()]
    param()
    switch ($script:ReahMood) {
        'functional' { return 'You are Reah operating in functional mode. Respond concisely and focus on executing built-in skills without extra personality.' }
        default      { return "You are Reah, a friendly and curious companion. Reply with full personality and encouragement." }
    }
}

Export-ModuleMember -Function Get-ReahMood, Set-ReahMood, Get-MoodSystemPrompt
