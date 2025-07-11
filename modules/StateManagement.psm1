function Save-State {
    $State | ConvertTo-Json -Depth 5 | Set-Content $StateFile
}
