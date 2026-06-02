param(
    [string]$DevicePath = "/sdcard/Download/tw.sh",
    [switch]$OpenTermux
)

$ErrorActionPreference = "Stop"

$adb = (Get-Command adb -ErrorAction Stop).Source
$scriptPath = Join-Path $PSScriptRoot "install-tablet-workdesk.sh"

if (-not (Test-Path $scriptPath)) {
    throw "Missing installer: $scriptPath"
}

Write-Host "== adb devices =="
& $adb devices -l

Write-Host ""
Write-Host "== push installer =="
& $adb push $scriptPath $DevicePath

if ($OpenTermux) {
    Write-Host ""
    Write-Host "== open Termux =="
    & $adb shell am start -n com.termux/.app.TermuxActivity
}

Write-Host ""
Write-Host "Next step in Termux:"
Write-Host "bash $DevicePath"
