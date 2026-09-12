# Hong Kong Assetto Corsa

An Assetto Corsa project for a 1:1-scale driving map of Kowloon, initially
covering Tsim Sha Tsui, Mong Kok, and Kowloon Bay.

## Project scope

- **Map:** Kowloon road network, built at real-world scale from geospatial data.
- **Initial area:** Tsim Sha Tsui -> Mong Kok -> Kowloon Bay.
- **Vehicles:** a growing set of original, legally distributable models
  representing cars that are commonly seen in Hong Kong. The first vehicle
  target is the Hong Kong Toyota Crown Comfort taxi.
- **Target game:** Assetto Corsa on PC.

The repository stores source data, Blender tooling, configuration, and
documentation. Generated meshes, textures, and KN5 files should remain out of
Git unless they are small enough to review and redistribute.

## Current status

This is the production scaffold. No map or vehicle mesh has been generated yet.
The build order and required inputs are documented in
[`docs/production-plan.md`](docs/production-plan.md).

## Source-data rules

Use OpenStreetMap or another source whose license permits redistribution, and
keep attribution with every exported release. Do not rip assets from Google
Maps, Street View, commercial games, or manufacturer websites. Real-world
vehicle names and logos may require separate permission; use original geometry
and replaceable branding for public releases.

## Repository layout

```text
config/                 Project scope and asset manifests
docs/                   Production and contribution notes
tools/blender/          Blender-side export helpers
content/tracks/         Local Assetto Corsa track package files
content/cars/           Local Assetto Corsa car package files
source/                 Source GIS, reference, and Blender files
build/                  Generated exports (ignored by Git)
```

## First milestone

1. Export the selected Kowloon road network and validate scale.
2. Produce a drivable greybox with named sectors and collision.
3. Create the taxi as an original low-poly-to-high-poly vehicle asset.
4. Export both assets to KN5 and validate them in Assetto Corsa.

