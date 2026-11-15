<#
.SYNOPSIS
Fails when README.md or a docs page links an image that does not exist or is 500 KB or larger.
Prints one line per image link.
#>
[CmdletBinding()]
param([string[]]$Files = @('README.md', 'docs\README.md', 'docs\screenshots.md'))

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$failed = 0
$checked = 0
foreach ($file in $Files) {
    $path = Join-Path $root $file
    if (-not (Test-Path -LiteralPath $path)) { continue }
    $base = Split-Path -Parent $path
    $text = [System.IO.File]::ReadAllText($path)
    foreach ($m in [regex]::Matches($text, '!\[[^\]]*\]\(([^)\s]+)\)')) {
        $target = $m.Groups[1].Value
        if ($target -match '^https?://') { continue }
        $checked++
        $full = Join-Path $base ($target -replace '/', '\')
        if (-not (Test-Path -LiteralPath $full)) {
            Write-Output "FAIL $file -> $target missing"
            $failed++
        } elseif ((Get-Item -LiteralPath $full).Length -ge 500KB) {
            Write-Output "FAIL $file -> $target is 500 KB or larger"
            $failed++
        } else {
            Write-Output "PASS $file -> $target"
        }
    }
}
Write-Output "README images: $checked links, $failed failed"
if ($failed -gt 0) { exit 1 }
exit 0
