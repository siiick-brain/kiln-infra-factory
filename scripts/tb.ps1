[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Command
)

$ErrorActionPreference = 'Stop'

if ($Command.Count -eq 0) {
    [Console]::Error.WriteLine('Usage: .\scripts\tb.ps1 <command> [arguments...] | versions')
    exit 2
}

if ($Command[0] -eq 'versions') {
    $Command = @('bash', 'scripts/toolbox-versions.sh')
}

$repoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repoRoot
try {
    & docker compose run --rm --no-deps toolbox @Command
    exit $LASTEXITCODE
} finally {
    Pop-Location
}
