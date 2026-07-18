@echo off
powershell -NoProfile -ExecutionPolicy Bypass -Command "IEX (Get-Content '%~f0' | Select-Object -Skip 3 | Out-String -Width 4096)"
exit /b
# ============================================================
#   POSTALANNEX+ AMAZON QR CODE SCANNER - INSTALLER / UPDATER
#   Downloads the latest app.html from GitHub. Contains NO app
#   code, so app.html in the repo is the single source of truth.
#   Re-run this file any time to update to the latest version.
# ============================================================

# --- Network hardening for Windows PowerShell 5.1 ---
# GitHub refuses connections below TLS 1.2; PS 5.1 does not enable it by default.
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
# Suppress the Invoke-WebRequest progress bar (it dominates runtime and looks like a hang on PS 5.1).
$ProgressPreference = 'SilentlyContinue'
# Route through the system proxy with the logged-in user's credentials, if any.
try { [System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials } catch {}

$AppUrl     = 'https://raw.githubusercontent.com/KingDomino/QR-CONVERTER-PA-AZ/main/app.html'
$InstallDir = Join-Path $env:LOCALAPPDATA 'PostalAnnex-Scanner'
$AppPath    = Join-Path $InstallDir 'app.html'
$TmpPath    = Join-Path $InstallDir 'app.download.tmp'

function Fail($msg) {
    Write-Host ''
    Write-Host '----------------------------------------------------' -ForegroundColor Red
    Write-Host 'INSTALL FAILED' -ForegroundColor Red
    Write-Host $msg -ForegroundColor Red
    Write-Host '----------------------------------------------------' -ForegroundColor Red
    Write-Host ''
    Read-Host 'Press Enter to close'
    exit 1
}

Write-Host '====================================================' -ForegroundColor Green
Write-Host '   POSTALANNEX+ AMAZON QR SCANNER - INSTALL/UPDATE  ' -ForegroundColor Green
Write-Host '====================================================' -ForegroundColor Green
Write-Host ''

# 1. Ensure the per-user install folder (LOCALAPPDATA needs no admin/UAC).
Write-Host 'Preparing application folder...'
if (-not (Test-Path $InstallDir)) {
    try { New-Item -ItemType Directory -Path $InstallDir -ErrorAction Stop | Out-Null }
    catch { Fail ("Could not create the application folder: " + $_.Exception.Message) }
}

# 2. Download the latest app.html to a temp file IN THE SAME FOLDER so the
#    final promotion is an atomic same-volume rename.
Write-Host 'Downloading the latest scanner from GitHub...'
try {
    Invoke-WebRequest -Uri $AppUrl -OutFile $TmpPath -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
} catch {
    $m = $_.Exception.Message
    Remove-Item $TmpPath -Force -ErrorAction SilentlyContinue
    if ($m -match 'trust relationship|SSL/TLS secure channel') {
        Fail ("Secure connection was blocked. Your network may inspect HTTPS - ask IT to trust the corporate root certificate on this PC. Also confirm the PC date and time are correct. Details: " + $m)
    }
    Fail ("Could not download the app. Check the internet connection and try again. Details: " + $m)
}

# 3. Validate what was downloaded BEFORE touching the working copy. A captive
#    portal / proxy login page is valid HTML, so check app-specific markers.
$ok = $false
try {
    if ((Get-Item $TmpPath).Length -gt 20KB) {
        $content = Get-Content $TmpPath -Raw
        if ($content -match '<title>PostalAnnex\+ Amazon QR Code Scanner</title>' -and $content -match 'id="textInput"' -and $content -match '</html>') {
            $ok = $true
        }
    }
} catch {}
if (-not $ok) {
    Remove-Item $TmpPath -Force -ErrorAction SilentlyContinue
    Fail 'The download did not look like the scanner app (a login or content-filter page may have been returned). Your existing app was left unchanged.'
}

# 4. Atomically promote the temp file onto app.html (same volume = atomic rename).
try { Move-Item -Path $TmpPath -Destination $AppPath -Force -ErrorAction Stop }
catch { Fail ("Could not save the app file: " + $_.Exception.Message) }

# file:/// URL for the shortcut; encode spaces so usernames with spaces still work.
$fileUrl = 'file:///' + (($AppPath -replace '\\','/') -replace ' ','%20')

# 5. Locate Microsoft Edge (probe both Program Files roots, then App Paths).
$edge = $null
$edgeCandidates = @()
if ($env:ProgramFiles)        { $edgeCandidates += (Join-Path $env:ProgramFiles 'Microsoft\Edge\Application\msedge.exe') }
if (${env:ProgramFiles(x86)}) { $edgeCandidates += (Join-Path ${env:ProgramFiles(x86)} 'Microsoft\Edge\Application\msedge.exe') }
foreach ($p in $edgeCandidates) { if (Test-Path $p) { $edge = $p; break } }
if (-not $edge) {
    try {
        $reg = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe'
        if (Test-Path $reg) { $edge = (Get-ItemProperty $reg -ErrorAction Stop).'(default)' }
    } catch {}
}

# 6. Create Desktop + Start Menu shortcuts to the LOCAL file (each best-effort).
function New-EdgeShortcut($lnkPath) {
    $ws = New-Object -ComObject WScript.Shell
    $sc = $ws.CreateShortcut($lnkPath)
    $sc.TargetPath   = $edge
    $sc.Arguments    = "--app=$fileUrl"
    $sc.IconLocation = "$edge,0"
    $sc.Save()
}
$madeShortcut = $false
if ($edge) {
    Write-Host 'Creating Desktop and Start Menu shortcuts...'
    try { New-EdgeShortcut (Join-Path ([Environment]::GetFolderPath('Desktop'))  'Amazon QR Code Scanner.lnk'); $madeShortcut = $true }
    catch { Write-Host ("  (Could not create Desktop shortcut: " + $_.Exception.Message + ")") -ForegroundColor Yellow }
    try { New-EdgeShortcut (Join-Path ([Environment]::GetFolderPath('Programs')) 'Amazon QR Code Scanner.lnk'); $madeShortcut = $true }
    catch { Write-Host ("  (Could not create Start Menu shortcut: " + $_.Exception.Message + ")") -ForegroundColor Yellow }
} else {
    Write-Host '  (Microsoft Edge was not found - shortcuts skipped.)' -ForegroundColor Yellow
    Write-Host ("   The app is installed at: " + $AppPath) -ForegroundColor Yellow
}

Write-Host ''
Write-Host '====================================================' -ForegroundColor Green
Write-Host 'SUCCESS: The scanner is installed and up to date.' -ForegroundColor Green
Write-Host ('Location: ' + $AppPath) -ForegroundColor Green
if ($madeShortcut) {
    Write-Host "Open 'Amazon QR Code Scanner' from the Desktop or Start Menu." -ForegroundColor Green
} else {
    Write-Host ('Open the app directly at: ' + $AppPath) -ForegroundColor Green
}
Write-Host 'If it was already open, close and reopen it to load the new version.' -ForegroundColor Green
Write-Host 'Re-run this installer any time to update to the latest version.' -ForegroundColor Green
Write-Host '====================================================' -ForegroundColor Green
Write-Host ''
Read-Host 'Press Enter to exit'
