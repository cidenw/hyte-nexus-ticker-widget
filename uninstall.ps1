#Requires -Version 5.1
<#
.SYNOPSIS
    Uninstalls the HYTE Nexus Ticker Widget.
#>

$ErrorActionPreference = 'SilentlyContinue'
$InstallDir = "$env:LOCALAPPDATA\Programs\HyteTickerWidget"
$TaskNames  = @('HyteTickerWidget-Server', 'HyteTickerWidget-Proxy')

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  HYTE Nexus Ticker Widget — Uninstaller" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# ── Stop scheduled tasks ─────────────────────────────────────────────────────
Write-Host "[1/3] Stopping and removing scheduled tasks..." -ForegroundColor Yellow
foreach ($name in $TaskNames) {
    schtasks /End    /TN $name 2>&1 | Out-Null
    schtasks /Delete /TN $name /F 2>&1 | Out-Null
}
Write-Host "         Done." -ForegroundColor Green

# ── Kill running Node processes for this widget ──────────────────────────────
Write-Host "[2/3] Stopping running servers..." -ForegroundColor Yellow
Get-Process -Name node -ErrorAction SilentlyContinue | ForEach-Object {
    try {
        $cmd = (Get-WmiObject Win32_Process -Filter "ProcessId=$($_.Id)").CommandLine
        if ($cmd -like "*HyteTickerWidget*" -or $cmd -like "*proxy.mjs*" -or $cmd -like "*server.mjs*") {
            $_ | Stop-Process -Force
        }
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
