# Hong Kong 1:1 Assetto Corsa / 香港 1:1 Assetto Corsa

This project aims to create a full Hong Kong 1:1 map for Assetto Corsa. The long-term goal is to cover the territory as an accurate, drivable virtual environment, not just a single road or route.

This repository is the starting point for a 1:1-scale Hong Kong free-roam map and the related map-generation workflow. The current prototype targets the HP1C sheet `11-SW-9D` and the Tin Kwong Road driving-test routes, with a wider target of roads covering Tsim Sha Tsui, Mong Kok, and Kowloon Bay.

## Project scope / 專案範圍

- **Map:** real-world-scale Kowloon roads built from geospatial data.
- **Current route:** Tin Kwong Road routes one, two, and three.
- **Target game:** Assetto Corsa on PC.
- **Vehicles:** original, legally distributable models representing cars seen in Hong Kong. The first hero vehicle is a Hong Kong Crown Comfort taxi.

- **地圖：** 以真實尺度建構九龍道路的地理空間資料。
- **現階段路線：** 天光道一、二、三考試路線。
- **目標遊戲：** PC 上的 Assetto Corsa。
- **車輛：** 原創、可合法分發的香港道路車輛模型，首部主角車為香港皇冠計程車。

The repository contains source-controlled planning, map-generation tooling, vehicle manifests, and server configuration. It does not include third-party map data, copyrighted imagery, Assetto Corsa game files, or the `acServer.exe` binary. Generated meshes, textures, and KN5 files remain out of Git unless they are small enough to review and redistribute.

本倉庫包含版本控制的規劃文件、地圖生成工具、車輛清單與伺服器配置。它不包含第三方地圖資料、受版權保護的影像、Assetto Corsa 遊戲檔案或 `acServer.exe` 執行檔。生成的網格、紋理與 KN5 檔案不會放進 Git，除非足夠小以便審查與重新分發。

## Repository layout / 倉庫結構

```text
config/                              Map and vehicle manifests
asset/assetto_corsa/tin_kwong_road/  Assetto Corsa track package skeleton
asset/routes/                         Route definitions
build/HP1C/                           Generated prototype output and manifests
docs/                                 Map production plan
server/cfg/                           Dedicated-server configuration
tools/                                Data download, Blender, and export scripts
```

## Build the map prototype / 建立地圖原型

From the repository root:

```powershell
.\tools\build_map.ps1
```

The workflow downloads the required OSM road data to `build\HP1C\source\` using local caching, one request at a time, a minimum 15-second interval, and backoff retries. Existing cached data is reused. It then invokes Blender to generate the road blockout and manifests.

Blender and ksEditor must be installed separately and available on `PATH` for the full export workflow. The current output is a road blockout, not a finished KN5. Add surveyed/GIS road points, terrain, buildings, collision, AI lines, and final tile exports before using it as a released track.

If ksEditor needs interactive export, use:

```powershell
.\tools\desktop_export.ps1
```

The helper requires explicit `EXPORT` confirmation, avoids blind mouse automation, and does not overwrite files without confirmation.

流程會先從 Overpass API 下載需要的 OSM 道路 GeoJSON 到 `build\HP1C\source\`。下載器使用本地快取、一次只發一個請求、請求間隔至少 15 秒，失敗時以退避方式重試；已存在快取資料時會直接重用。完成後再呼叫 Blender 生成道路 blockout 與地圖清單。

要完整匯出 KN5，Blender 和 ksEditor 必須另外安裝好，並加入 `PATH`。目前輸出仍是道路 blockout，不是已完成的 KN5。正式使用前，仍需補上現時測量/GIS 道路點、地形、建築物、碰撞、AI line 及最終圖幅匯出。

如果 ksEditor 沒有可用的命令列匯出參數，可執行：

```powershell
.\tools\desktop_export.ps1
```

腳本會先要求輸入 `EXPORT`，用 Blender 將 `.blend` 匯出為 `11-SW-9D.fbx`，再開啟 ksEditor。它不會使用盲目滑鼠座標、不會自動覆蓋檔案，也不會代替使用者在 ksEditor 內確認輸出。

## Track tiling and scale / 圖幅分區與規模

Use metres as the authoring unit and preserve the HP1C sheet boundary. Each sheet should produce an independent KN5 model recorded in `tile_manifest.json`. Target 1.5 GB per model with a hard working limit of 2 GB. Only split an oversized sheet, using names such as:

```text
11-SW-9D.kn5
11-SW-9D-1.kn5
11-SW-9D-2.kn5
```

Do not combine all Hong Kong roads, terrain, and buildings into one model. See `docs/production-plan.md` for the broader production and quality gates.

以米作為建模單位，並保留 HP1C 圖幅邊界。每個圖幅應輸出獨立的 KN5 模型，並由 `tile_manifest.json` 記錄圖幅與載入順序。每個模型以 1.5 GB 為目標上限，工作上硬限制為 2 GB。只有在圖幅過大時才分割，命名方式如上。

不要把全部香港道路、地形和建築物合併成一個單一模型。更完整的製作與品質門檻請參閱 `docs/production-plan.md`。

## Dedicated server / 專用伺服器

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

The default server is private (`REGISTER_TO_LOBBY=0`) until the track has been tested. Set it to `1` only after port forwarding and server moderation are ready.

1. 透過 Steam Tools 安裝官方 Assetto Corsa Dedicated Server。
2. 將地圖安裝到：

   ```text
   content/tracks/hong_kong_1to1/
   ```

3. 編輯 `server/cfg/server_cfg.ini` 及 `server/cfg/entry_list.ini`。
4. 驗證並啟動伺服器：

   ```powershell
   .\server\validate-config.ps1
   .\server\start-server.ps1 -ServerRoot "C:\ACServer"
   ```

在地圖完成初步測試前，預設伺服器仍為私用 (`REGISTER_TO_LOBBY=0`)，只有在端口轉發與伺服器管理準備完成後，才應將其設定為 `1`。

## Vehicles and licensing / 車輛與授權

The first hero vehicle is an original Hong Kong Crown Comfort taxi model. Additional traffic vehicles are tracked in `config/vehicles.json`, including a prototype Hong Kong double-decker bus asset in `asset/vehicles/hk_double_decker_bus/`. Do not rip assets from commercial games or use unlicensed manufacturer CAD. Keep OSM attribution with every exported release, and treat real-world branding as replaceable until permission is available.

首部主角車是原創香港皇冠計程車模型。其他車流車輛列於 `config/vehicles.json`，其中也包括位於 `asset/vehicles/hk_double_decker_bus/` 的香港雙層巴士原型資產。不要從商業遊戲中盜用資產，也不要使用未授權的製造商 CAD。每次導出正式版本時，請保留 OSM 歸屬資訊；真實世界品牌在未取得授權前視為可替換。

The ACROSS bus-model catalog used for traffic planning is stored in `docs/across/`. It contains the exact ACROSS operator name, internal record ID, model name, fleet/type prefix where available, and source URL for all records currently listed by the site. Regenerate it with:

```powershell
python .\tools\across_catalog.py --output .\build\across --cache .\build\across-cache
```

For a compact view, use `docs/across/across_code_counts.csv`. It aggregates each operator and fleet/type code (for example `KMB,E5T`, `KMB,E6X`, or `KMB,E6M`) and reports the number of fleet entries displayed by ACROSS, rather than printing every vehicle. These counts can include historical, spare, training, or retired entries when ACROSS includes them on a model page; they are not a claim about the operator's current active fleet.

## Data sources and references / 資料來源及範圍

The route reference is the [TODS Kowloon driving-test route page](https://www.driving.com.hk/exam-routes-kowloon), updated in 2021. Recheck road positions, directions, and traffic facilities against current survey data before release.

路線轉向順序及頁面中的座標錨點來自 [TODS 九龍考車路線](https://www.driving.com.hk/exam-routes-kowloon)。該頁面的資料於 2021 年更新；正式發布前應以現時道路測量資料重新校準道路位置、方向及交通設施。

## Credit / 資源致謝

This project uses and references the following resources:

- examination route data and turning points for route ordering and junction interpretation
- map layers and street reference data for manual checking of road shape, layout, and environmental features; no automated scraping of external map content is performed
- OpenStreetMap (OSM) / Overpass API for road geometry and geographic reference data, downloaded by the project as GeoJSON / OSM source data
- HP1C survey sheets and the `11-SW-9D` tile as the basis for terrain and tile boundaries
- map-generation tools and format skeletons used in the modelling, export, and final track workflow

本專案使用及參考以下資源：

- 考試路線資料及轉向點 — 供路線順序與路口判讀參考。
- 地圖圖層與街道參考資料 — 供人工核對道路形狀、街道佈局及環境特徵；本專案不會自動抓取外部地圖內容。
- OpenStreetMap (OSM) / Overpass API — 供道路幾何及地理資料的基礎參考，並由本專案自動下載為 GeoJSON / OSM 來源資料。
- HP1C 測量圖 / 11-SW-9D 圖幅 — 作為土地測量和圖幅邊界基礎資料，控制模型分區與輸出範圍。
- 地圖製作工具與格式骨架 — 用於原型建模、輸出與最終地圖工程流程。

This project is for non-commercial research and modding only. All source data remains subject to its original copyright and usage terms. If a public release or commercial use is planned, confirm licensing and permissions before distribution.

本專案僅為非商業、研究與模組製作用途，所有資料源均保留其原始版權與使用條款。若正式發布或商業化，需先確認各資料來源的授權與使用要求，並在必要時取得適當許可。
