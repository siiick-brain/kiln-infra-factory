[CmdletBinding()]
param(
    [string]$KeyDirectory = (Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'kiln-infra-factory\ansible'),
    [string]$EnvFilePath = '',
    [string]$SshKeygenPath = 'ssh-keygen'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path.TrimEnd(
    [IO.Path]::DirectorySeparatorChar
) + [IO.Path]::DirectorySeparatorChar
if ([string]::IsNullOrWhiteSpace($EnvFilePath)) {
    $EnvFilePath = Join-Path (Split-Path -Parent $PSScriptRoot) '.env'
}

$fullKeyDirectory = [IO.Path]::GetFullPath($KeyDirectory)
if ($fullKeyDirectory.StartsWith($repoRoot, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'The SSH private key directory must be outside the repository.'
}

$privateKeyPath = Join-Path $fullKeyDirectory 'id_ed25519'
$publicKeyPath = "$privateKeyPath.pub"
if ((Test-Path -LiteralPath $privateKeyPath) -or (Test-Path -LiteralPath $publicKeyPath)) {
    throw 'Refusing to overwrite an existing SSH key.'
}

$null = New-Item -ItemType Directory -Force -Path $fullKeyDirectory
$identity = [Security.Principal.WindowsIdentity]::GetCurrent().Name
& icacls.exe $fullKeyDirectory '/inheritance:r' '/grant:r' "${identity}:(OI)(CI)(F)" 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw 'Could not restrict the SSH key directory to the current Windows user.'
}

$sshKeygen = (Get-Command -Name $SshKeygenPath -ErrorAction Stop).Source
$arguments = '-q -t ed25519 -N "" -f "' + $privateKeyPath + '" -C kiln-infra-factory'
$process = Start-Process -FilePath $sshKeygen -ArgumentList $arguments -Wait -PassThru -NoNewWindow
$keygenExitCode = $process.ExitCode

if ($keygenExitCode -ne 0 -or
    -not (Test-Path -LiteralPath $privateKeyPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $publicKeyPath -PathType Leaf)) {
    foreach ($path in @($privateKeyPath, $publicKeyPath)) {
        if (Test-Path -LiteralPath $path) {
            Remove-Item -LiteralPath $path -Force
        }
    }
    throw 'ssh-keygen failed to create the key pair.'
}

& icacls.exe $privateKeyPath '/inheritance:r' '/grant:r' "${identity}:(F)" 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    Remove-Item -LiteralPath $privateKeyPath -Force
    Remove-Item -LiteralPath $publicKeyPath -Force
    throw 'Could not restrict the SSH private key to the current Windows user.'
}

$publicKey = (Get-Content -LiteralPath $publicKeyPath -Raw).Trim()
if ($publicKey -notmatch '^ssh-ed25519\s+[A-Za-z0-9+/]+={0,3}(?:\s+.*)?$') {
    Remove-Item -LiteralPath $privateKeyPath -Force
    Remove-Item -LiteralPath $publicKeyPath -Force
    throw 'ssh-keygen produced an invalid public key.'
}

$environment = [System.Collections.Generic.List[string]]::new()
if (Test-Path -LiteralPath $EnvFilePath -PathType Leaf) {
    foreach ($line in Get-Content -LiteralPath $EnvFilePath) {
        if ($line -notmatch '^\s*ANSIBLE_(KEY_DIR|PUBLIC_KEY)=') {
            $environment.Add($line)
        }
    }
}
$environment.Add("ANSIBLE_KEY_DIR=$($fullKeyDirectory.Replace('\', '/'))")
$environment.Add("ANSIBLE_PUBLIC_KEY=$publicKey")
[IO.File]::WriteAllLines($EnvFilePath, $environment, [Text.UTF8Encoding]::new($false))

Write-Output "Created Ansible SSH key outside the repository: $fullKeyDirectory"
