$ErrorActionPreference = "Continue"
$BLENDER_EXE = "C:\Program Files\Blender Foundation\Blender 4.2\blender.exe"
$PROJECT_DIR = $PSScriptRoot
$BUILD_DIR   = Join-Path $PROJECT_DIR "build"
$FBX_PATH    = Join-Path $BUILD_DIR "map.fbx"
$KN5_PATH    = Join-Path $BUILD_DIR "hk_road.kn5"
$AC_TRACKS_DIR = "C:\Program Files (x86)\Steam\steamapps\common\assettocorsa\content\tracks\hk_road"

Write-Host "Running CSDI Data Processing..." -ForegroundColor Yellow
python "$PROJECT_DIR\scripts\process_csdi.py"

Write-Host "Exporting FBX via Blender..." -ForegroundColor Yellow
if (Test-Path "$PROJECT_DIR\map_source.blend") {
    & $BLENDER_EXE -b "$PROJECT_DIR\map_source.blend" -P "$PROJECT_DIR\scripts\blender_export.py"
}

Write-Host "Converting FBX to KN5..." -ForegroundColor Yellow
if (Test-Path "$PROJECT_DIR\tools\kn5-conv.exe") {
    & "$PROJECT_DIR\tools\kn5-conv.exe" --input $FBX_PATH --output $KN5_PATH
}

Write-Host "Deploying to Assetto Corsa..." -ForegroundColor Yellow
if (-not (Test-Path $AC_TRACKS_DIR)) { New-Item -ItemType Directory -Force -Path $AC_TRACKS_DIR | Out-Null }
if (Test-Path $KN5_PATH) { Copy-Item $KN5_PATH -Destination (Join-Path $AC_TRACKS_DIR "hk_road.kn5") -Force }
Copy-Item "$PROJECT_DIR\templates\*" -Destination $AC_TRACKS_DIR -Recurse -Force

Write-Host "
Build and Deployment Complete!" -ForegroundColor Green
Read-Host -Prompt "Press Enter to exit"
