$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$modules = @(
    'aws\net',
    'aws\state-bootstrap',
    'aws\sqs',
    'aws\lambda-sqs-consumer',
    'aws\cloudfront-static',
    'aws\github-oidc',
    'azure\net-hub-spoke',
    'azure\hosting',
    'azure\keyvault',
    'azure\github-federated-identity',
    'gcp\shared-vpc',
    'gcp\gke-private',
    'gcp\log-sinks',
    'gcp\workload-identity-federation',
    'secrets\aws',
    'secrets\azure',
    'secrets\gcp'
)
$requiredFiles = @('versions.tf', 'variables.tf', 'outputs.tf', 'README.md', 'examples\basic\main.tf', 'tests\basic.tftest.hcl', 'VERSION', 'CHANGELOG.md')

foreach ($module in $modules) {
    $modulePath = Join-Path (Join-Path $root 'modules') $module
    foreach ($file in $requiredFiles) {
        $path = Join-Path $modulePath $file
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Module contract file is missing: $path"
        }
    }

    $test = Get-Content -Raw -LiteralPath (Join-Path $modulePath 'tests\basic.tftest.hcl')
    if ($test -notmatch 'mock_provider') {
        throw "Module test does not declare a mock provider: $module"
    }
}

Write-Output 'Module contract tests passed.'
