# Hong Kong Assetto Corsa Map

This project aims to create a full Hong Kong 1:1 map for Assetto Corsa. The long-term goal is to cover the entire territory as an accurate, drivable virtual environment, not just a single road or route.

The current work focuses on a realistic, data-driven prototype using surveyed mapping data and OpenStreetMap road geometry. The project is intentionally structured so it can scale from a small road corridor to a full-city map by splitting the world into HP1C tiles and exporting them as separate KN5 models.

The initial prototype uses **HP1C** tile **11-SW-9D** as the test area and extracts only the needed road corridors for the Tin Kwong Road driving routes. This keeps the early stages manageable while establishing the workflow for a much larger map.

Each HP1C tile produces an independent KN5 model, with `tile_manifest.json` recording the tile boundaries and load order. Assetto Corsa enforces a hard file size limit of 2 GB, so generation targets a practical cap around 1.5 GB to leave safe margin for export and runtime overhead.

If a tile exceeds the limit, it is split into multiple files using the following naming pattern:

```text
11-SW-9D.kn5
11-SW-9D-1.kn5
11-SW-9D-2.kn5
```

未超過限制時使用 `11-SW-9D.kn5`；只有超過限制時才使用 `11-SW-9D-1.kn5`、`11-SW-9D-2.kn5` 等分片。分片按同一個 HP1C 圖幅的實際道路內容產生，不使用任意固定網格。

## 生成 Blender 原型

在專案根目錄執行：

```powershell
blender --background --python tools\blender\generate_tin_kwong.py
```

輸出位置：

```text
build\HP1C\tin_kwong_road\tin_kwong_road_blockout.blend
build\HP1C\tin_kwong_road\routes.json
build\HP1C\tin_kwong_road\tile_manifest.json
```

Assetto Corsa 專案骨架已放在 `asset\assetto_corsa\tin_kwong_road\`，包括 `models.ini`、`data\surfaces.ini` 和 `ui\ui_track.json`。目前版本是道路 blockout，不是已完成的 KN5。要在 Assetto Corsa 使用，下一步需要在 Blender 中加入現時測量/GIS 道路點、地形、建築物和碰撞，然後按圖幅以 ksEditor 匯出 KN5，根據 `tile_manifest.json` 更新 `models.ini`、AI line 及碰撞。不要把全部香港道路、建築物和地形合併成一個模型檔。

## 一鍵下載及建模

```powershell
.\tools\build_map.ps1
```

流程會先從 Overpass API 下載天光道附近的 OSM 道路 GeoJSON 到：

```text
build\HP1C\source\
```

下載器使用本地快取、一次只發一個請求、請求間隔至少 15 秒，失敗時以退避方式重試；不會並行請求、掃描 API 或反覆下載相同資料。已有 `roads.osm.json` 時會直接使用快取。

然後呼叫 Blender 生成道路模型。Google Maps 不會被爬取；它只可作人工參考。輸出 KN5 前，電腦必須另外安裝 Blender 和 ksEditor，並把它們加入 `PATH`。目前這個工作環境沒有這兩個程式，所以已完成下載資料和自動化腳本，但尚未產生 `.blend` 或 `.kn5`。

## 桌面匯出輔助

如果 ksEditor 沒有可用的命令列匯出參數，可執行：

```powershell
.\tools\desktop_export.ps1
```

腳本會先要求輸入 `EXPORT`，用 Blender 將 `.blend` 匯出為 `11-SW-9D.fbx`，再開啟 ksEditor。它不會使用盲目滑鼠座標、不會自動覆蓋檔案，也不會代替使用者在 ksEditor 內確認輸出。完成後請在 ksEditor 將 FBX 匯出為 `11-SW-9D.kn5`。

## 資料來源及範圍

路線轉向順序及頁面中的座標錨點來自 [TODS 九龍考車路線](https://www.driving.com.hk/exam-routes-kowloon)。該頁面的資料於 2021 年更新；正式發布前應以現時道路測量資料重新校準道路位置、方向及交通設施。

## Credit / 資源致謝

本專案使用及參考以下資源：

- 考試路線資料及轉向點 — 供路線順序與路口判讀參考。
- 地圖圖層與街道參考資料 — 供人工核對道路形狀、街道佈局及環境特徵；本專案不會自動抓取外部地圖內容。
- OpenStreetMap (OSM) / Overpass API — 供道路幾何及地理資料的基礎參考，並由本專案自動下載為 GeoJSON / OSM 來源資料。
- HP1C 測量圖 / 11-SW-9D 圖幅 — 作為土地測量和圖幅邊界基礎資料，控制模型分區與輸出範圍。
- 地圖製作工具與格式骨架 — 用於原型建模、輸出與最終地圖工程流程。

本專案僅為非商業、研究與模組製作用途，所有資料源均保留其原始版權與使用條款。若正式發布或商業化，需先確認各資料來源的授權與使用要求，並在必要時取得適當許可。
