# 香港 1:1 Assetto Corsa / Hong Kong 1:1 Assetto Corsa

香港本專案旨在製作一個完整的香港 1:1 Assetto Corsa 地圖，目標是將整個香港以真實尺度重建為可駕駛的虛擬環境，而不只是單一道路或單一路線。

This project aims to create a complete Hong Kong 1:1 map for Assetto Corsa. The goal is to rebuild the whole territory at real-world scale as a drivable virtual environment, not just a single road or route.

本倉庫是香港 1:1 地圖開發的起點，包含地圖生成流程、資料處理工具、車輛配置與伺服器設定。現階段原型聚焦在 HP1C 圖幅 `11-SW-9D` 與天光道考試路線，未來會擴展至九龍更大範圍道路網。

This repository is the starting point for the Hong Kong 1:1 map project, including map-generation workflow, data tooling, vehicle config, and server setup. The current prototype focuses on HP1C sheet `11-SW-9D` and the Tin Kwong Road driving-test routes, with a broader goal of expanding to a larger Kowloon road network.

## 專案範圍 / Project scope

- 地圖：基於地理空間資料建立真實尺度的九龍道路環境。
- 現階段路線：天光道一、二、三考試路線。
- 目標遊戲：PC 版 Assetto Corsa。
- 車輛：以原創、可合法分發的香港道路車輛模型為主，首部主角車為香港皇冠計程車。

- Map: real-world-scale Kowloon roads built from geospatial data.
- Current route: Tin Kwong Road routes one, two, and three.
- Target game: Assetto Corsa on PC.
- Vehicles: original, legally distributable Hong Kong road vehicles; the first hero vehicle is a Hong Kong Crown Comfort taxi.

本倉庫包含版本控制的規劃文件、地圖生成工具、車輛清單與伺服器配置。它不包含第三方地圖資料、受版權保護的影像、Assetto Corsa 遊戲檔案或 `acServer.exe` 執行檔。生成的網格、紋理與 KN5 檔案不會放進 Git，除非足夠小以便審查與重新分發。

The repository contains version-controlled planning docs, map-generation tooling, vehicle manifests, and server configuration. It does not include third-party map data, copyrighted imagery, Assetto Corsa game files, or the `acServer.exe` binary. Generated meshes, textures, and KN5 files remain out of Git unless they are small enough to review and redistribute.

## 倉庫結構 / Repository layout

```text
config/                              車輛與地圖設定
asset/assetto_corsa/tin_kwong_road/  Assetto Corsa 路線包骨架
asset/routes/                         路線定義
build/HP1C/                           生成中的原型輸出與圖幅清單
docs/                                 地圖製作計劃
server/cfg/                           專用伺服器設定
tools/                                下載資料、Blender 及匯出腳本
```

```text
config/                              Map and vehicle manifests
asset/assetto_corsa/tin_kwong_road/  Assetto Corsa track package skeleton
asset/routes/                         Route definitions
build/HP1C/                           Generated prototype output and manifests
docs/                                 Map production plan
server/cfg/                           Dedicated-server configuration
tools/                                Data download, Blender, and export scripts
```

## 建立地圖原型 / Build the map prototype

在倉庫根目錄執行：

```powershell
.\tools\build_map.ps1
```

From the repository root:

```powershell
.\tools\build_map.ps1
```

流程會先下載所需的 OSM 道路資料到 `build\HP1C\source\`，採用本地快取、單一請求、最少 15 秒間隔和退避重試。已存在快取資料時會直接重用，之後再呼叫 Blender 生成道路 blockout 與圖幅清單。

The workflow downloads the required OSM road data to `build\HP1C\source\` using local caching, one request at a time, a minimum 15-second interval, and backoff retries. Existing cached data is reused. It then invokes Blender to generate the road blockout and manifests.

Blender 和 ksEditor 必須另外安裝，並確保位於 `PATH` 內，才能完成完整匯出流程。目前輸出仍是道路 blockout，不是已完成的 KN5；正式使用前，還需要補齊測量/GIS 道路點、地形、建築物、碰撞、AI line 及最終圖幅匯出。

Blender and ksEditor must be installed separately and available on `PATH` for the full export workflow. The current output is a road blockout, not a finished KN5. Add surveyed/GIS road points, terrain, buildings, collision, AI lines, and final tile exports before using it as a released track.

如果 ksEditor 沒有可用的命令列匯出參數，可執行：

```powershell
.\tools\desktop_export.ps1
```

If ksEditor needs interactive export, use:

```powershell
.\tools\desktop_export.ps1
```

腳本會先要求輸入 `EXPORT`，用 Blender 將 `.blend` 匯出為 `11-SW-9D.fbx`，再開啟 ksEditor。它不會使用盲目滑鼠座標、不會自動覆蓋檔案，也不會代替使用者在 ksEditor 內確認輸出。

The helper requires explicit `EXPORT` confirmation, avoids blind mouse automation, and does not overwrite files without confirmation.

## 圖幅分區與規模 / Track tiling and scale

以米作為建模單位，並保留 HP1C 圖幅邊界。每個圖幅應輸出獨立的 KN5 模型，並由 `tile_manifest.json` 記錄圖幅與載入順序。每個模型以 1.5 GB 為目標上限，工作上硬限制為 2 GB。只有在圖幅過大時才分割，命名方式如下：

Use metres as the authoring unit and preserve the HP1C sheet boundary. Each sheet should produce an independent KN5 model recorded in `tile_manifest.json`. Target 1.5 GB per model with a hard working limit of 2 GB. Only split an oversized sheet, using names such as:

```text
11-SW-9D.kn5
11-SW-9D-1.kn5
11-SW-9D-2.kn5
```

不要把全部香港道路、地形和建築物合併成一個單一模型。更完整的製作與品質門檻請參閱 `docs/production-plan.md`。

Do not combine all Hong Kong roads, terrain, and buildings into one model. See `docs/production-plan.md` for the broader production and quality gates.

## 專用伺服器 / Dedicated server

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

## 車輛與授權 / Vehicles and licensing

首部主角車是原創香港皇冠計程車模型。其他車流車輛列於 `config/vehicles.json`。不要從商業遊戲中盜用資產，也不要使用未授權的製造商 CAD。每次導出正式版本時，請保留 OSM 歸屬資訊；真實世界品牌在未取得授權前視為可替換。

The first hero vehicle is an original Hong Kong Crown Comfort taxi model. Additional traffic vehicles are tracked in `config/vehicles.json`. Do not rip assets from commercial games or use unlicensed manufacturer CAD. Keep OSM attribution with every exported release, and treat real-world branding as replaceable until permission is available.

## 資料來源及範圍 / Data sources and references

路線轉向順序及頁面中的座標錨點來自 [TODS 九龍考車路線](https://www.driving.com.hk/exam-routes-kowloon)。該頁面的資料於 2021 年更新；正式發布前應以現時道路測量資料重新校準道路位置、方向及交通設施。

The route reference is the [TODS Kowloon driving-test route page](https://www.driving.com.hk/exam-routes-kowloon), updated in 2021. Recheck road positions, directions, and traffic facilities against current survey data before release.

## 資源致謝 / Credit

本專案使用及參考以下資源：

- 考試路線資料及轉向點 — 供路線順序與路口判讀參考。
- 地圖圖層與街道參考資料 — 供人工核對道路形狀、街道佈局及環境特徵；本專案不會自動抓取外部地圖內容。
- OpenStreetMap (OSM) / Overpass API — 供道路幾何及地理資料的基礎參考，並由本專案自動下載為 GeoJSON / OSM 來源資料。
- HP1C 測量圖 / 11-SW-9D 圖幅 — 作為土地測量和圖幅邊界基礎資料，控制模型分區與輸出範圍。
- 地圖製作工具與格式骨架 — 用於原型建模、輸出與最終地圖工程流程。

This project uses and references the following resources:

- examination route data and turning points for route ordering and junction interpretation
- map layers and street reference data for manual checking of road shape, layout, and environmental features; no automated scraping of external map content is performed
- OpenStreetMap (OSM) / Overpass API for road geometry and geographic reference data, downloaded by the project as GeoJSON / OSM source data
- HP1C survey sheets and the `11-SW-9D` tile as the basis for terrain and tile boundaries
- map-generation tools and format skeletons used in the modelling, export, and final track workflow

本專案僅為非商業、研究與模組製作用途，所有資料源均保留其原始版權與使用條款。若正式發布或商業化，需先確認各資料來源的授權與使用要求，並在必要時取得適當許可。

This project is for non-commercial research and modding only. All source data remains subject to its original copyright and usage terms. If a public release or commercial use is planned, confirm licensing and permissions before distribution.
