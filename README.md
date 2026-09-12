# Hong Kong 1:1 Assetto Corsa

This repository is the starting point for a 1:1-scale Hong Kong free-roam map and
an Assetto Corsa dedicated server that hosts it.

The repository contains source-controlled planning and server configuration. It
does **not** contain third-party map data, copyrighted imagery, Assetto Corsa
game files, or the `acServer.exe` binary.

## Repository layout

```text
docs/
  map-production-plan.md   Terrain, roads, references, and build milestones
server/
  cfg/
    server_cfg.ini         Main Assetto Corsa server configuration
    entry_list.ini         Starting grid / driver slots
  start-server.ps1         Launches the server from a local AC installation
  validate-config.ps1      Checks required configuration values
```

## Quick start

1. Install Assetto Corsa and the official Assetto Corsa Dedicated Server
   through Steam Tools.
2. Copy the contents of `server/cfg` into the dedicated server's `cfg`
   directory, or use the `-c` option to point the server at this directory.
3. Build or install the track at:

   ```text
   content/tracks/hong_kong_1to1/
   ```

4. Put the track's server-compatible `surfaces.ini` and collision meshes in
   the track package.
5. Edit `server/cfg/server_cfg.ini` and `server/cfg/entry_list.ini`.
6. Run the validation script, then start the server:

   ```powershell
   .\server\validate-config.ps1
   .\server\start-server.ps1 -ServerRoot "C:\ACServer"
   ```

The default server is private (`REGISTER_TO_LOBBY=0`) until the track has been
tested. Set it to `1` only after port forwarding and server moderation are ready.

## Scope and licensing

Use openly licensed or self-created source material and verify the terms before
redistributing any derived asset. See `docs/map-production-plan.md` for the
recommended data and attribution workflow.
