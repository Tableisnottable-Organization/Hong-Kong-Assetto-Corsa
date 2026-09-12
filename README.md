# Hong Kong Assetto Corsa

An Assetto Corsa project for a 1:1-scale driving map of Hong Kong. The current
production slice is the HP1C Tin Kwong Road driving-test corridor in Kowloon,
with the wider target of a road network covering Tsim Sha Tsui, Mong Kok, and
Kowloon Bay.

## Project scope

- **Map:** real-world-scale Kowloon roads built from geospatial data.
- **Current route:** Tin Kwong Road routes one, two, and three.
- **Vehicles:** original, legally distributable models representing cars seen
  in Hong Kong. The first hero vehicle is a Hong Kong Crown Comfort taxi.
- **Target game:** Assetto Corsa on PC.

The repository stores source data, Blender tooling, configuration, and
documentation. Generated meshes, textures, and KN5 files remain out of Git
unless they are small enough to review and redistribute.

## Current map pipeline

The HP1C map is exported by survey-sheet tile. Each tile is a separate KN5
model and `tile_manifest.json` records its load order. Keep each model below
the 1.5 GB target, with 2 GB treated as the hard single-file limit. Split a
tile only when it exceeds that limit, using names such as
`11-SW-9D-1.kn5`.

Generate the Blender prototype:

```powershell
blender --background --python tools\blender\generate_tin_kwong.py
```

Or run the guarded download-and-build flow:

```powershell
.\tools\build_map.ps1
```

The downloader uses a local cache, one request at a time, a minimum 15-second
interval, and backoff retries. It does not scrape Google Maps or Street View.
Blender and ksEditor must be installed separately for KN5 export. If ksEditor
has no usable command-line export mode, use:

```powershell
.\tools\desktop_export.ps1
```

That helper requires explicit `EXPORT` confirmation, avoids blind mouse
coordinates and overwrites, and leaves final KN5 confirmation to the user.

## Production plan

The broader map build order, scale rules, vehicle requirements, and quality
gates are documented in [`docs/production-plan.md`](docs/production-plan.md).
The map and fleet manifests live in `config/`.

Do not rip assets from commercial games or use unlicensed manufacturer CAD.
Keep OSM attribution with every exported release, and treat real-world
branding as replaceable until permission is available.

## Repository layout

```text
config/                 Project scope and asset manifests
docs/                   Production and contribution notes
tools/                  GIS, Blender, and export helpers
asset/                  Assetto Corsa package files and route data
build/                  Generated exports (ignored by Git)
source/                 Source GIS, reference, and Blender files
```
