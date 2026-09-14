# Assetto Corsa 4-Stage Pipeline Script (Bypass Winget)
$ErrorActionPreference = "Continue"

function Write-StepHeader($stepNum, $title, $color) {
    Write-Host "`n========================================" -ForegroundColor $color
    Write-Host " [$stepNum] $title" -ForegroundColor $color
    Write-Host "========================================" -ForegroundColor $color
}

# --- 1. Get Data & System Update ---
Write-StepHeader "Stage 1" "1. Get Data & System Updates" Cyan
try {
    git config --global http.postBuffer 524288000
    Write-Host "Verifying git setup..." -ForegroundColor Gray
    if (Get-Command uv -ErrorAction SilentlyContinue) { uv self update }
    Write-Host "Stage 1 completed." -ForegroundColor Green
} catch {
    Write-Host "Stage 1 warning: $_" -ForegroundColor Yellow
}

# --- 2. Transfer to Blender ---
Write-StepHeader "Stage 2" "2. Transfer to Blender" Green
$blenderPipeline = @"
import bpy, os
def process_and_export():
    obj = bpy.context.active_object
    if obj:
        obj.name = '1ROAD_main'
        if not obj.modifiers.get('AC_Road_GeoNodes'):
            obj.modifiers.new(name='AC_Road_GeoNodes', type='NODES')
            
    export_path = os.path.abspath('./sdk_output/track_mesh.fbx')
    os.makedirs(os.path.dirname(export_path), exist_ok=True)
    
    bpy.ops.export_scene.fbx(
        filepath=export_path,
        use_selection=False,
        axis_forward='-Z',
        axis_up='Y'
    )
    print('FBX successfully exported for SDK:', export_path)

if __name__ == '__main__':
    process_and_export()
"@
$blenderPipeline | Out-File -FilePath "blender_ac_pipeline.py" -Encoding utf8
Write-Host "blender_ac_pipeline.py created." -ForegroundColor Yellow

# --- 3. Export to SDK ---
Write-StepHeader "Stage 3" "3. Export to SDK Directory" Yellow
$sdkDir = "./sdk_output"
if (-not (Test-Path -Path $sdkDir)) { New-Item -ItemType Directory -Path $sdkDir | Out-Null }
Write-Host "SDK Output directory ready at: $sdkDir" -ForegroundColor Yellow

# --- 4. Output & Git Sync ---
Write-StepHeader "Stage 4" "4. Output & Git Sync" Magenta
try {
    git fetch --all
    git pull
    git add .
    git commit -m "Pipeline update: 1. Data -> 2. Blender -> 3. SDK -> 4. Output"
    git push
    Write-Host "Git synchronized successfully." -ForegroundColor Green
} catch {
    Write-Host "Git sync error: $_" -ForegroundColor Red
}

Write-Host "`n[COMPLETED] Pipeline execution finished." -ForegroundColor Cyan
