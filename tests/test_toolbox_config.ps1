$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$dockerfile = Join-Path $root 'docker\toolbox\Dockerfile'
$compose = Join-Path $root 'compose.yml'
$runner = Join-Path $root 'scripts\tb.ps1'

foreach ($path in @($dockerfile, $compose, $runner)) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Required toolbox file is missing: $path"
    }
}

$dockerText = Get-Content -Raw -LiteralPath $dockerfile
$composeText = Get-Content -Raw -LiteralPath $compose
$runnerText = Get-Content -Raw -LiteralPath $runner

foreach ($tool in @('TERRAFORM', 'TERRAGRUNT', 'TFLINT', 'CHECKOV', 'OPA', 'CONFTEST', 'ANSIBLE', 'ANSIBLE_LINT', 'SOPS', 'AGE', 'SHELLCHECK', 'BATS', 'TERRAFORM_DOCS', 'TPM2_TOOLS')) {
    if ($dockerText -notmatch "(?m)^ARG $tool`_VERSION=\d") {
        throw "Toolbox version is not pinned for $tool."
    }
}

foreach ($service in @('toolbox:', 'emulator:', 'swtpm:', 'rocky-target-1:', 'rocky-target-2:')) {
    if ($composeText -notmatch [regex]::Escape($service)) {
        throw "Compose service is missing: $service"
    }
}

if ($runnerText -notmatch 'docker compose run --rm --no-deps toolbox') {
    throw 'The toolbox runner must pass commands to docker compose run.'
}

if ($dockerText -notmatch 'expected_opa_sha=.*awk') {
    throw 'The OPA checksum check must parse the first field of its checksum file.'
}

if ($dockerText -notmatch 'curl -fsSLO .*sops-v\$\{SOPS_VERSION\}\.linux\.amd64') {
    throw 'The SOPS binary must be downloaded under the filename used by its checksum file.'
}

Write-Output 'Toolbox configuration tests passed.'
