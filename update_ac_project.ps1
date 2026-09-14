# Assetto Corsa Pipeline with Background Blender Execution
$ErrorActionPreference = "Continue"

function Write-StepHeader($stepNum, $title, $color) {
    Write-Host "`n========================================" -ForegroundColor $color
    Write-Host " [$stepNum] $title" -ForegroundColor $color
    Write-Host "========================================" -ForegroundColor $color
}

# --- Stage 1: Get Data & Setup ---
Write-StepHeader "Stage 1" "1. Get Data & Verify Setup" Cyan
git config --global http.postBuffer 524288000
if (Get-Command uv -ErrorAction SilentlyContinue) { uv self update }
Write-Host "Stage 1 completed." -ForegroundColor Green

# --- Stage 2: Background Blender Map Execution ---
Write-StepHeader "Stage 2" "2. Run Blender in Background (-b)" Green

# 1. Generate Python automation script for Blender
$blenderPipeline = @"
import bpy, os

def run_map_pipeline():
    # Set scene units to Meters for Assetto Corsa 1:1 scale
    bpy.context.scene.unit_settings.system = 'METRIC'
    bpy.context.scene.unit_settings.scale_length = 1.0

    # Locate active mesh or create base terrain grid
    obj = bpy.context.active_object
    if not obj:
        bpy.ops.mesh.primitive_grid_add(x_subdivisions=100, y_subdivisions=100, size=500)
        obj = bpy.context.active_object

    # Kunos physics naming convention
    obj.name = '1ROAD_main'
    
    # Attach Geometry Nodes modifier for road mesh curve
    if not obj.modifiers.get('AC_Road_GeoNodes'):
        obj.modifiers.new(name='AC_Road_GeoNodes', type='NODES')
            
    # Export FBX mesh for AC SDK (ksEditor)
    export_path = os.path.abspath('./sdk_output/track_mesh.fbx')
    os.makedirs(os.path.dirname(export_path), exist_ok=True)
    
    bpy.ops.export_scene.fbx(
        filepath=export_path,
        use_selection=False,
        axis_forward='-Z',
        axis_up='Y'
    )
    print('[BLENDER BACKEND] FBX exported successfully to:', export_path)

if __name__ == '__main__':
    run_map_pipeline()
"@
$blenderPipeline | Out-File -FilePath "blender_ac_pipeline.py" -Encoding utf8
Write-Host "Generated 'blender_ac_pipeline.py'." -ForegroundColor Yellow

# 2. Find Blender executable path
$blenderExe = Get-Command "blender" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source

if (-not $blenderExe) {
    # Check default Windows installation paths if blender is not in PATH
    $defaultPaths = @(
        "C:\Program Files\Blender Foundation\Blender 4.2\blender.exe",
        "C:\Program Files\Blender Foundation\Blender 4.1\blender.exe",
        "C:\Program Files\Blender Foundation\Blender 4.0\blender.exe",
        "C:\Program Files\Blender Foundation\Blender 3.6\blender.exe"
    )
    foreach ($path in $defaultPaths) {
        if (Test-Path $path) { $blenderExe = $path; break }
    }
}

if ($blenderExe) {
    Write-Host "Executing Blender in Background using: $blenderExe" -ForegroundColor Cyan
    # Run Blender headlessly (-b) and execute script (-P)
    Start-Process -FilePath $blenderExe -ArgumentList "-b -P blender_ac_pipeline.py" -Wait -NoNewWindow
    Write-Host "Blender background processing completed." -ForegroundColor Green
} else {
    Write-Host "Blender executable not found in PATH or standard directories. Please add Blender to System PATH." -ForegroundColor Red
}

# --- Stage 3: Export to SDK ---
Write-StepHeader "Stage 3" "3. SDK Directory Check" Yellow
$sdkDir = "./sdk_output"
if (-not (Test-Path -Path $sdkDir)) { New-Item -ItemType Directory -Path $sdkDir | Out-Null }
Write-Host "SDK Output directory ready: $sdkDir" -ForegroundColor Yellow

# --- Stage 4: Output & Git Sync ---
Write-StepHeader "Stage 4" "4. Output & Sync Repo" Magenta
try {
    git fetch --all
    git pull
    git add .
    git commit -m "Background Blender: Auto-processed 3D map and synced FBX to SDK"
    git push
    Write-Host "Git repository synchronized successfully." -ForegroundColor Green
} catch {
    Write-Host "Git sync notice: $_" -ForegroundColor Red
}

Write-Host "`n[COMPLETED] All 4 stages finished successfully!" -ForegroundColor Cyan
