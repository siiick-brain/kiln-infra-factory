<#
.SYNOPSIS
Checks prose against docs/STYLE.md punctuation rules.

.DESCRIPTION
Fails on em dashes, en dashes, the sequence "and," and a comma before "and".
Warns on a comma before "or". Skips fenced code, inline code, quoted text and URLs.
In code files only comment lines are checked. Lines listed in .style-allow are skipped.
Prints one line per finding and exits 1 when any FAIL is found.

.EXAMPLE
./scripts/check-style.ps1 -Staged
#>
[CmdletBinding()]
param(
    [string[]]$Paths = @('README.md', 'CHANGELOG.md', 'CONTRIBUTING.md', 'SECURITY.md', 'docs', '.github', 'scripts', 'modules', 'live', 'policies', 'ansible', 'pki', 'tpm', 'k8s', 'tests', 'docker'),
    [switch]$Staged,
    [string]$AllowFile
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not $AllowFile) { $AllowFile = Join-Path $root '.style-allow' }

$proseExtensions = @('.md', '.txt')
$codeExtensions = @('.ps1', '.sh', '.py', '.tf', '.hcl', '.rego', '.yml', '.yaml', '.toml', '.bats', '.cfg', '.j2')
$skipDirectories = @('.git', '.terraform', 'artifacts', 'private', 'node_modules', '__pycache__', '.pytest_cache', 'fixtures')

$allow = @()
if (Test-Path -LiteralPath $AllowFile) {
    foreach ($entry in Get-Content -LiteralPath $AllowFile) {
        if ($entry -match '^\s*(#|$)') { continue }
        $parts = $entry.Split('|', 2)
        if ($parts.Count -eq 2) {
            $allow += [pscustomobject]@{ Path = $parts[0].Trim().Replace('\', '/'); Text = $parts[1].Trim() }
        }
    }
}

function Get-RelativePath([string]$fullName) {
    $full = [System.IO.Path]::GetFullPath($fullName)
    if ($full.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $full.Substring($root.Length).TrimStart('\', '/').Replace('\', '/')
    }
    return $full.Replace('\', '/')
}

function Test-Skipped([string]$relative) {
    foreach ($segment in $relative.Split('/')) {
        if ($segment -in $skipDirectories) { return $true }
    }
    return $false
}

$files = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
if ($Staged) {
    $names = & git -C $root diff --cached --name-only --diff-filter=ACMR
    foreach ($name in $names) {
        if (Test-Skipped $name) { continue }
        $full = Join-Path $root $name
        if (Test-Path -LiteralPath $full -PathType Leaf) { $files.Add((Get-Item -Force -LiteralPath $full)) }
    }
} else {
    foreach ($path in $Paths) {
        $resolved = if ([System.IO.Path]::IsPathRooted($path)) { $path } else { Join-Path $root $path }
        if (-not (Test-Path -LiteralPath $resolved)) { continue }
        # -Force: on Linux, PowerShell treats dot folders such as .github as hidden.
        $item = Get-Item -Force -LiteralPath $resolved
        if ($item.PSIsContainer) {
            Get-ChildItem -Force -LiteralPath $resolved -File -Recurse | Where-Object { -not (Test-Skipped (Get-RelativePath $_.FullName)) } | ForEach-Object { $files.Add($_) }
        } else {
            $files.Add($item)
        }
    }
}

$failCount = 0
$warnCount = 0
$emDash = [string][char]0x2014
$enDash = [string][char]0x2013

foreach ($file in $files) {
    $extension = $file.Extension.ToLowerInvariant()
    $isProse = $extension -in $proseExtensions
    $isCode = $extension -in $codeExtensions
    if (-not ($isProse -or $isCode)) { continue }
    $relative = Get-RelativePath $file.FullName
    $fileAllow = @($allow | Where-Object { $relative -like $_.Path })

    $inFence = $false
    $lineNumber = 0
    foreach ($line in [System.IO.File]::ReadAllLines($file.FullName)) {
        $lineNumber++
        if ($isProse -and $line -match '^\s*(```|~~~)') { $inFence = -not $inFence; continue }
        if ($inFence) { continue }

        $text = $line
        if ($isCode) {
            if ($line -notmatch '^\s*(#|//)') { continue }
            if ($line -match '^\s*#!') { continue }
            $text = $line -replace '^\s*(#|//)+\s*', ''
        }
        if (@($fileAllow | Where-Object { $line.Contains($_.Text) }).Count -gt 0) { continue }

        # Remove inline code, quoted text and URLs before checking.
        $text = $text -replace '`[^`]*`', 'CODE'
        $text = $text -replace '"[^"]*"', ''
        $text = $text -replace 'https?://\S+', ''

        $findings = @()
        if ($text.Contains($emDash)) { $findings += 'FAIL em-dash' }
        if ($text.Contains($enDash)) { $findings += 'FAIL en-dash' }
        if ($text -match '\band,') { $findings += 'FAIL and-comma' }
        if ($text -match ',\s+and\b') { $findings += 'FAIL serial-comma' }
        if ($text -match ',\s+or\b') { $findings += 'WARN comma-or' }

        foreach ($finding in $findings) {
            $level, $rule = $finding.Split(' ', 2)
            Write-Output "$level ${relative}:$lineNumber $rule"
            if ($level -eq 'FAIL') { $failCount++ } else { $warnCount++ }
        }
    }
}

Write-Output "Style check: $($files.Count) files, $failCount FAIL, $warnCount WARN"
if ($failCount -gt 0) { exit 1 }
exit 0
