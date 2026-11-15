$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$required = @(
    'root.hcl',
    'live\dev\env.hcl',
    'live\stage\env.hcl',
    'live\prod\env.hcl',
    'live\dev\aws\state-bootstrap\terragrunt.hcl',
    'live\dev\aws\net\terragrunt.hcl',
    'live\dev\gcp\shared-vpc\terragrunt.hcl',
    'live\dev\gcp\gke-private\terragrunt.hcl'
)

$missing = @($required | Where-Object { -not (Test-Path (Join-Path $repoRoot $_)) })
if ($missing.Count -gt 0) {
    Write-Error "Terragrunt layout is missing: $($missing -join ', ')"
    exit 1
}

$unitFiles = @(Get-ChildItem -Path (Join-Path $repoRoot 'live') -Filter 'terragrunt.hcl' -Recurse -File)
if ($unitFiles.Count -lt 12) {
    Write-Error 'Expected at least twelve environment unit configurations.'
    exit 1
}

$dependencyFiles = @($unitFiles | Where-Object {
    (Get-Content -Raw $_.FullName) -match '(?m)^dependency\s+"'
})
if ($dependencyFiles.Count -lt 2) {
    Write-Error 'Expected Terragrunt dependency declarations for the AWS and GCP stacks.'
    exit 1
}

Write-Output "Terragrunt layout checks passed for $($unitFiles.Count) units."
