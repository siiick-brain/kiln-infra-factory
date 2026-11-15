<#
.SYNOPSIS
Renders every terminal screenshot in docs/images with scripts/terminal_shot.py. Rerunnable.

.DESCRIPTION
Short checks run live in the toolbox. Long runs (emulator applies, Ansible, kind, swtpm) are shown
from their recorded logs, and the image title says so. Prints one line per image.
GitHub page captures need the public repository and are not part of this script.
#>
[CmdletBinding()]
param([string[]]$Only)
# Through powershell.exe -File a comma list arrives as one string, so split it.
$Only = @($Only | ForEach-Object { $_ -split "," } | Where-Object { $_ })

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$images = Join-Path $root 'docs\images'
$shot = Join-Path $root 'scripts\terminal_shot.py'
$tb = @('docker', 'run', '--rm', '-v', "${root}:/workspace", '-w', '/workspace', 'kiln-infra-toolbox:2026.11.15')

function Src([string]$name) { return $tb + @('bash', 'scripts/shot-source.sh', $name) }

$specs = [ordered]@{
    'tb-versions'      = @('Toolbox versions (live)', (Src 'tb-versions'))
    'tf-validate-all'  = @('fmt, validate and test per module (recorded run)', (Src 'tf-validate-all'))
    'terraform-test'   = @('terraform test results per module (recorded run)', (Src 'terraform-test'))
    'checkov-summary'  = @('Checkov with accepted skips (recorded run)', @('python', 'scripts/checkov-summary.py', 'artifacts/logs/checkov/run3.json', '.checkov.yaml'))
    'conftest-pass'    = @('Conftest on modules and live (live)', (Src 'conftest-pass'))
    'conftest-deny'    = @('Conftest denies the bad fixtures (live)', (Src 'conftest-deny'))
    'terragrunt-plan'  = @('Terragrunt run-all (recorded run)', (Src 'terragrunt-plan'))
    'remote-state'     = @('State migration and lock refusal (recorded run)', (Src 'remote-state'))
    'drift-detected'   = @('Drift demo (recorded run)', (Src 'drift-detected'))
    'promotion-gates'  = @('Promotion gate tests (live, gate commands stubbed)', @('powershell.exe', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', 'tests/test_promote.ps1'))
    'ansible-recap'    = @('Ansible recap, lint and testinfra (recorded run)', (Src 'ansible-recap'))
    'pki-chain-verify' = @('PKI tests (live)', (Src 'pki-chain-verify'))
    'pki-revoked-crl'  = @('Revoked certificate fails the CRL check (live)', (Src 'pki-revoked-crl'))
    'ocsp-revoked'     = @('OCSP reports revoked (live)', (Src 'ocsp-revoked'))
    'cert-rotation'    = @('Rotation deployed to nginx (recorded run)', (Src 'cert-rotation'))
    'tpm-unseal-ok'    = @('TPM seal, unseal and quote on swtpm (recorded run)', (Src 'tpm-unseal-ok'))
    'tpm-unseal-fail'  = @('Unseal fails after PCR extend (recorded run)', (Src 'tpm-unseal-fail'))
    'sops-encrypted'   = @('Committed SOPS file is encrypted (live)', (Src 'sops-encrypted'))
    'kind-apply'       = @('kind apply and pod checks (recorded run)', (Src 'kind-apply'))
    'k8s-certs-verify' = @('Kubernetes component certificates (live)', (Src 'k8s-certs-verify'))
    'tests-green'      = @('Test summary across suites (recorded runs)', (Src 'tests-green'))
    'secret-scan'      = @('gitleaks on history and tree (live)', @('powershell.exe', '-NoProfile', '-Command', 'gitleaks git --no-banner --redact --log-opts=--all .; gitleaks dir --no-banner --redact .'))
    'skills-report'    = @('Skills gate (live)', @('powershell.exe', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', 'scripts/verify-skills.ps1', '-Strict'))
}

Push-Location $root
try {
    foreach ($name in $specs.Keys) {
        if ($Only -and $name -notin $Only) { continue }
        $title, $cmd = $specs[$name]
        $out = Join-Path $images "$name.png"
        $result = & python $shot $out $title -- @cmd 2>&1
        Write-Output "$name : $($result | Select-Object -Last 1)"
    }
} finally {
    Pop-Location
}
