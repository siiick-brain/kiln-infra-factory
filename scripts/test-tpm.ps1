# Starts the swtpm container and runs the TPM bats tests in the toolbox on the same Compose network.
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repoRoot
try {
    & docker compose up -d --build swtpm
    if ($LASTEXITCODE -ne 0) { throw 'Could not start swtpm.' }
    # A fresh TPM state for each run keeps the tests repeatable.
    & docker compose restart swtpm | Out-Null
    & docker compose run --rm -e TPM2TOOLS_TCTI=swtpm:host=swtpm,port=2321 toolbox bats tests/test_tpm.bats
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
