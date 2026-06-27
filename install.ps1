#Requires -Version 5.1
<#
.SYNOPSIS
    Installs the HYTE Nexus Ticker Widget and sets it up to start with Windows.
#>

$ErrorActionPreference = 'Stop'
$InstallDir = "$env:LOCALAPPDATA\Programs\HyteTickerWidget"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  HYTE Nexus Ticker Widget — Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ── Step 1: Check / install Node.js ─────────────────────────────────────────

$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) {
    Write-Host "[1/4] Node.js not found. Installing via winget..." -ForegroundColor Yellow
    try {
        winget install OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements --silent
        # Refresh PATH for this session
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" +
                    [System.Environment]::GetEnvironmentVariable("PATH","User")
        $node = Get-Command node -ErrorAction SilentlyContinue
        if (-not $node) { throw "Node.js install succeeded but 'node' still not on PATH. Please restart and re-run." }
    } catch {
        Write-Host "ERROR: Could not install Node.js automatically." -ForegroundColor Red
        Write-Host "Please download and install it from https://nodejs.org then re-run this script." -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "[1/4] Node.js found: $(node --version)" -ForegroundColor Green
}

# ── Step 2: Copy files ───────────────────────────────────────────────────────

Write-Host "[2/4] Installing files to $InstallDir ..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

$exclude = @('install.ps1', 'uninstall.ps1', '.git', 'node_modules', '.gitignore')
Get-ChildItem -Path $PSScriptRoot | Where-Object { $_.Name -notin $exclude } | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $InstallDir -Recurse -Force
}
Write-Host "         Done." -ForegroundColor Green

# ── Step 3: Create scheduled tasks ──────────────────────────────────────────

Write-Host "[3/4] Setting up auto-start tasks..." -ForegroundColor Yellow
$nodePath = (Get-Command node).Source

$tasks = @(
    @{ Name = 'HyteTickerWidget-Proxy';  Script = 'proxy.mjs';  Delay = 'PT10S' },
    @{ Name = 'HyteTickerWidget-Server'; Script = 'server.mjs'; Delay = 'PT15S' }
)

foreach ($t in $tasks) {
    $scriptPath = Join-Path $InstallDir $t.Script
    $xml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <Triggers>
    <LogonTrigger>
      <Enabled>true</Enabled>
      <Delay>$($t.Delay)</Delay>
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
      <Command>$nodePath</Command>
      <Arguments>"$scriptPath"</Arguments>
      <WorkingDirectory>$InstallDir</WorkingDirectory>
    </Exec>
  </Actions>
</Task>
"@
    $tmpXml = [System.IO.Path]::GetTempFileName() + '.xml'
    [System.IO.File]::WriteAllText($tmpXml, $xml, [System.Text.Encoding]::Unicode)
    schtasks /Create /TN $t.Name /XML $tmpXml /F 2>&1 | Out-Null
    Remove-Item $tmpXml -Force
}
Write-Host "         Done." -ForegroundColor Green

# ── Step 4: Start servers now ────────────────────────────────────────────────

Write-Host "[4/4] Starting widget servers..." -ForegroundColor Yellow

# Stop any existing instances first
Get-Process -Name node -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -like "*HyteTickerWidget*" -or $_.CommandLine -like "*proxy.mjs*" -or $_.CommandLine -like "*server.mjs*" } |
    Stop-Process -Force -ErrorAction SilentlyContinue

Start-Sleep -Seconds 1

Start-Process -FilePath $nodePath -ArgumentList "`"$InstallDir\proxy.mjs`"" -WindowStyle Hidden
Start-Sleep -Seconds 2
Start-Process -FilePath $nodePath -ArgumentList "`"$InstallDir\server.mjs`"" -WindowStyle Hidden
Start-Sleep -Seconds 2
Write-Host "         Done." -ForegroundColor Green

# ── Get local IP ─────────────────────────────────────────────────────────────

$ip = (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
       Where-Object { $_.InterfaceAlias -notmatch 'Loopback|WSL|vEthernet' -and $_.IPAddress -notlike '169.*' } |
       Select-Object -First 1).IPAddress

if (-not $ip) { $ip = "YOUR_LOCAL_IP" }

$nexusUrl = "http://${ip}:4000"

# Copy URL to clipboard
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
Write-Host "  Both servers start automatically when Windows logs in." -ForegroundColor Gray
Write-Host ""
Write-Host "  To uninstall, run: uninstall.ps1" -ForegroundColor Gray
Write-Host ""
