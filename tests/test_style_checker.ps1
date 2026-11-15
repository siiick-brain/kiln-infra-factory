# Style checker tests: a bad fixture fails, a good fixture passes and .style-allow suppresses a listed line.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$checker = Join-Path $root 'scripts\check-style.ps1'
$fixtures = Join-Path $root 'tests\fixtures\style'
$failed = 0

function Invoke-Checker {
    param([string[]]$CheckerArgs)
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $out = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $checker @CheckerArgs 2>&1
    $code = $LASTEXITCODE
    $ErrorActionPreference = $previous
    return [pscustomobject]@{ Code = $code; Text = ($out -join "`n") }
}

function Assert-Check {
    param([string]$Name, [bool]$Condition)
    if ($Condition) { Write-Output "PASS $Name" } else { Write-Output "FAIL $Name"; $script:failed++ }
}

$emptyAllow = Join-Path $env:TEMP ('style-allow-' + [guid]::NewGuid().ToString('N'))
Set-Content -LiteralPath $emptyAllow -Value '# empty'

$good = Invoke-Checker @('-Paths', (Join-Path $fixtures 'good.md'), '-AllowFile', $emptyAllow)
Assert-Check 'good fixture passes' ($good.Code -eq 0)

$bad = Invoke-Checker @('-Paths', (Join-Path $fixtures 'bad.md'), '-AllowFile', $emptyAllow)
Assert-Check 'bad fixture fails' ($bad.Code -eq 1)
Assert-Check 'em dash reported' ($bad.Text -match 'bad\.md:3 .*em-dash')
Assert-Check 'en dash reported' ($bad.Text -match 'bad\.md:4 .*en-dash')
Assert-Check 'and-comma reported' ($bad.Text -match 'bad\.md:5 .*and-comma')
Assert-Check 'serial comma reported' ($bad.Text -match 'bad\.md:6 .*serial-comma')

$allowedPath = Join-Path $fixtures 'allowed.md'
$plain = Invoke-Checker @('-Paths', $allowedPath, '-AllowFile', $emptyAllow)
Assert-Check 'unlisted serial comma fails' ($plain.Code -eq 1)
$allowFile = Join-Path $env:TEMP ('style-allow-' + [guid]::NewGuid().ToString('N'))
Set-Content -LiteralPath $allowFile -Value 'tests/fixtures/style/allowed.md|exact upstream title'
$allowed = Invoke-Checker @('-Paths', $allowedPath, '-AllowFile', $allowFile)
Assert-Check 'style-allow entry suppresses the line' ($allowed.Code -eq 0)

Remove-Item -LiteralPath $emptyAllow, $allowFile -Force
if ($failed -gt 0) { Write-Output "Style checker tests: $failed failed"; exit 1 }
Write-Output 'Style checker tests passed.'
