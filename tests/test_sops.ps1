[CmdletBinding()]
param(
    [string]$SopsPath = 'sops',
    [string]$AgeKeyFile = (Join-Path $env:APPDATA 'sops\age\kiln-infra-factory\keys.txt')
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$encryptedFile = Join-Path $PSScriptRoot '..\secrets\demo.enc.yaml'
if (-not (Test-Path -LiteralPath $encryptedFile -PathType Leaf)) {
    throw "Encrypted example is missing: $encryptedFile"
}

$ciphertext = Get-Content -LiteralPath $encryptedFile -Raw
if ($ciphertext.Contains('example-not-a-secret')) {
    throw 'The encrypted example contains its plaintext value.'
}

$previousKeyFile = $env:SOPS_AGE_KEY_FILE
$previousAgeKey = $env:SOPS_AGE_KEY
try {
    if ([string]::IsNullOrWhiteSpace($env:SOPS_AGE_KEY)) {
        $env:SOPS_AGE_KEY_FILE = $AgeKeyFile
    }
    else {
        Remove-Item Env:\SOPS_AGE_KEY_FILE -ErrorAction SilentlyContinue
    }

    $previousErrorActionPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $plaintextOutput = & $SopsPath --decrypt $encryptedFile 2>&1
        $decryptExitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
    $plaintext = $plaintextOutput -join "`n"
    if ($decryptExitCode -ne 0) {
        throw 'SOPS could not decrypt the example with the age key.'
    }

    if ($plaintext -notmatch '(?m)^username:\s+demo-user$' -or
        $plaintext -notmatch '(?m)^password:\s+example-not-a-secret$') {
        throw 'Decrypted example did not match the fake expected values.'
    }

    Remove-Item Env:\SOPS_AGE_KEY -ErrorAction SilentlyContinue
    $env:SOPS_AGE_KEY_FILE = Join-Path $env:TEMP 'kiln-missing-age-key.txt'
    try {
        $ErrorActionPreference = 'Continue'
        $null = & $SopsPath --decrypt $encryptedFile 2>&1
        $missingKeyExitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
    if ($missingKeyExitCode -eq 0) {
        throw 'SOPS decrypted the example without an age key.'
    }
}
finally {
    if ($null -eq $previousKeyFile) {
        Remove-Item Env:\SOPS_AGE_KEY_FILE -ErrorAction SilentlyContinue
    }
    else {
        $env:SOPS_AGE_KEY_FILE = $previousKeyFile
    }

    if ($null -eq $previousAgeKey) {
        Remove-Item Env:\SOPS_AGE_KEY -ErrorAction SilentlyContinue
    }
    else {
        $env:SOPS_AGE_KEY = $previousAgeKey
    }
}

Write-Output 'SOPS example decrypts with the key and fails without it.'
# The missing-key check leaves a non-zero $LASTEXITCODE, which the Actions pwsh wrapper would report.
exit 0
