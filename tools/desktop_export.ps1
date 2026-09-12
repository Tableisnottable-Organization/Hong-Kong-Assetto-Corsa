param(
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$blend = Join-Path $root "build\HP1C\tin_kwong_road\tin_kwong_road_blockout.blend"
$fbx = Join-Path $root "build\HP1C\tin_kwong_road\11-SW-9D.fbx"
$blender = "C:\Program Files\Blender Foundation\Blender 5.1\blender.exe"
$ksEditor = "A:\SteamLibrary\steamapps\common\assettocorsa\sdk\editor\ksEditor.exe"

if (-not (Test-Path $blend)) { throw "Blend file not found: $blend" }
if (-not (Test-Path $blender)) { throw "Blender not found: $blender" }
if (-not (Test-Path $ksEditor)) { throw "ksEditor not found: $ksEditor" }

Write-Host "This helper will open Blender and ksEditor only. It will not click unknown UI controls."
Write-Host "Press Ctrl+C to stop. Existing files will not be overwritten."
if (-not $DryRun) {
    $answer = Read-Host "Continue? Type EXPORT"
    if ($answer -cne "EXPORT") { throw "Cancelled." }
}

$exportScript = Join-Path $root "tools\blender\export_tin_kwong_fbx.py"
& $blender --background $blend --python $exportScript -- --output $fbx
if ($LASTEXITCODE -ne 0) { throw "Blender FBX export failed." }
if (-not (Test-Path $fbx)) { throw "Blender did not create the FBX: $fbx" }

Write-Host "FBX created: $fbx"
Write-Host "Opening ksEditor. In ksEditor, open the FBX and export it as 11-SW-9D.kn5."
if (-not $DryRun) {
    Start-Process -FilePath $ksEditor -WorkingDirectory (Split-Path $ksEditor)
}
