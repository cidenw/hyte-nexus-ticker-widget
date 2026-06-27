# HYTE Nexus Ticker Widget Server
# Pure PowerShell — no Node.js or third-party tools required.
# Serves the widget files AND proxies Yahoo Finance on the same port (no CORS issues).
#
# Usage: powershell -WindowStyle Hidden -File widget.ps1
param([int]$Port = 4000)

$ErrorActionPreference = 'Stop'
$ScriptDir = $PSScriptRoot

# ── Detect local IP ──────────────────────────────────────────────────────────
$LocalIP = (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object { $_.InterfaceAlias -notmatch 'Loopback|WSL|vEthernet|Bluetooth' -and
                   $_.IPAddress -notlike '169.*' } |
    Select-Object -First 1).IPAddress

# ── Start HTTP listener ──────────────────────────────────────────────────────
# http://+:PORT/ requires a URL ACL registered by install.ps1 (one-time, needs admin).
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://+:${Port}/")

try { $listener.Start() }
catch {
    Write-Error "Could not start server on port ${Port}. Run install.ps1 first to register the URL reservation. Error: $_"
    exit 1
}

Write-Host "HYTE Nexus Ticker Widget running:"
Write-Host "  Local:  http://localhost:${Port}"
if ($LocalIP) { Write-Host "  Nexus:  http://${LocalIP}:${Port}  <- paste this into Nexus" }
Write-Host "Press Ctrl+C to stop."

# ── MIME types ───────────────────────────────────────────────────────────────
$MIME = @{
    '.html' = 'text/html; charset=utf-8'
    '.css'  = 'text/css'
    '.js'   = 'application/javascript'
    '.json' = 'application/json'
    '.svg'  = 'image/svg+xml'
    '.ico'  = 'image/x-icon'
    '.png'  = 'image/png'
}

# ── Helper: write response ────────────────────────────────────────────────────
function Send-Response {
    param($Res, [int]$Status, [string]$Type, $Body)
    try {
        $Res.StatusCode = $Status
        $Res.ContentType = $Type
        $bytes = if ($Body -is [byte[]]) { $Body }
                 else { [System.Text.Encoding]::UTF8.GetBytes([string]$Body) }
        $Res.ContentLength64 = $bytes.Length
        $Res.OutputStream.Write($bytes, 0, $bytes.Length)
    } finally {
        try { $Res.OutputStream.Close() } catch {}
    }
}

# ── Request loop ─────────────────────────────────────────────────────────────
while ($listener.IsListening) {
    $ctx = $null
    try { $ctx = $listener.GetContext() } catch { continue }

    $req  = $ctx.Request
    $res  = $ctx.Response
    $path = $req.Url.AbsolutePath

    # ── /api/quote?ticker=SPY  (Yahoo Finance proxy) ──────────────────────────
    if ($path -eq '/api/quote') {
        $ticker = $req.QueryString['ticker']
        if (-not $ticker) {
            Send-Response $res 400 'application/json' '{"error":"Missing ?ticker="}'
            continue
        }
        try {
            $url = "https://query1.finance.yahoo.com/v8/finance/chart/$([Uri]::EscapeDataString($ticker))?interval=1d&range=1d"
            $wr  = Invoke-WebRequest -Uri $url -UseBasicParsing -UserAgent 'Mozilla/5.0' -TimeoutSec 10
            Send-Response $res 200 'application/json' $wr.Content
        } catch {
            Send-Response $res 502 'application/json' "{`"error`":`"$($_.Exception.Message -replace '"','')`"}"
        }
        continue
    }

    # ── /api/startup GET  (check if auto-start is enabled) ────────────────────
    if ($path -eq '/api/startup' -and $req.HttpMethod -eq 'GET') {
        try {
            $out     = schtasks /Query /TN 'HyteTickerWidget' /FO LIST 2>$null
            $enabled = ($out -join '') -match 'Ready|Running'
        } catch { $enabled = $false }
        Send-Response $res 200 'application/json' "{`"enabled`":$($enabled.ToString().ToLower())}"
        continue
    }

    # ── /api/startup POST  (enable or disable auto-start) ─────────────────────
    if ($path -eq '/api/startup' -and $req.HttpMethod -eq 'POST') {
        try {
            $body    = (New-Object System.IO.StreamReader($req.InputStream)).ReadToEnd()
            $enable  = $body -match '"enabled"\s*:\s*true'
            $flag    = if ($enable) { '/ENABLE' } else { '/DISABLE' }
            schtasks /Change /TN 'HyteTickerWidget' $flag 2>&1 | Out-Null
            Send-Response $res 200 'application/json' "{`"ok`":true,`"enabled`":$($enable.ToString().ToLower())}"
        } catch {
            Send-Response $res 500 'application/json' "{`"error`":`"$($_.Exception.Message -replace '"','')`"}"
        }
        continue
    }

    # ── Static files ──────────────────────────────────────────────────────────
    $rel      = if ($path -eq '/') { 'index.html' } else { $path.TrimStart('/') }
    $fullPath = Join-Path $ScriptDir $rel

    # Prevent path traversal
    if (-not $fullPath.StartsWith($ScriptDir)) {
        Send-Response $res 403 'text/plain' 'Forbidden'
        continue
    }

    if (Test-Path $fullPath -PathType Leaf) {
        $ext  = [System.IO.Path]::GetExtension($fullPath)
        $mime = if ($MIME.ContainsKey($ext)) { $MIME[$ext] } else { 'application/octet-stream' }
        $bytes = [System.IO.File]::ReadAllBytes($fullPath)
        Send-Response $res 200 $mime $bytes
    } else {
        Send-Response $res 404 'text/plain' 'Not found'
    }
}
