#Requires -Version 5.1
<#
.SYNOPSIS
    Installs the HYTE Nexus Ticker Widget.
    No Node.js or third-party tools required — uses built-in PowerShell.
#>

$ErrorActionPreference = 'Stop'
$InstallDir  = "$env:LOCALAPPDATA\Programs\HyteTickerWidget"
$TaskName    = 'HyteTickerWidget'
$WidgetPort  = 4000

# ── Self-elevate if not running as admin (needed for URL ACL registration) ──
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  HYTE Nexus Ticker Widget — Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ── Step 0: Register URL ACL so widget.ps1 can bind to all network interfaces
Write-Host "[0/3] Registering network port reservation..." -ForegroundColor Yellow
$urlAcl = "http://+:${WidgetPort}/"
netsh http add urlacl url=$urlAcl user="$env:USERNAME" 2>&1 | Out-Null
Write-Host "         Done. ($urlAcl reserved for $env:USERNAME)" -ForegroundColor Green

# ── Step 1: Copy files ───────────────────────────────────────────────────────
Write-Host "[1/4] Installing files to $InstallDir ..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

$exclude = @('install.ps1', 'uninstall.ps1', '.git', 'node_modules', '.gitignore',
             'server.mjs', 'proxy.mjs', 'package.json')
Get-ChildItem -Path $PSScriptRoot | Where-Object { $_.Name -notin $exclude } | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $InstallDir -Recurse -Force
}
Write-Host "         Done." -ForegroundColor Green

# ── Step 2: Register scheduled task ─────────────────────────────────────────
Write-Host "[2/4] Registering auto-start task..." -ForegroundColor Yellow

$scriptPath  = Join-Path $InstallDir 'widget.ps1'
$psExe       = "$PSHOME\powershell.exe"
$args        = "-WindowStyle Hidden -NonInteractive -File `"$scriptPath`""

$xml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <Triggers>
    <LogonTrigger>
      <Enabled>true</Enabled>
      <Delay>PT10S</Delay>
    </LogonTrigger>
  </Triggers>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    <Hidden>true</Hidden>
  </Settings>
  <Actions>
    <Exec>
      <Command>$psExe</Command>
      <Arguments>$args</Arguments>
      <WorkingDirectory>$InstallDir</WorkingDirectory>
    </Exec>
  </Actions>
</Task>
"@

$tmpXml = [System.IO.Path]::GetTempFileName() + '.xml'
[System.IO.File]::WriteAllText($tmpXml, $xml, [System.Text.Encoding]::Unicode)
schtasks /Create /TN $TaskName /XML $tmpXml /F 2>&1 | Out-Null
Remove-Item $tmpXml -Force
Write-Host "         Done." -ForegroundColor Green

# ── Step 3: Start the server now ─────────────────────────────────────────────
Write-Host "[3/4] Starting the widget server..." -ForegroundColor Yellow

# Stop any existing instance
Get-Process -Name powershell -ErrorAction SilentlyContinue | ForEach-Object {
    try {
        $cmd = (Get-WmiObject Win32_Process -Filter "ProcessId=$($_.Id)" -ErrorAction SilentlyContinue).CommandLine
        if ($cmd -like "*HyteTickerWidget*") { $_ | Stop-Process -Force -ErrorAction SilentlyContinue }
    } catch {}
}
Start-Sleep -Seconds 1

Start-Process -FilePath $psExe -ArgumentList "-WindowStyle Hidden -NonInteractive -File `"$scriptPath`"" -WorkingDirectory $InstallDir
Start-Sleep -Seconds 3
Write-Host "         Done." -ForegroundColor Green

# ── Get local IP ─────────────────────────────────────────────────────────────
$ip = (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
       Where-Object { $_.InterfaceAlias -notmatch 'Loopback|WSL|vEthernet|Bluetooth' -and
                      $_.IPAddress -notlike '169.*' } |
       Select-Object -First 1).IPAddress

Write-Host "[4/4] Detecting local IP..." -ForegroundColor Yellow
$nexusUrl = if ($ip) { "http://${ip}:${WidgetPort}" } else { "http://YOUR_LOCAL_IP:${WidgetPort}" }

try { Set-Clipboard -Value $nexusUrl } catch {}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Installation complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Paste this URL into HYTE Nexus as a Web widget:" -ForegroundColor Cyan
Write-Host ""
Write-Host "     $nexusUrl" -ForegroundColor White
Write-Host ""
Write-Host "  (URL copied to clipboard)" -ForegroundColor Gray
Write-Host "  The widget starts automatically when Windows logs in." -ForegroundColor Gray
Write-Host ""
Write-Host "  To uninstall, run: uninstall.ps1" -ForegroundColor Gray
Write-Host ""
