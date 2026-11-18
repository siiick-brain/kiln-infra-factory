$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceScript = Join-Path $repoRoot 'scripts\promote.ps1'
if (-not (Test-Path -LiteralPath $sourceScript)) {
    throw 'Promotion script does not exist.'
}

$testRoot = Join-Path $env:TEMP ('kiln-promote-test-' + [guid]::NewGuid().ToString('N'))
$repo = Join-Path $testRoot 'repo'
$bin = Join-Path $testRoot 'bin'
$script = Join-Path $repo 'scripts\promote.ps1'
$log = Join-Path $testRoot 'docker.log'
$originalPath = $env:PATH
$originalLog = $env:PROMOTE_TEST_LOG
$originalExit = $env:PROMOTE_TEST_EXIT

function Set-EnvironmentPin {
    param([string]$Environment, [string]$Version)

    $directory = Join-Path $repo "live\$Environment"
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $directory 'env.hcl') -Value @"
locals {
  module_version = "$Version"
}
"@
}

function Invoke-Promotion {
    param([string]$From, [string]$To)

    $previousErrorPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script -From $From -To $To 2>&1
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorPreference
    }

    return [pscustomobject]@{
        ExitCode = $exitCode
        Output   = $output
    }
}

try {
    New-Item -ItemType Directory -Path (Join-Path $repo 'scripts'), $bin -Force | Out-Null
    Copy-Item -LiteralPath $sourceScript -Destination $script
    Set-EnvironmentPin -Environment dev -Version '0.1.0'
    Set-EnvironmentPin -Environment stage -Version '0.0.9'
    Set-EnvironmentPin -Environment prod -Version '0.0.8'
    Set-Content -LiteralPath (Join-Path $bin 'docker.cmd') -Encoding ASCII -Value @'
@echo off
echo %*>>"%PROMOTE_TEST_LOG%"
exit /b %PROMOTE_TEST_EXIT%
'@
    $env:PATH = "$bin;$originalPath"
    $env:PROMOTE_TEST_LOG = $log
    $env:PROMOTE_TEST_EXIT = '0'

    $success = Invoke-Promotion -From dev -To stage
    if ($success.ExitCode -ne 0) {
        throw "Promotion failed unexpectedly: $($success.Output -join "`n")"
    }
    if ((Get-Content -Raw (Join-Path $repo 'live\stage\env.hcl')) -notmatch 'module_version\s*=\s*"0\.1\.0"') {
        throw 'A successful promotion did not update the target version pin.'
    }

    $commands = Get-Content -LiteralPath $log -Raw
    foreach ($gate in @('format', 'validate', 'tflint', 'checkov', 'conftest', 'terraform test', 'emulator plan')) {
        if (($success.Output -join "`n") -notmatch [regex]::Escape("Running promotion gate: $gate")) {
            throw "Promotion did not run the required gate: $gate"
        }
    }
    # Regression: without the namespace Conftest evaluates no rules and passes every input.
    foreach ($gate in @('terraform fmt', 'terragrunt run', 'tflint', 'checkov --config-file .checkov.yaml', 'conftest test --parser hcl2 --namespace terraform', 'plan')) {
        if ($commands -notmatch [regex]::Escape($gate)) {
            throw "Promotion did not run the required gate: $gate"
        }
    }
    # Regression: a login shell runs /etc/profile, which resets PATH and hides the toolbox venv
    # (checkov exited 127 in the first real promotion run).
    if ($commands -match 'bash -l') {
        throw 'Promotion gates must not run in a login shell.'
    }

    Set-EnvironmentPin -Environment dev -Version '0.2.0'
    Set-EnvironmentPin -Environment stage -Version '0.1.0'
    $env:PROMOTE_TEST_EXIT = '1'
    $failedGate = Invoke-Promotion -From dev -To stage
    if ($failedGate.ExitCode -eq 0) {
        throw 'Promotion passed after a gate returned a failure.'
    }
    if ((Get-Content -Raw (Join-Path $repo 'live\stage\env.hcl')) -notmatch 'module_version\s*=\s*"0\.1\.0"') {
        throw 'A failed gate changed the target version pin.'
    }

    Set-EnvironmentPin -Environment stage -Version '0.3.0'
    Set-EnvironmentPin -Environment prod -Version '0.1.0'
    Remove-Item -LiteralPath $log -Force
    $blockedProd = Invoke-Promotion -From dev -To prod
    if ($blockedProd.ExitCode -eq 0) {
        throw 'Production promotion passed while stage used a different version.'
    }
    if (Test-Path -LiteralPath $log) {
        throw 'Production promotion ran gates before checking the stage version.'
    }
    if ((Get-Content -Raw (Join-Path $repo 'live\prod\env.hcl')) -notmatch 'module_version\s*=\s*"0\.1\.0"') {
        throw 'A blocked production promotion changed the target version pin.'
    }
} finally {
    $env:PATH = $originalPath
    $env:PROMOTE_TEST_LOG = $originalLog
    $env:PROMOTE_TEST_EXIT = $originalExit
    if (Test-Path -LiteralPath $testRoot) {
        Remove-Item -LiteralPath $testRoot -Recurse -Force
    }
}

Write-Output 'Promotion tests passed.'
