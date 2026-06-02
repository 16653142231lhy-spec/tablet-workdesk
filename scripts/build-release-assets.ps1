$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $root

$dist = Join-Path $root "dist"
New-Item -ItemType Directory -Force -Path $dist | Out-Null

$src = Join-Path $root "scripts\install-tablet-workdesk.sh"
$asset = Join-Path $dist "tw.sh"
$hashFile = Join-Path $dist "tw.sh.sha256"

Copy-Item -LiteralPath $src -Destination $asset -Force

$bytes = [System.IO.File]::ReadAllBytes($asset)
for ($i = 0; $i -lt $bytes.Length - 1; $i++) {
    if ($bytes[$i] -eq 13 -and $bytes[$i + 1] -eq 10) {
        throw "CRLF found in $asset"
    }
}

$hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $asset).Hash.ToLowerInvariant()
"$hash  tw.sh" | Set-Content -LiteralPath $hashFile -Encoding ASCII

Write-Host "Release assets written:"
Write-Host "  dist\tw.sh"
Write-Host "  dist\tw.sh.sha256"
