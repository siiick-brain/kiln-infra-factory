[CmdletBinding()]
param(
    [string]$KeyPath = (Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'sops\age\kiln-infra-factory\keys.txt'),
    [string]$AgeKeygenPath = 'age-keygen'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path.TrimEnd(
    [IO.Path]::DirectorySeparatorChar
) + [IO.Path]::DirectorySeparatorChar
$fullKeyPath = [IO.Path]::GetFullPath($KeyPath)
if ($fullKeyPath.StartsWith($repoRoot, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'The age private key path must be outside the repository.'
}
if (Test-Path -LiteralPath $fullKeyPath) {
    throw "Refusing to overwrite an existing age key: $fullKeyPath"
}

$keyDirectory = Split-Path -Parent $fullKeyPath
$null = New-Item -ItemType Directory -Force -Path $keyDirectory
$identity = [Security.Principal.WindowsIdentity]::GetCurrent().Name
& icacls.exe $keyDirectory '/inheritance:r' '/grant:r' "${identity}:(OI)(CI)(F)" 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw 'Could not restrict the age key directory to the current Windows user.'
}

$ageKeygen = (Get-Command -Name $AgeKeygenPath -ErrorAction Stop).Source
$previousErrorActionPreference = $ErrorActionPreference
try {
    $ErrorActionPreference = 'Continue'
    $null = & $ageKeygen -o $fullKeyPath 2>&1
    $keygenExitCode = $LASTEXITCODE
}
finally {
    $ErrorActionPreference = $previousErrorActionPreference
}

if ($keygenExitCode -ne 0 -or -not (Test-Path -LiteralPath $fullKeyPath -PathType Leaf)) {
    if (Test-Path -LiteralPath $fullKeyPath) {
        Remove-Item -LiteralPath $fullKeyPath -Force
    }
    throw 'age-keygen failed to create the private key.'
}

& icacls.exe $fullKeyPath '/inheritance:r' '/grant:r' "${identity}:(F)" 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    Remove-Item -LiteralPath $fullKeyPath -Force
    throw 'Could not restrict the age key file to the current Windows user.'
}

Write-Output "Created age key outside the repository: $fullKeyPath"
