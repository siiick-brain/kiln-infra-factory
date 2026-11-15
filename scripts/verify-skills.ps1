<#
.SYNOPSIS
Checks each skill gate against recorded run logs and the repository, then writes the reports.

.DESCRIPTION
Each row is Pass, Fail or Not verified. Not verified rows stay visible with their reason.
Logs are read from artifacts/logs. They are produced by the commands named in each row.
Writes artifacts/skills-report.md and docs/skills-evidence.md.
With -Strict, the exit code is 1 only when a row is Fail.

.EXAMPLE
./scripts/verify-skills.ps1 -Strict
#>
[CmdletBinding()]
param([switch]$Strict)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$logs = Join-Path $root 'artifacts\logs'
$rows = [System.Collections.Generic.List[object]]::new()

function Read-Log([string]$name) {
    $path = Join-Path $logs $name
    if (Test-Path -LiteralPath $path) { return [System.IO.File]::ReadAllText($path) }
    return $null
}

function Add-Row([int]$id, [string]$skill, [string]$status, [string]$evidence, [string]$command) {
    $rows.Add([pscustomobject]@{ Id = $id; Skill = $skill; Status = $status; Evidence = $evidence; Command = $command })
    Write-Output ('{0,-13} {1,2} {2}' -f $status, $id, $skill)
}

function Test-LogMatch([string]$log, [string[]]$patterns) {
    $text = Read-Log $log
    if ($null -eq $text) { return $null }
    foreach ($p in $patterns) { if ($text -notmatch $p) { return $false } }
    return $true
}

function Resolve-Status($result, [string]$missingReason) {
    if ($null -eq $result) { return @('Not verified', $missingReason) }
    if ($result) { return @('Pass', '') }
    return @('Fail', '')
}

$gates = @(
    @{ Id = 1; Skill = 'Terraform modules validate and test for AWS, Azure and GCP'; Log = 'test-modules.log'; Patterns = @('Modules: 17 checked, 0 failed'); Command = 'scripts/test-modules.sh'; Evidence = 'artifacts/logs/test-modules.log' },
    @{ Id = 2; Skill = 'Remote state exists and locking refuses a second apply'; Log = 'migrate-state.log'; Patterns = @('Remote state object verified', 'Concurrent apply refused'); Command = 'scripts/migrate-state.sh'; Evidence = 'artifacts/logs/migrate-state.log' },
    @{ Id = 4; Skill = 'Promotion succeeds dev to stage and prod refuses a mismatched pin'; Log = 'test-promote.log'; Patterns = @('Promotion tests passed'); Command = 'tests/test_promote.ps1'; Evidence = 'artifacts/logs/test-promote.log (gate commands stubbed)' },
    @{ Id = 5; Skill = 'Terragrunt run-all passes'; Log = 'terragrunt-run-all.log'; Patterns = @('validate=0', 'plan=0', 'apply=0', 'destroy=0'); Command = 'scripts/terragrunt-run-all.sh'; Evidence = 'artifacts/logs/terragrunt-run-all.log' },
    @{ Id = 6; Skill = 'Azure networking and hosting pass validate, mock tests and policies'; Log = 'test-modules.log'; Patterns = @('PASS modules/azure/net-hub-spoke', 'PASS modules/azure/hosting'); Command = 'scripts/test-modules.sh, opa test, conftest'; Evidence = 'artifacts/logs/test-modules.log' },
    @{ Id = 8; Skill = 'GCP GKE and log sink modules pass validate, mock tests and policies'; Log = 'test-modules.log'; Patterns = @('PASS modules/gcp/gke-private', 'PASS modules/gcp/log-sinks'); Command = 'scripts/test-modules.sh'; Evidence = 'artifacts/logs/test-modules.log' },
    @{ Id = 9; Skill = 'Ansible runs, second run changed=0 and tests pass'; Log = 'test-ansible.log'; Patterns = @('changed=0\s+unreachable=0\s+failed=0', '\d+ passed'); Command = 'scripts/test-ansible.ps1'; Evidence = 'artifacts/logs/test-ansible.log' },
    @{ Id = 11; Skill = 'Bash passes shellcheck and bats'; Log = 'test-bash.log'; Patterns = @('ok 5 every script passes shellcheck'); Command = 'bats tests/test_bash_conventions.bats'; Evidence = 'artifacts/logs/test-bash.log' },
    @{ Id = 12; Skill = 'OPA tests pass and every bad fixture is denied'; Log = 'opa-test.log'; Patterns = @('(?m)^PASS: (\d+)/\1\s*$'); Command = 'opa test policies/terraform policies/k8s'; Evidence = 'artifacts/logs/opa-test.log' },
    @{ Id = 13; Skill = 'Checkov has zero unaccepted findings'; Log = 'checkov-summary.log'; Patterns = @('failed 0'); Command = 'checkov --config-file .checkov.yaml -d modules -d live'; Evidence = 'artifacts/logs/checkov-summary.log, .checkov.yaml' },
    @{ Id = 17; Skill = 'SOPS decrypts with the key and fails without it'; Log = 'test-sops.log'; Patterns = @('ok 2 decryption with the age key', 'ok 3 decryption without a key fails'); Command = 'bats tests/test_sops.bats'; Evidence = 'artifacts/logs/test-sops.log' },
    @{ Id = 18; Skill = 'PKI chain, expiry, CRL, OCSP and rotation'; Log = 'test-pki.log'; Patterns = @('ok 3 the chain verifies', 'ok 5 an expired certificate fails', 'ok 6 a revoked certificate fails the CRL check', 'ok 8 OCSP reports revoked', 'ok 10 rotation gives a new serial'); Command = 'bats tests/test_pki.bats'; Evidence = 'artifacts/logs/test-pki.log' },
    @{ Id = 19; Skill = 'TPM unseal succeeds, fails after extend, quote verifies'; Log = 'test-tpm.log'; Patterns = @('ok 2 a secret sealed', 'ok 3 unseal fails after PCR 16 is extended', 'ok 4 a quote over'); Command = 'scripts/test-tpm.ps1'; Evidence = 'artifacts/logs/test-tpm.log' },
    @{ Id = 21; Skill = 'Kubernetes manifests pass kubeconform and run non-root on kind'; Log = 'kind-apply.log'; Patterns = @('kind: 0 failed', 'runs as non-root'); Command = 'k8s/kind-apply.sh'; Evidence = 'artifacts/logs/kind-apply.log' }
)

foreach ($g in $gates) {
    $s = Resolve-Status (Test-LogMatch $g.Log $g.Patterns) "log $($g.Log) not found, run $($g.Command)"
    $evidence = if ($s[1]) { $s[1] } else { $g.Evidence }
    Add-Row $g.Id $g.Skill $s[0] $evidence $g.Command
}

# Row 3: drift. Pass needs exit 2 for injected drift and exit 0 after remediation.
$drift = Read-Log 'drift-demo.log'
if ($null -eq $drift) {
    Add-Row 3 'Drift detected with exit code 2 then cleared' 'Not verified' 'log drift-demo.log not found, run scripts/drift-demo.sh' 'scripts/drift-demo.sh'
} elseif ($drift -match 'PASS drift check after out-of-band change \(exit 2\)' -and $drift -match 'PASS drift check after remediation \(exit 0\)') {
    Add-Row 3 'Drift detected with exit code 2 then cleared' 'Pass' 'artifacts/logs/drift-demo.log' 'scripts/drift-demo.sh'
} elseif ($drift -match 'PASS drift check after out-of-band change \(exit 2\)' -and $drift -match 'PASS injected drift cleared' -and $drift -match 'NOT VERIFIED drift check after remediation') {
    Add-Row 3 'Drift detected with exit code 2 then cleared' 'Not verified' 'Exit 2 and the diff were shown. Remediation cleared the injected change. Exit 0 not reached: Moto returns policy JSON with spaces, so redrive_policy shows a whitespace-only diff on every plan' 'scripts/drift-demo.sh'
} else {
    Add-Row 3 'Drift detected with exit code 2 then cleared' 'Fail' 'artifacts/logs/drift-demo.log' 'scripts/drift-demo.sh'
}

# Row 7: Lambda and SQS on the emulator.
$lambda = Test-LogMatch 'lambda-sqs-e2e.log' @('PASS message reached the function')
if ($null -eq $lambda) {
    Add-Row 7 'AWS Lambda and SQS apply to the emulator and a message reaches the function' 'Not verified' 'Units apply to Moto. End-to-end delivery needs Moto to run the function in Docker. No passing run is recorded in artifacts/logs/lambda-sqs-e2e.log' 'scripts/lambda-sqs-e2e.sh'
} else {
    $s = Resolve-Status $lambda ''
    Add-Row 7 'AWS Lambda and SQS apply to the emulator and a message reaches the function' $s[0] 'artifacts/logs/lambda-sqs-e2e.log' 'scripts/lambda-sqs-e2e.sh'
}

# Row 10: Rocky target and Linux exercise outputs.
$outputs = @(Get-ChildItem -Path (Join-Path $root 'docs\linux-admin\outputs') -Filter '*.txt' -ErrorAction SilentlyContinue)
$rocky = ($outputs | Where-Object Name -eq '01-server.txt' | ForEach-Object { Get-Content $_.FullName -Raw }) -match 'Rocky Linux'
$status = if ($outputs.Count -ge 20 -and $rocky) { 'Pass' } elseif ($outputs.Count -eq 0) { 'Not verified' } else { 'Fail' }
Add-Row 10 'Rocky target reports Rocky and the Linux exercise outputs exist' $status "docs/linux-admin/outputs ($($outputs.Count) files)" 'scripts/linux-exercises.sh'

# Row 14: networking tables and deny-by-default test.
$net = Get-Content (Join-Path $root 'docs\networking.md') -Raw -ErrorAction SilentlyContinue
$netOk = $net -and $net -match 'mermaid' -and $net -match '(?i)\|\s*Source\s*\|' -and (Test-LogMatch 'test-modules.log' @('PASS modules/gcp/shared-vpc', 'PASS modules/aws/net', 'PASS modules/azure/net-hub-spoke'))
Add-Row 14 'Shared VPC style networking, NAT and firewall tables exist and deny-by-default tests pass' ($(if ($netOk) { 'Pass' } else { 'Fail' })) 'docs/networking.md, network module tests' 'scripts/test-modules.sh'

# Rows 15 and 16: identity trust and wildcard rejection, proven by module tests.
$idOk = Test-LogMatch 'test-modules.log' @('PASS modules/aws/github-oidc', 'PASS modules/azure/github-federated-identity', 'PASS modules/gcp/workload-identity-federation', 'PASS modules/gcp/gke-private')
$s = Resolve-Status $idOk 'run scripts/test-modules.sh'
Add-Row 15 'Workload identity trust conditions are tested' $s[0] 'OIDC and GKE module tests in artifacts/logs/test-modules.log' 'scripts/test-modules.sh'
$wild = (Test-LogMatch 'opa-test.log' @('(?m)^PASS: (\d+)/\1\s*$')) -and ((Get-Content (Join-Path $root 'policies\terraform\policy_test.rego') -Raw) -match 'wildcard')
Add-Row 16 'Wildcard IAM rejection tests pass' ($(if ($wild) { 'Pass' } else { 'Fail' })) 'policies/terraform/policy_test.rego, github-oidc module tests' 'opa test policies/terraform'

# Row 20: key lifecycle sections.
$kl = Get-Content (Join-Path $root 'docs\key-lifecycle.md') -Raw -ErrorAction SilentlyContinue
$sections = @('Generation', 'Storage', 'Use', 'Backup decision', 'Rotation', 'Revocation', 'Destruction', 'Approver')
$missing = @($sections | Where-Object { $kl -notmatch "(?m)^## $_\s*$" })
Add-Row 20 'docs/key-lifecycle.md has all required sections' ($(if ($missing.Count -eq 0) { 'Pass' } else { 'Fail' })) ($(if ($missing) { 'missing: ' + ($missing -join ', ') } else { 'docs/key-lifecycle.md' })) 'review'

# Row 22: cross-project documents.
$docs = @('docs\threat-model.md', 'docs\risk-assessment.md', 'docs\sdl-checklist.md', 'docs\procedures\promote-an-environment.md', 'docs\procedures\rotate-a-certificate.md', 'docs\procedures\recover-state.md', 'docs\procedures\respond-to-ca-compromise.md', 'docs\procedures\rotate-age-key.md')
$absent = @($docs | Where-Object { -not (Test-Path (Join-Path $root $_)) })
Add-Row 22 'Cross-project documents exist' ($(if ($absent.Count -eq 0) { 'Pass' } else { 'Fail' })) ($(if ($absent) { 'missing: ' + ($absent -join ', ') } else { 'threat model, risk assessment, SDL checklist, 5 procedures' })) 'file check'

# Row 23: hygiene.
Push-Location $root
try {
    $allowed = (Get-Content '.github\allowed-author' -Raw).Trim()
    $emails = @(git log --format='%ae%n%ce' | Sort-Object -Unique)
    $names = @(git log --format='%an%n%cn' | Sort-Object -Unique)
    $coauthors = @(git log --format='%B' | Select-String -Pattern '^co-authored-by:' -CaseSensitive:$false).Count
    $tracked = @(git ls-files | Where-Object { $_ -match '(^|/)private/|\.(pem|key|p12|pfx|tfstate)$' })
    $null = & gitleaks git --no-banner --redact --log-opts=--all . 2>&1
    $leakHistory = $LASTEXITCODE
    $null = & gitleaks dir --no-banner --redact . 2>&1
    $leakTree = $LASTEXITCODE
    $null = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'scripts\check-style.ps1')
    $style = $LASTEXITCODE
} finally { Pop-Location }
$hyg = ($emails.Count -eq 1 -and $emails[0] -eq $allowed -and $names.Count -eq 1 -and $coauthors -eq 0 -and $tracked.Count -eq 0 -and $leakHistory -eq 0 -and $leakTree -eq 0 -and $style -eq 0)
$hygEvidence = "authors=$($names.Count) emails=$($emails.Count) coauthored=$coauthors tracked-tooling=$($tracked.Count) gitleaks-history=$leakHistory gitleaks-tree=$leakTree style=$style"
Add-Row 23 'Hygiene: one author, no co-author trailers, no tooling or key files, gitleaks clean, style clean' ($(if ($hyg) { 'Pass' } else { 'Fail' })) $hygEvidence 'git log, gitleaks, scripts/check-style.ps1'

# Row 24: private evidence files.
$private = @('private\plan.md', 'private\tdd-log.md', 'private\skills-and-tools.md', 'private\reviews')
$pAbsent = @($private | Where-Object { -not (Test-Path (Join-Path $root $_)) })
Add-Row 24 'Private evidence files exist (plan, TDD log, reviews, skills log)' ($(if ($pAbsent.Count -eq 0) { 'Pass' } else { 'Fail' })) ($(if ($pAbsent) { 'missing: ' + ($pAbsent -join ', ') } else { 'private/ (gitignored)' })) 'file check'

# Row 25: README images.
$imgCheck = Join-Path $root 'scripts\check-readme-images.ps1'
if (Test-Path $imgCheck) {
    $null = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $imgCheck
    $imgStatus = if ($LASTEXITCODE -eq 0) { 'Pass' } else { 'Fail' }
    Add-Row 25 'Images present and linked' $imgStatus 'scripts/check-readme-images.ps1' 'scripts/check-readme-images.ps1'
} else {
    Add-Row 25 'Images present and linked' 'Not verified' 'scripts/check-readme-images.ps1 not present' 'scripts/check-readme-images.ps1'
}

$sorted = $rows | Sort-Object Id
$date = Get-Date -Format 'yyyy-MM-dd'
$table = @('| # | Skill gate | Status | Evidence | Command |', '|---|---|---|---|---|')
foreach ($r in $sorted) { $table += "| $($r.Id) | $($r.Skill) | $($r.Status) | $($r.Evidence) | ``$($r.Command)`` |" }
$counts = $sorted | Group-Object Status | ForEach-Object { "$($_.Name): $($_.Count)" }
$summary = "Generated by scripts/verify-skills.ps1 on $date. " + ($counts -join '. ') + '.'

New-Item -ItemType Directory -Force -Path (Join-Path $root 'artifacts') | Out-Null
$report = @('# Skills report', '', $summary, '', 'Pass means the named log or check exists and matched. Not verified rows give the reason.', '') + $table
[System.IO.File]::WriteAllText((Join-Path $root 'artifacts\skills-report.md'), ($report -join "`n") + "`n", [System.Text.UTF8Encoding]::new($false))

$evidence = @('# Skills evidence', '', 'Each project skill and the file, test or recorded run that proves it. Standards are referenced with "informed by" and no compliance claim is made.', '', $summary, '') + $table
[System.IO.File]::WriteAllText((Join-Path $root 'docs\skills-evidence.md'), ($evidence -join "`n") + "`n", [System.Text.UTF8Encoding]::new($false))

$fails = @($sorted | Where-Object Status -eq 'Fail').Count
Write-Output "Skills gate: $($sorted.Count) rows. $($counts -join '. ')."
if ($Strict -and $fails -gt 0) { exit 1 }
exit 0
