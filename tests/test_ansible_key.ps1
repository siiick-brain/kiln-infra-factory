$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$sshKeygen = Join-Path $env:WINDIR 'System32\OpenSSH\ssh-keygen.exe'
$testRoot = Join-Path $env:TEMP ('kiln-ansible-key-test-' + [guid]::NewGuid().ToString('N'))
$keyDirectory = Join-Path $testRoot 'keys'
$envFile = Join-Path $testRoot 'compose.env'
$scriptPath = Join-Path $PSScriptRoot '..\scripts\new-ansible-key.ps1'

try {
    $null = New-Item -ItemType Directory -Path $testRoot
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $scriptPath `
        -KeyDirectory $keyDirectory -EnvFilePath $envFile -SshKeygenPath $sshKeygen
    if ($LASTEXITCODE -ne 0) {
        throw 'Ansible key generation did not succeed.'
    }

    $privateKeyPath = Join-Path $keyDirectory 'id_ed25519'
    $publicKeyPath = "$privateKeyPath.pub"
    if (-not (Test-Path -LiteralPath $privateKeyPath) -or
        -not (Test-Path -LiteralPath $publicKeyPath)) {
        throw 'The SSH key pair is incomplete.'
    }

    $fullKeyPath = [IO.Path]::GetFullPath($privateKeyPath)
    if ($fullKeyPath.StartsWith(
            $repoRoot.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar,
            [StringComparison]::OrdinalIgnoreCase
        )) {
        throw 'The SSH private key was created inside the repository.'
    }

    $privateKey = Get-Content -LiteralPath $privateKeyPath -Raw
    $publicKey = (Get-Content -LiteralPath $publicKeyPath -Raw).Trim()
    $envContents = Get-Content -LiteralPath $envFile -Raw
    if ($envContents.Contains($privateKey.Trim())) {
        throw 'The private key was copied into the Compose environment file.'
    }
    if ($envContents -notmatch '(?m)^ANSIBLE_KEY_DIR=' -or
        $envContents -notmatch '(?m)^ANSIBLE_PUBLIC_KEY=ssh-ed25519 ') {
        throw 'The Compose environment file is missing the key directory or public key.'
    }

    $originalHash = (Get-FileHash -LiteralPath $privateKeyPath -Algorithm SHA256).Hash
    $previousErrorActionPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $null = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $scriptPath `
            -KeyDirectory $keyDirectory -EnvFilePath $envFile -SshKeygenPath $sshKeygen 2>&1
        $overwriteExitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
    if ($overwriteExitCode -eq 0) {
        throw 'Ansible key generation overwrote an existing private key.'
    }

    $newHash = (Get-FileHash -LiteralPath $privateKeyPath -Algorithm SHA256).Hash
    if ($newHash -ne $originalHash) {
        throw 'The existing private key changed after a refused overwrite.'
    }
}
finally {
    if (Test-Path -LiteralPath $testRoot) {
        Remove-Item -LiteralPath $testRoot -Recurse -Force
    }
}

Write-Output 'Ansible SSH keys stay outside the repository and existing keys are preserved.'
