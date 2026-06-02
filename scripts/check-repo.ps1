$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $root

Write-Host "== PowerShell syntax =="
$tokens = $null
$errors = $null
[System.Management.Automation.Language.Parser]::ParseFile(
    (Join-Path $root "scripts\deploy-to-tablet.ps1"),
    [ref]$tokens,
    [ref]$errors
) > $null
if ($errors.Count) {
    $errors | Format-List *
    exit 1
}

Write-Host "== Shell script line endings =="
Get-ChildItem -Path (Join-Path $root "scripts") -Filter "*.sh" | ForEach-Object {
    $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
    for ($i = 0; $i -lt $bytes.Length - 1; $i++) {
        if ($bytes[$i] -eq 13 -and $bytes[$i + 1] -eq 10) {
            throw "CRLF found in shell script: $($_.FullName)"
        }
    }
}

Write-Host "== Bash syntax =="
$bash = Get-Command bash -ErrorAction SilentlyContinue
if ($bash) {
    & $bash.Path -n scripts/install-tablet-workdesk.sh
    & $bash.Path -n scripts/finalize-office-lite-avnc.sh
    & $bash.Path -n scripts/switch-office-to-avnc.sh
    & $bash.Path -n scripts/tune-office-light.sh
    & $bash.Path -n scripts/check-repo.sh
} else {
    Write-Warning "bash not found; skipped Bash syntax checks"
}

Write-Host "== Common accidental secret patterns =="
$patterns = @(
    'sk-[A-Za-z0-9_-]{20,}',
    'ghp_[A-Za-z0-9_]{20,}',
    'github_pat_[A-Za-z0-9_]{20,}',
    'OPENAI_API_KEY',
    'ANTHROPIC_API_KEY',
    'Authorization: Bearer'
)
$paths = @(
    "README.md",
    "README.zh-CN.md",
    "CHANGELOG.md",
    "CONTRIBUTING.md",
    "SECURITY.md",
    "SUPPORT.md",
    "CODE_OF_CONDUCT.md",
    "docs",
    "scripts",
    ".github\ISSUE_TEMPLATE",
    ".github\PULL_REQUEST_TEMPLATE.md"
)
$files = foreach ($path in $paths) {
    if (Test-Path $path -PathType Container) {
        Get-ChildItem -LiteralPath $path -Recurse -File
    } elseif (Test-Path $path -PathType Leaf) {
        Get-Item -LiteralPath $path
    }
}
$files = $files | Where-Object {
    $_.FullName -notmatch 'scripts[\\/]+check-repo\.(sh|ps1)$'
}
foreach ($pattern in $patterns) {
    $matches = $files | Select-String -Pattern $pattern -ErrorAction SilentlyContinue
    if ($matches) {
        $matches | Format-Table Path, LineNumber, Line -AutoSize
        throw "Possible secret pattern found: $pattern"
    }
}

Write-Host "OK"
