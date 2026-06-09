# Starts a local web server and exposes it via a public Cloudflare tunnel.
# Keep this window open while sharing the link.

$ProjectRoot = $PSScriptRoot
$Port = 8080
$Cloudflared = "C:\Program Files (x86)\cloudflared\cloudflared.exe"

Write-Host ""
Write-Host "Starting I-Love-You web app..." -ForegroundColor Cyan
Write-Host "Project: $ProjectRoot"
Write-Host ""

# Stop any existing server on this port
Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue |
    ForEach-Object { Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue }

Start-Process python -ArgumentList "-m", "http.server", $Port, "-d", "`"$ProjectRoot`"" -WindowStyle Hidden
Start-Sleep -Seconds 2

Write-Host "Local server running at http://localhost:$Port" -ForegroundColor Green
Write-Host ""
Write-Host "Creating public link (keep this window open)..." -ForegroundColor Yellow
Write-Host ""

if (-not (Test-Path $Cloudflared)) {
    Write-Host "cloudflared not found. Install it with:" -ForegroundColor Red
    Write-Host "  winget install Cloudflare.cloudflared"
    exit 1
}

& $Cloudflared tunnel --url "http://localhost:$Port"
