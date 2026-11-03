param(
    [Parameter(Mandatory=$true)][string]$Exe,
    [Parameter(Mandatory=$true)][string]$Zig
)
$ErrorActionPreference = 'Stop'
$Exe = (Resolve-Path $Exe).Path
$Zig = (Resolve-Path $Zig).Path
$solutions = Join-Path $PSScriptRoot 'solutions'
$learn = Join-Path ([IO.Path]::GetTempPath()) ('Zig 中文 smoke ' + [guid]::NewGuid().ToString('N'))
$utf8 = [Text.UTF8Encoding]::new($false)
$originalConsoleEncoding = [Console]::OutputEncoding
$originalOutputEncoding = $OutputEncoding
function Invoke-Learning {
    param([int]$Expected, [string[]]$Arguments)
    # Native stderr contains intentional compiler failures; preserve it without
    # letting Windows PowerShell's NativeCommandError replace exit-code checks.
    $old = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try { $lines = & $Exe @Arguments 2>&1; $code = $LASTEXITCODE }
    finally { $ErrorActionPreference = $old }
    $text = ($lines | ForEach-Object { "$_" }) -join "`n"
    if ($code -ne $Expected) { throw "Expected exit $Expected, got $code for $Arguments`n$text" }
    return $text
}
function Assert-Contains([string]$Text, [string]$Value) {
    if (-not $Text.Contains($Value)) { throw "Missing '$Value' in:`n$Text" }
}
function Assert-Bytes([byte[]]$Before, [string]$Path) {
    $after = [IO.File]::ReadAllBytes($Path)
    if ([Convert]::ToBase64String($Before) -cne [Convert]::ToBase64String($after)) { throw "File changed: $Path" }
}
try {
    [Console]::OutputEncoding = $utf8
    $OutputEncoding = $utf8
    Invoke-Learning 0 @('init', $learn) | Write-Host
    Assert-Contains (Invoke-Learning 0 @('list', '--path', $learn)) '0/36'
    $hints = Invoke-Learning 0 @('hint', '01_values', '--level', '3', '--path', $learn)
    foreach ($level in @('1', '2', '3')) { Assert-Contains $hints $level }
    $progress = Join-Path $learn '.zig-learning/progress.json'
    $first = Join-Path $learn 'exercises/01_values.zig'
    $savedProgress = [IO.File]::ReadAllBytes($progress)
    $savedSource = [IO.File]::ReadAllBytes($first)
    Invoke-Learning 2 @('init', $learn) | Write-Host
    Assert-Bytes $savedProgress $progress
    Assert-Bytes $savedSource $first
    $files = @(Get-ChildItem $solutions -Filter '*.zig' | Sort-Object Name)
    if ($files.Count -ne 36) { throw 'Expected 36 reference solutions' }
    foreach ($file in $files) {
        Invoke-Learning 1 @('run', $file.BaseName, '--path', $learn, '--zig', $Zig) | Write-Host
    }
    Assert-Contains (Invoke-Learning 0 @('list', '--path', $learn)) '0/36'
    Copy-Item (Join-Path $solutions '01_values.zig') $first
    Invoke-Learning 0 @('run', '01_values', '--path', $learn, '--zig', $Zig) | Write-Host
    Assert-Contains (Invoke-Learning 0 @('list', '--path', $learn)) '1/36'
    Assert-Contains (Invoke-Learning 0 @('list', '--path', $learn)) '1/36'
    $correct = [IO.File]::ReadAllText($first)
    [IO.File]::WriteAllText($first, $correct.Replace('42', '41'), $utf8)
    $modified = Invoke-Learning 0 @('list', '--path', $learn)
    Assert-Contains $modified '已修改'
    Assert-Contains $modified '0/36'
    Invoke-Learning 1 @('run', '01_values', '--path', $learn, '--zig', $Zig) | Write-Host
    # No learner tests remain: an incorrect public implementation must still fail.
    [IO.File]::WriteAllText($first, 'pub fn answer() u8 { return 41; }', $utf8)
    Invoke-Learning 1 @('run', '01_values', '--path', $learn, '--zig', $Zig) | Write-Host
    [IO.File]::WriteAllText($first, $correct, $utf8)
    Invoke-Learning 0 @('run', '01_values', '--path', $learn, '--zig', $Zig) | Write-Host
    $savedProgress = [IO.File]::ReadAllBytes($progress)
    Invoke-Learning 2 @('run', 'unknown', '--path', $learn) | Write-Host
    Assert-Bytes $savedProgress $progress
    Invoke-Learning 2 @('run', '02_variables', '--path', $learn, '--zig', (Join-Path $learn 'missing.exe')) | Write-Host
    Assert-Bytes $savedProgress $progress
    $second = Join-Path $learn 'exercises/02_variables.zig'
    Move-Item $second ($second + '.backup')
    Invoke-Learning 2 @('run', '02_variables', '--path', $learn, '--zig', $Zig) | Write-Host
    Assert-Bytes $savedProgress $progress
    Move-Item ($second + '.backup') $second
    [IO.File]::WriteAllText($progress, '{broken', $utf8)
    $broken = [IO.File]::ReadAllBytes($progress)
    Invoke-Learning 2 @('list', '--path', $learn) | Write-Host
    Assert-Bytes $broken $progress
    [IO.File]::WriteAllBytes($progress, $savedProgress)
    foreach ($file in $files) { Copy-Item $file.FullName (Join-Path $learn ('exercises/' + $file.Name)) }
    Invoke-Learning 0 @('verify', '--path', $learn, '--zig', $Zig) | Write-Host
    Assert-Contains (Invoke-Learning 0 @('list', '--path', $learn)) '36/36'
    foreach ($command in @('run', 'watch')) {
        Assert-Contains (Invoke-Learning 0 @($command, '--path', $learn, '--zig', (Join-Path $learn 'missing.exe'))) '全部 36 道练习已完成'
    }
    Write-Host 'SMOKE PASS: 36 starters rejected, 36 solutions accepted; CLI state/error checks passed.'
}
finally {
    if (Test-Path -LiteralPath $learn) { Remove-Item -LiteralPath $learn -Recurse -Force }
    [Console]::OutputEncoding = $originalConsoleEncoding
    $OutputEncoding = $originalOutputEncoding
}
