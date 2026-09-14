# Auto-Elevate to Administrator if not running as Admin
$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
if (-not $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting Administrator privileges..." -ForegroundColor Yellow
    $powershell = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
    Start-Process $powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

$ErrorActionPreference = "Continue"
$targetDir = "C:\Users\Table\Documents\GitHub\Hong-Kong-Assetto-Corsa\auto\v1"
Set-Location $targetDir

$BLENDER_EXE = "C:\Program Files\Blender Foundation\Blender 4.2\blender.exe"
$PROJECT_DIR = $PSScriptRoot
$BUILD_DIR   = Join-Path $PROJECT_DIR "build"
$FBX_PATH    = Join-Path $BUILD_DIR "map.fbx"
$KN5_PATH    = Join-Path $BUILD_DIR "hk_road.kn5"
$AC_TRACKS_DIR = "C:\Program Files (x86)\Steam\steamapps\common\assettocorsa\content\tracks\hk_road"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " RUNNING AUTO BUILD IN auto\v1 (ADMIN)          " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

Write-Host "
[1/4] Running CSDI Data Processing..." -ForegroundColor Yellow
if (Test-Path "$PROJECT_DIR\scripts\process_csdi.py") {
    python "$PROJECT_DIR\scripts\process_csdi.py"
}

Write-Host "
[2/4] Exporting FBX via Blender..." -ForegroundColor Yellow
if (Test-Path "$PROJECT_DIR\map_source.blend") {
    & $BLENDER_EXE -b "$PROJECT_DIR\map_source.blend" -P "$PROJECT_DIR\scripts\blender_export.py"
}

Write-Host "
[3/4] Converting FBX to KN5..." -ForegroundColor Yellow
if (Test-Path "$PROJECT_DIR\tools\kn5-conv.exe") {
    & "$PROJECT_DIR\tools\kn5-conv.exe" --input $FBX_PATH --output $KN5_PATH
}

Write-Host "
[4/4] Deploying to Assetto Corsa Directory..." -ForegroundColor Yellow
if (-not (Test-Path $AC_TRACKS_DIR)) { 
    New-Item -ItemType Directory -Force -Path $AC_TRACKS_DIR | Out-Null 
}

if (Test-Path $KN5_PATH) { 
    Copy-Item $KN5_PATH -Destination (Join-Path $AC_TRACKS_DIR "hk_road.kn5") -Force 
}

if (Test-Path "$PROJECT_DIR\templates") {
    Copy-Item "$PROJECT_DIR\templates\*" -Destination $AC_TRACKS_DIR -Recurse -Force
}

Write-Host "
==================================================" -ForegroundColor Green
Write-Host " SUCCESS! Map built and installed in Assetto Corsa." -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

Write-Host "
"
Read-Host -Prompt "Press Enter to exit"
