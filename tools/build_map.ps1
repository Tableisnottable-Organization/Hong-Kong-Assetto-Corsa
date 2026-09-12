$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root

Write-Host "[1/3] Downloading road data..."
# fetch_hk_data.py intentionally performs at most one request and uses a local cache.
python tools\fetch_hk_data.py
if ($LASTEXITCODE -ne 0) { throw "Source download failed." }

$blender = Get-Command blender -ErrorAction SilentlyContinue
if ($null -eq $blender) {
    $blenderPath = "C:\Program Files\Blender Foundation\Blender 5.1\blender.exe"
    if (Test-Path $blenderPath) { $blender = Get-Item $blenderPath }
}
if ($null -eq $blender) {
    throw "Blender was not found on PATH. Install Blender, then rerun tools\build_map.ps1."
}

Write-Host "[2/3] Generating Blender source model..."
& $blender.FullName --background --python tools\blender\generate_tin_kwong.py
if ($LASTEXITCODE -ne 0) { throw "Blender generation failed." }

$kseditor = Get-Command ksEditor -ErrorAction SilentlyContinue
if ($null -eq $kseditor) {
    $ksEditorPath = "A:\SteamLibrary\steamapps\common\assettocorsa\sdk\editor\ksEditor.exe"
    if (Test-Path $ksEditorPath) { $kseditor = Get-Item $ksEditorPath }
}
if ($null -eq $kseditor) {
    throw "ksEditor was not found on PATH or the configured SDK path. The .blend was generated, but KN5 export cannot run."
}

Write-Host "[3/3] KN5 export requires an installed ksEditor profile."
Write-Host "ksEditor found at $($kseditor.FullName). Use the generated blend and HP1C source manifest to export 11-SW-9D.kn5."
