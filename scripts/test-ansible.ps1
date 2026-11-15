$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $repoRoot '.env'
if (-not (Test-Path -LiteralPath $envFile -PathType Leaf)) {
    throw 'Run scripts/new-ansible-key.ps1 before testing the Rocky targets.'
}

Push-Location $repoRoot
try {
    & docker compose up -d --build rocky-target-1 rocky-target-2
    if ($LASTEXITCODE -ne 0) {
        throw 'Could not start the Rocky Linux targets.'
    }

    & docker compose run --rm --no-deps toolbox bash scripts/test-ansible.sh
    if ($LASTEXITCODE -ne 0) {
        throw "Ansible profile checks failed with exit code $LASTEXITCODE."
    }
}
finally {
    Pop-Location
}
