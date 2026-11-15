[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('dev', 'stage', 'prod')]
    [string]$From,

    [Parameter(Mandatory = $true)]
    [ValidateSet('dev', 'stage', 'prod')]
    [string]$To
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$environmentOrder = @{ dev = 0; stage = 1; prod = 2 }
if ($environmentOrder[$From] -ge $environmentOrder[$To]) {
    throw 'Promotion must move from a lower environment to a higher environment.'
}

function Get-ModuleVersion {
    param([string]$Environment)

    $path = Join-Path $repoRoot "live\$Environment\env.hcl"
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Environment configuration does not exist: $path"
    }

    $content = Get-Content -LiteralPath $path -Raw
    $matches = [regex]::Matches($content, '(?m)^\s*module_version\s*=\s*"([^"]+)"\s*$')
    if ($matches.Count -ne 1) {
        throw "Expected one module_version pin in $path."
    }

    return [pscustomobject]@{
        Path    = $path
        Content = $content
        Version = $matches[0].Groups[1].Value
    }
}

$source = Get-ModuleVersion -Environment $From
$target = Get-ModuleVersion -Environment $To
if ($To -eq 'prod') {
    $stage = Get-ModuleVersion -Environment 'stage'
    if ($stage.Version -ne $source.Version) {
        throw "Production promotion is blocked because stage uses $($stage.Version) and the requested version is $($source.Version)."
    }
}

function Invoke-PromotionGate {
    param(
        [string]$Name,
        [string]$Command
    )

    Write-Output "Running promotion gate: $Name"
    & docker compose -f (Join-Path $repoRoot 'compose.yml') run --rm --no-deps toolbox bash -lc $Command
    if ($LASTEXITCODE -ne 0) {
        throw "Promotion gate '$Name' failed with exit code $LASTEXITCODE."
    }
}

$validationCommand = @'
set -euo pipefail
while IFS= read -r -d '' module; do
  terraform -chdir="$module" init -backend=false -input=false -no-color
  terraform -chdir="$module" validate -no-color
done < <(find modules -mindepth 2 -maxdepth 2 -type d -print0)
while IFS= read -r -d '' example; do
  terraform -chdir="$example" init -backend=false -input=false -no-color
  terraform -chdir="$example" validate -no-color
done < <(find modules -path '*/examples/*' -type d -print0)
'@
$testCommand = @'
set -euo pipefail
while IFS= read -r -d '' module; do
  terraform -chdir="$module" test -no-color
done < <(find modules -mindepth 2 -maxdepth 2 -type d -print0)
'@

Invoke-PromotionGate -Name 'format' -Command 'terraform fmt -check -recursive modules live'
Invoke-PromotionGate -Name 'validate' -Command $validationCommand
Invoke-PromotionGate -Name 'tflint' -Command 'bash scripts/run-tflint.sh'
Invoke-PromotionGate -Name 'checkov' -Command 'checkov --config-file .checkov.yaml -d modules -d live'
Invoke-PromotionGate -Name 'conftest' -Command 'conftest test --parser hcl2 --namespace terraform --ignore ''\.terraform|\.terragrunt-cache'' -p policies/terraform modules live'
Invoke-PromotionGate -Name 'terraform test' -Command $testCommand
Invoke-PromotionGate -Name 'emulator plan' -Command "bash scripts/bootstrap-state-bucket.sh && terragrunt run --all --parallelism 1 --non-interactive --working-dir live/$To/aws -- plan -no-color"

$updatedContent = [regex]::Replace(
    $target.Content,
    '(?m)^(\s*module_version\s*=\s*)"[^"]+"',
    ('$1"' + $source.Version + '"')
)
[System.IO.File]::WriteAllText(
    $target.Path,
    $updatedContent,
    [System.Text.UTF8Encoding]::new($false)
)
Write-Output "Updated $To module_version to $($source.Version)."
