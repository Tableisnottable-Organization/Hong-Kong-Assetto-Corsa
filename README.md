# Hong Kong 1:1 Assetto Corsa

This repository is the starting point for a 1:1-scale Hong Kong free-roam map
and an Assetto Corsa dedicated server that hosts it. The current map prototype
targets the HP1C sheet `11-SW-9D` and the Tin Kwong Road driving-test routes.

The repository contains source-controlled planning, map-generation tooling, and
server configuration. It does **not** contain third-party map data,
copyrighted imagery, Assetto Corsa game files, or the `acServer.exe` binary.

## Repository layout

```text
asset/assetto_corsa/tin_kwong_road/  Assetto Corsa track package skeleton
asset/routes/                         Route definitions
build/HP1C/                           Generated prototype output and manifests
docs/                                 Map production plan
server/cfg/                           Dedicated-server configuration
tools/                                Data download, Blender, and export scripts
```

## Build the map prototype

From the repository root:

```powershell
.\tools\build_map.ps1
```

The workflow downloads the required OSM road data to `build\HP1C\source\`
using local caching, one request at a time, a minimum 15-second interval, and
backoff retries. Existing cached data is reused. It then invokes Blender to
generate the road blockout and manifests.

Blender and ksEditor must be installed separately and available on `PATH` for
the full export workflow. The current output is a road blockout, not a finished
KN5. Add surveyed/GIS road points, terrain, buildings, collision, AI lines,
and final tile exports before using it as a released track.

If ksEditor needs interactive export, use:

```powershell
.\tools\desktop_export.ps1
```

The helper requires explicit `EXPORT` confirmation, avoids blind mouse
automation, and does not overwrite files without confirmation.

## Track tiling and scale

Use metres as the authoring unit and preserve the HP1C sheet boundary. Each
sheet should produce an independent KN5 model recorded in `tile_manifest.json`.
Target 1.5 GB per model with a hard working limit of 2 GB. Only split an
oversized sheet, using names such as:

```text
11-SW-9D.kn5
11-SW-9D-1.kn5
11-SW-9D-2.kn5
```

Do not combine all Hong Kong roads, terrain, and buildings into one model.
See `docs/map-production-plan.md` for the broader production and quality gates.

## Dedicated server

1. Install the official Assetto Corsa Dedicated Server through Steam Tools.
2. Build or install the track at:

   ```text
   content/tracks/hong_kong_1to1/
   ```

3. Edit `server/cfg/server_cfg.ini` and `server/cfg/entry_list.ini`.
4. Validate and start the server:

   ```powershell
   .\server\validate-config.ps1
   .\server\start-server.ps1 -ServerRoot "C:\ACServer"
   ```

The default server is private (`REGISTER_TO_LOBBY=0`) until the track has been
tested. Set it to `1` only after port forwarding and server moderation are ready.

## Data and licensing

The route reference is the [TODS Kowloon driving-test route
page](https://www.driving.com.hk/exam-routes-kowloon), updated in 2021. Recheck
road positions, directions, and traffic facilities against current survey data
before release. Use openly licensed or self-created source material and verify
redistribution terms for every derived asset.
