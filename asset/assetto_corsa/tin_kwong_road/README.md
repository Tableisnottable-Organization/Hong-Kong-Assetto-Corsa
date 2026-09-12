# 天光道考試路線 AC 專案骨架

這個資料夾是 Assetto Corsa 的匯出目標，不是已完成的 KN5 地圖。把 ksEditor 匯出的模型放到：

```text
content\tracks\tin_kwong_road\
```

需要的檔案：

- `models.ini`：載入 `11-SW-9D.kn5`，超過 2 GB 時改為 `11-SW-9D-1.kn5`、`11-SW-9D-2.kn5` 等
- `data\surfaces.ini`：路面物理材質
- `ui\ui_track.json`：遊戲選單顯示資料

目前沒有 HP1C 原尺寸測量圖，因此尚未生成真實 KN5、AI line、碰撞網格或可發布的道路模型。
