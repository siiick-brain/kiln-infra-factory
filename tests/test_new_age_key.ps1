$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ageKeygen = Join-Path $env:TEMP 'kiln-item12-tools\age\age-keygen.exe'
$testRoot = Join-Path $env:TEMP ('kiln-new-age-key-test-' + [guid]::NewGuid().ToString('N'))
$keyPath = Join-Path $testRoot 'keys.txt'
$scriptPath = Join-Path $PSScriptRoot '..\scripts\new-age-key.ps1'

try {
    $null = New-Item -ItemType Directory -Path $testRoot
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $scriptPath `
        -KeyPath $keyPath -AgeKeygenPath $ageKeygen
    if ($LASTEXITCODE -ne 0) {
        throw 'Key creation script did not succeed.'
    }

    $fullKeyPath = [IO.Path]::GetFullPath($keyPath)
    if ($fullKeyPath.StartsWith(
            $repoRoot.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar,
            [StringComparison]::OrdinalIgnoreCase
        )) {
        throw 'The test key was created inside the repository.'
    }

    $keyContents = Get-Content -LiteralPath $keyPath -Raw
    if ($keyContents -notmatch '(?m)^AGE-SECRET-KEY-1') {
        throw 'The generated file does not contain an age identity.'
    }

    $originalHash = (Get-FileHash -LiteralPath $keyPath -Algorithm SHA256).Hash
    $previousErrorActionPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $null = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $scriptPath `
            -KeyPath $keyPath -AgeKeygenPath $ageKeygen 2>&1
        $overwriteExitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
    if ($overwriteExitCode -eq 0) {
        throw 'The key creation script overwrote an existing key.'
    }

    $newHash = (Get-FileHash -LiteralPath $keyPath -Algorithm SHA256).Hash
    if ($newHash -ne $originalHash) {
        throw 'The existing key changed after a refused overwrite.'
    }
}
finally {
    if (Test-Path -LiteralPath $testRoot) {
        Remove-Item -LiteralPath $testRoot -Recurse -Force
    }
}

Write-Output 'Age key creation stays outside the repository and refuses overwrites.'
