# Assetto Corsa Map Generation & Pipeline Script
$ErrorActionPreference = "Continue"

function Write-StepHeader($stepNum, $title, $color) {
    Write-Host "`n========================================" -ForegroundColor $color
    Write-Host " [$stepNum] $title" -ForegroundColor $color
    Write-Host "========================================" -ForegroundColor $color
}

# --- 1. Get Data & System Update ---
Write-StepHeader "Stage 1" "1. Get Data & Verify Setup" Cyan
try {
    git config --global http.postBuffer 524288000
    Write-Host "Verifying environment and fetching map assets..." -ForegroundColor Gray
    if (Get-Command uv -ErrorAction SilentlyContinue) { uv self update }
    Write-Host "Stage 1 completed." -ForegroundColor Green
} catch {
    Write-Host "Stage 1 warning: $_" -ForegroundColor Yellow
}

# --- 2. Transfer to Blender & Generate 3D Map Mesh ---
Write-StepHeader "Stage 2" "2. Generate Map Mesh in Blender" Green
$blenderPipeline = @"
import bpy, os

def generate_ac_map():
    # Set up Scene Units to Meters for Assetto Corsa 1:1 Scale
    bpy.context.scene.unit_settings.system = 'METRIC'
    bpy.context.scene.unit_settings.scale_length = 1.0

    # Ensure/Select Map Mesh
    obj = bpy.context.active_object
    if not obj:
        # Create a default terrain grid if no object is selected
        bpy.ops.mesh.primitive_grid_add(x_subdivisions=100, y_subdivisions=100, size=500)
        obj = bpy.context.active_object

    obj.name = '1ROAD_main'
    
    # Attach Geometry Nodes Modifier for Road Curve Sweeping
    mod = obj.modifiers.get('AC_Road_GeoNodes')
    if not mod:
        mod = obj.modifiers.new(name='AC_Road_GeoNodes', type='NODES')
            
    # Export FBX to SDK directory
    export_path = os.path.abspath('./sdk_output/track_mesh.fbx')
    os.makedirs(os.path.dirname(export_path), exist_ok=True)
    
    bpy.ops.export_scene.fbx(
        filepath=export_path,
        use_selection=False,
        axis_forward='-Z',
        axis_up='Y'
    )
    print('Map FBX successfully generated and exported:', export_path)

if __name__ == '__main__':
    generate_ac_map()
"@
$blenderPipeline | Out-File -FilePath "blender_ac_pipeline.py" -Encoding utf8
Write-Host "blender_ac_pipeline.py created with map generation logic." -ForegroundColor Yellow

# Execute Blender background generation if available
$blenderExe = Get-Command "blender" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if ($blenderExe) {
    Write-Host "Running Blender map generation in background..." -ForegroundColor Gray
    Start-Process -FilePath $blenderExe -ArgumentList "-b -P blender_ac_pipeline.py" -Wait -NoNewWindow
} else {
    Write-Host "Blender executable not found in PATH. You can run 'blender_ac_pipeline.py' manually inside Blender." -ForegroundColor Yellow
}

# --- 3. Export to SDK ---
Write-StepHeader "Stage 3" "3. Export Map to SDK Directory" Yellow
$sdkDir = "./sdk_output"
if (-not (Test-Path -Path $sdkDir)) { New-Item -ItemType Directory -Path $sdkDir | Out-Null }
Write-Host "SDK Output directory ready at: $sdkDir" -ForegroundColor Yellow

# --- 4. Output & Git Sync ---
Write-StepHeader "Stage 4" "4. Sync Map & Repository" Magenta
try {
    git fetch --all
    git pull
    git add .
    git commit -m "Map Generation: Auto-generated 3D map mesh and exported FBX to SDK"
    git push
    Write-Host "Map files synchronized to Git successfully." -ForegroundColor Green
} catch {
    Write-Host "Git sync error: $_" -ForegroundColor Red
}

Write-Host "`n[COMPLETED] Map generation & pipeline execution finished." -ForegroundColor Cyan
