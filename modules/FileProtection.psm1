function Get-EncryptionKey {
    param([string]$EnvVar = 'REAI_ENC_KEY')
    $keyFile = Join-Path $global:WorkDir 'enc_key.txt'
    $key = ${env:$EnvVar}
    if (-not $key -and (Test-Path $keyFile)) {
        $key = Get-Content -Path $keyFile -Raw
    }
    if (-not $key) {
        $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
        $bytes = New-Object byte[] 32
        $rng.GetBytes($bytes)
        $key = [Convert]::ToBase64String($bytes)
        [Environment]::SetEnvironmentVariable($EnvVar, $key, 'User')
        try { Set-Content -Path $keyFile -Value $key -Force } catch {}
    }
    return [Convert]::FromBase64String($key)
}

function Protect-File {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path $Path)) { return }
    $key = Get-EncryptionKey
    $data = [IO.File]::ReadAllBytes($Path)
    $ms = New-Object IO.MemoryStream
    $gzip = New-Object IO.Compression.GZipStream($ms,[IO.Compression.CompressionMode]::Compress)
    $gzip.Write($data,0,$data.Length)
    $gzip.Close()
    $compressed = $ms.ToArray()
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $key
    $aes.GenerateIV()
    $iv = $aes.IV
    $enc = $aes.CreateEncryptor()
    $cipher = $enc.TransformFinalBlock($compressed,0,$compressed.Length)
    $dest = "$Path.enc"
    [IO.File]::WriteAllBytes($dest, $iv + $cipher)
    Remove-Item $Path
    return $dest
}

function Unprotect-File {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path $Path)) { return }
    $key = Get-EncryptionKey
    $bytes = [IO.File]::ReadAllBytes($Path)
    $iv = $bytes[0..15]
    $cipher = $bytes[16..($bytes.Length-1)]
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $key
    $aes.IV = $iv
    $dec = $aes.CreateDecryptor()
    $compressed = $dec.TransformFinalBlock($cipher,0,$cipher.Length)
    $ms = New-Object IO.MemoryStream($compressed)
    $gzip = New-Object IO.Compression.GZipStream($ms,[IO.Compression.CompressionMode]::Decompress)
    $out = New-Object IO.MemoryStream
    $buf = New-Object byte[] 1024
    while(($read = $gzip.Read($buf,0,1024)) -gt 0){$out.Write($buf,0,$read)}
    $gzip.Close()
    $dest = $Path -replace '\.enc$',''
    [IO.File]::WriteAllBytes($dest,$out.ToArray())
    return $dest
}

function Protect-Reports {
    foreach ($f in Get-ChildItem $global:ReportsDir -Filter '*.md' -File) {
        Protect-File -Path $f.FullName | Out-Null
    }
}

function Protect-ReAILog {
    Protect-File -Path $global:LogFile | Out-Null
    $global:LogFile = "$global:LogFile.enc"
}

Export-ModuleMember -Function Get-EncryptionKey,Protect-File,Unprotect-File,Protect-Reports,Protect-ReAILog
