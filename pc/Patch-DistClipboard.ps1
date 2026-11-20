# Patch-DistClipboard.ps1
# Xiaomi HyperConnect (Xiaomi Interconnect) 2.0.4.577  /  dist_clipboard 1.0.4.6
# Removes the phone-only filter (device_types=[1]) from the universalClipboard service
# listener so that Xiaomi Pads (device_type=2) can send clipboard text/images to the PC.
#   file offset 0xE2E53 : E8 88 39 00 00  ->  0F 1F 44 00 00
# Run in Windows PowerShell 5.1 as Administrator:
#   powershell -ExecutionPolicy Bypass -File .\Patch-DistClipboard.ps1
#   powershell -ExecutionPolicy Bypass -File .\Patch-DistClipboard.ps1 -Rollback
param([switch]$Rollback)

$ErrorActionPreference = 'Stop'
$Version  = '2.0.4.577'
$Offset   = 0xE2E53
$OrigByte = [byte[]](0xE8,0x88,0x39,0x00,0x00)
$NewByte  = [byte[]](0x0F,0x1F,0x44,0x00,0x00)
$OrigHash = '87E70C317B2A1DA44CAA179350CF849FE47B2D152E6FB5D11857EC5AADFFB290'
$NewHash  = 'DC128FB596756BDBF1CB3D753F0BDE52FB5B92E6C9838587BE24A186A1B25301'

function Fail($msg) { Write-Host $msg -ForegroundColor Red; exit 1 }

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { Fail 'Please run PowerShell as Administrator.' }

# Locate install folder (registry first, default path as fallback)
$keys = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
$app = Get-ItemProperty $keys -ErrorAction SilentlyContinue |
       Where-Object { $_.InstallLocation -match 'HyperConnect' } | Select-Object -First 1
$root = $null
if ($app) { $root = $app.InstallLocation.TrimEnd('\') }
if (-not $root -or -not (Test-Path $root)) { $root = "C:\Program Files\MI\HyperConnect\$Version" }
if ($root -notmatch [regex]::Escape($Version)) { Fail "Installed version is not $Version ($root). This script only supports $Version." }

$dir    = Join-Path $root 'resources\native-interconnect\win32'
$target = Join-Path $dir 'dist_clipboard.dll'
$backup = Join-Path $dir 'dist_clipboard.dll.orig'
if (-not (Test-Path $target)) { Fail "Not found: $target" }

function Stop-HyperConnect {
    Get-Process -Name 'hyperConnect','MiPcContinuity','MiScreenShare' -ErrorAction SilentlyContinue |
        ForEach-Object { Write-Host "Stopping $($_.Name) ($($_.Id))"; Stop-Process -Id $_.Id -Force }
    Start-Sleep -Seconds 3
}

$cur = (Get-FileHash $target -Algorithm SHA256).Hash

if ($Rollback) {
    if (-not (Test-Path $backup)) { Fail "Backup not found: $backup" }
    if ((Get-FileHash $backup -Algorithm SHA256).Hash -ne $OrigHash) { Fail 'Backup hash mismatch, abort.' }
    Stop-HyperConnect
    Copy-Item $backup $target -Force
    Write-Host "Restored original: $($OrigHash.Substring(0,8))..." -ForegroundColor Green
    exit 0
}

if ($cur -eq $NewHash) { Write-Host "Already patched: $($NewHash.Substring(0,8))..." -ForegroundColor Green; exit 0 }
if ($cur -ne $OrigHash) { Fail "dist_clipboard.dll hash $cur is not the $Version original. Abort." }

$bytes = [System.IO.File]::ReadAllBytes($target)
for ($i = 0; $i -lt 5; $i++) { if ($bytes[$Offset + $i] -ne $OrigByte[$i]) { Fail 'Byte pattern mismatch at patch offset. Abort.' } }
for ($i = 0; $i -lt 5; $i++) { $bytes[$Offset + $i] = $NewByte[$i] }

Stop-HyperConnect
if (-not (Test-Path $backup)) { Copy-Item $target $backup -Force; Write-Host "Backup: $backup" }
[System.IO.File]::WriteAllBytes($target, $bytes)

$final = (Get-FileHash $target -Algorithm SHA256).Hash
if ($final -ne $NewHash) {
    Copy-Item $backup $target -Force
    Fail "Verify failed ($final). Original restored."
}
Write-Host "Installed: $($NewHash.Substring(0,8))..." -ForegroundColor Green
Write-Host 'Now start Xiaomi HyperConnect again (or reboot).'
