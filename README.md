# 香港天光道 Assetto Corsa 地圖

這個專案以測量圖組別 **HP1C**（圖幅 **11-SW-9D**）作為資料來源，按 HP1C 原有圖幅邊界輸出模型，只抽取天光道三條考試路線所需的道路走廊，不保存不需要的周邊區域。路線一、二、三共用已抽取的道路，避免重複建模。

每個 HP1C 圖幅會輸出一個獨立的 KN5 模型，並由 `tile_manifest.json` 記錄圖幅和載入順序。Assetto Corsa 單一檔案的硬上限按 2 GB 處理；生成設定以 1.5 GB 作為目標上限，預留安全空間。

如果圖幅模型超過 2 GB，只分割該圖幅，並按以下格式命名：

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
