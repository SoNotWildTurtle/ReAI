function Save-State {
    $path = $StateFile
    if (-not $path) { $path = $global:StateFile }
    $State | ConvertTo-Json -Depth 5 | Set-Content $path
}

Export-ModuleMember -Function Save-State
