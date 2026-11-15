$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$compose = Get-Content -Raw -LiteralPath (Join-Path $root 'compose.yml')
$decisionPath = Join-Path $root 'docs\adr\0001-emulator-choice.md'

if ($compose -notmatch 'image:\s+kiln-infra-moto:5\.2\.5') {
    throw 'Compose must pin the Moto emulator version.'
}
if ($compose -match 'localstack|LOCALSTACK_AUTH_TOKEN') {
    throw 'Compose must not use LocalStack or require its account token.'
}
if (-not (Test-Path -LiteralPath $decisionPath)) {
    throw 'The emulator choice ADR is missing.'
}

$decision = Get-Content -Raw -LiteralPath $decisionPath
foreach ($required in @('Moto', 'S3', 'SQS', 'Lambda', 'IAM', 'STS', 'CloudFront', 'account')) {
    if ($decision -notmatch [regex]::Escape($required)) {
        throw "The emulator ADR does not document $required."
    }
}

Write-Output 'Emulator contract tests passed.'
