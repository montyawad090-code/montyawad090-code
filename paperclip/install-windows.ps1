# Windows half of the Paperclip setup: installs WSL2 + Ubuntu and enables
# mirrored networking (so a phone on Tailscale can reach Paperclip later).
#
# Run in PowerShell *as Administrator*:
#   irm https://raw.githubusercontent.com/montyawad090-code/montyawad090-code/main/paperclip/install-windows.ps1 | iex
#
# Safe to run again: it skips anything already done.

$ErrorActionPreference = 'Stop'

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host 'Please re-open PowerShell with "Run as administrator" and run this again.' -ForegroundColor Red
    return
}

# 1. .wslconfig with mirrored networking
$cfg = Join-Path $env:USERPROFILE '.wslconfig'
if (-not (Test-Path $cfg)) {
    Set-Content -Path $cfg -Value "[wsl2]`nnetworkingMode=mirrored"
    Write-Host "Created $cfg" -ForegroundColor Green
} else {
    $text = Get-Content $cfg -Raw
    if ($text -match 'networkingMode') {
        Write-Host "$cfg already sets networkingMode; leaving it alone." -ForegroundColor Yellow
    } elseif ($text -match '\[wsl2\]') {
        Set-Content -Path $cfg -Value ($text -replace '\[wsl2\]', "[wsl2]`nnetworkingMode=mirrored")
        Write-Host "Added networkingMode=mirrored to $cfg" -ForegroundColor Green
    } else {
        Add-Content -Path $cfg -Value "`n[wsl2]`nnetworkingMode=mirrored"
        Write-Host "Added a [wsl2] section to $cfg" -ForegroundColor Green
    }
}

# 2. WSL2 + Ubuntu
$distros = ''
try { $distros = (wsl.exe -l -q 2>$null) -join ' ' -replace "`0", '' } catch { }
if ($distros -match 'Ubuntu') {
    Write-Host 'Ubuntu is already installed in WSL.' -ForegroundColor Green
    wsl.exe --shutdown
    $needsRestart = $false
} else {
    Write-Host 'Installing WSL2 and Ubuntu (this can take a few minutes)...' -ForegroundColor Cyan
    wsl.exe --install -d Ubuntu
    $needsRestart = $true
}

Write-Host ''
if ($needsRestart) {
    Write-Host '1. Restart your PC now.' -ForegroundColor Cyan
    Write-Host '2. After restart, open "Ubuntu" from the Start menu and create a username + password.'
} else {
    Write-Host '1. Open "Ubuntu" from the Start menu.'
}
Write-Host '3. Paste this into Ubuntu:'
Write-Host '   curl -fsSL https://raw.githubusercontent.com/montyawad090-code/montyawad090-code/main/paperclip/install-wsl.sh | bash' -ForegroundColor Yellow
