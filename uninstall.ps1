#Requires -Version 5.1
<#
.SYNOPSIS
    Uninstalls the HYTE Nexus Ticker Widget.
#>

$ErrorActionPreference = 'SilentlyContinue'
$InstallDir = "$env:LOCALAPPDATA\Programs\HyteTickerWidget"
$TaskName   = 'HyteTickerWidget'

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  HYTE Nexus Ticker Widget — Uninstaller" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# ── Stop and remove scheduled task ───────────────────────────────────────────
Write-Host "[1/3] Removing auto-start task..." -ForegroundColor Yellow
schtasks /End    /TN $TaskName 2>&1 | Out-Null
schtasks /Delete /TN $TaskName /F 2>&1 | Out-Null
Write-Host "         Done." -ForegroundColor Green

# ── Kill running widget server process ───────────────────────────────────────
Write-Host "[2/3] Stopping widget server..." -ForegroundColor Yellow
Get-Process -Name powershell -ErrorAction SilentlyContinue | ForEach-Object {
    try {
        $cmd = (Get-WmiObject Win32_Process -Filter "ProcessId=$($_.Id)" -ErrorAction SilentlyContinue).CommandLine
        if ($cmd -like "*HyteTickerWidget*") { $_ | Stop-Process -Force -ErrorAction SilentlyContinue }
    } catch {}
}
Write-Host "         Done." -ForegroundColor Green

# ── Remove installed files ───────────────────────────────────────────────────
Write-Host "[3/3] Removing files from $InstallDir ..." -ForegroundColor Yellow
if (Test-Path $InstallDir) {
    Remove-Item -Recurse -Force $InstallDir
    Write-Host "         Done." -ForegroundColor Green
} else {
    Write-Host "         (not found, skipping)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  Uninstall complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Remember to remove the widget from HYTE Nexus manually." -ForegroundColor Gray
Write-Host ""
