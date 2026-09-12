"""Generate a shared Tin Kwong Road driving-test prototype in Blender.

Run with Blender:
    blender --background --python tools/blender/generate_tin_kwong.py

The source route points are the published route anchors from:
https://www.driving.com.hk/exam-routes-kowloon

This intentionally generates a clean, editable road blockout. Survey/GIS
coordinates and visual assets can be added later without changing route IDs.
"""

from __future__ import annotations

import json
import math
from pathlib import Path

import bpy
from mathutils import Vector


ROOT = Path(__file__).resolve().parents[2]
MAP_ID = "tin_kwong_road"
MAP_DISPLAY_NAME = "天光道考試路線"
SURVEY_GROUP = "HP1C"
SHEET_ID = "11-SW-9D"
OUTPUT = ROOT / "build" / SURVEY_GROUP / MAP_ID
ROAD_WIDTH = 7.0
ROAD_Z = 0.08
TARGET_MAX_FILE_BYTES = 1_500_000_000

# WGS84 anchors published with the three Tin Kwong Road routes. Coordinates
# are converted to a local metre grid around the driving-test centre.
ANCHORS = {
    "test_centre": (22.3219899, 114.1848273),
    "tian_kwong_road": (22.3163984, 114.1869889),
    "back_cheung_road": (22.3200388, 114.1863787),
    "tian_kwong_return": (22.3205179, 114.1832788),
    "road_two_turn": (22.3206612, 114.1832943),
    "road_two_loop": (22.3200290, 114.1873843),
    "route_three_far": (22.3201916, 114.1802234),
}

# Route instructions from the source page. Names are kept in English here so
# the generator remains portable across Blender installations.
ROUTES = {
    "tin_kwong_1": [
        "START",
        "LEFT Tian Kwong Road",
        "RIGHT Back Cheung Road",
        "LEFT Lok Shan Road",
        "RIGHT Mei Shing Tong Street",
        "RIGHT Jiangsu Street",
        "RIGHT Back Cheung Road",
        "LEFT Tian Kwong Road",
        "RIGHT Sheung Hong Street",
        "U-TURN",
        "LEFT Sheung Shing Street",
        "LEFT Tian Kwong Road",
        "FINISH",
    ],
    "tin_kwong_2": [
        "START",
        "LEFT Tian Kwong Road",
        "RIGHT Sheung Shing Street",
        "RIGHT Sheung Hong Street",
        "U-TURN",
        "LEFT Sheung Shing Street",
        "RIGHT Tian Kwong Road",
        "LEFT Ma Tau Wai Road",
        "LEFT Farm Road",
        "RIGHT Tian Kwong Road",
        "FINISH",
    ],
    "tin_kwong_3": [
        "START",
        "RIGHT Tian Kwong Road",
        "LEFT Argyle Street",
        "LEFT Carlisle Road",
        "RIGHT Pui Ching Road",
        "LEFT Shek Ku Street",
        "LEFT Sheung Shing Street",
        "RIGHT Sheung Hong Street",
        "U-TURN",
        "LEFT Sheung Shing Street",
        "LEFT Tian Kwong Road",
        "FINISH",
    ],
}


def local_xy(lat: float, lon: float) -> tuple[float, float]:
    lat0, lon0 = ANCHORS["test_centre"]
    metres_per_degree_lat = 111_320.0
    metres_per_degree_lon = 111_320.0 * math.cos(math.radians(lat0))
    return ((lon - lon0) * metres_per_degree_lon, (lat - lat0) * metres_per_degree_lat)


def curve_points(points: list[tuple[float, float]], subdivisions: int = 8) -> list[Vector]:
    """Catmull-Rom interpolation for a smooth, editable road centreline."""
    result: list[Vector] = []
    padded = [points[0], *points, points[-1]]
    for i in range(1, len(padded) - 2):
        p0, p1, p2, p3 = (Vector((*p, ROAD_Z)) for p in padded[i - 1 : i + 3])
        for step in range(subdivisions):
            t = step / subdivisions
            t2, t3 = t * t, t * t * t
            point = 0.5 * (
                (2 * p1)
                + (-p0 + p2) * t
                + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2
                + (-p0 + 3 * p1 - 3 * p2 + p3) * t3
            )
            result.append(point)
    result.append(Vector((*points[-1], ROAD_Z)))
    return result


def mesh_strip(name: str, centreline: list[Vector], width: float, material: bpy.types.Material):
    vertices = []
    faces = []
    for index, point in enumerate(centreline):
        previous = centreline[max(0, index - 1)]
        following = centreline[min(len(centreline) - 1, index + 1)]
        tangent = (following - previous).normalized()
        side = Vector((-tangent.y, tangent.x, 0)).normalized() * (width / 2)
        vertices.extend([point + side, point - side])
        if index:
            base = (index - 1) * 2
            faces.append((base, base + 1, base + 3, base + 2))
    mesh = bpy.data.meshes.new(name + "_mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.materials.append(material)
    object_ = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(object_)
    return object_


def material(name: str, colour: tuple[float, float, float, float]) -> bpy.types.Material:
    result = bpy.data.materials.new(name)
    result.diffuse_color = colour
    return result


def add_marker(name: str, location: Vector, colour: tuple[float, float, float, float]):
    bpy.ops.mesh.primitive_cube_add(
        size=1,
        location=(location.x, location.y, ROAD_Z + 0.035),
    )
    marker = bpy.context.object
    marker.name = name
    marker.dimensions = (0.12, 2.5, 0.035)
    marker.data.materials.append(material("marker_" + name, colour))
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return marker


def build_shared_road() -> list[Vector]:
    source = ROOT / "build" / SURVEY_GROUP / "source" / "roads.geojson"
    if source.exists():
        data = json.loads(source.read_text(encoding="utf-8"))
        asphalt = material("HK_asphalt", (0.055, 0.06, 0.065, 1))
        primary = []
        excluded = {"footway", "path", "steps", "cycleway", "pedestrian"}
        for index, feature in enumerate(data.get("features", [])):
            highway = feature.get("properties", {}).get("highway", "")
            if highway in excluded:
                continue
            points = [
                local_xy(coordinate[1], coordinate[0])
                for coordinate in feature.get("geometry", {}).get("coordinates", [])
            ]
            if len(points) < 2:
                continue
            line = curve_points(points, subdivisions=2)
            mesh_strip("HP1C_ROAD_%04d" % index, line, ROAD_WIDTH, asphalt)
            if not primary:
                primary = line
        if primary:
            return primary

    # Fallback anchors keep the generator useful before source download.
    anchor_points = [
        local_xy(*ANCHORS["test_centre"]),
        local_xy(*ANCHORS["tian_kwong_road"]),
        local_xy(*ANCHORS["back_cheung_road"]),
        local_xy(*ANCHORS["tian_kwong_return"]),
        local_xy(*ANCHORS["road_two_turn"]),
        local_xy(*ANCHORS["road_two_loop"]),
        local_xy(*ANCHORS["route_three_far"]),
        local_xy(*ANCHORS["test_centre"]),
    ]
    centreline = curve_points(anchor_points)
    asphalt = material("HK_asphalt", (0.055, 0.06, 0.065, 1))
    mesh_strip("TIN_KWONG_SHARED_ROADS", centreline, ROAD_WIDTH, asphalt)

    line_colour = (0.95, 0.95, 0.82, 1)
    for index, point in enumerate(centreline[::4]):
        if index % 2 == 0:
            add_marker("centre_line_%03d" % index, point, line_colour)
    return centreline


def write_tile_manifest(centreline: list[Vector]) -> None:
    """Describe road-only models per source sheet, splitting only when needed."""
    sheets = [{
        "sheet": SHEET_ID,
        "model": "models/%s.kn5" % SHEET_ID,
        "max_file_bytes": TARGET_MAX_FILE_BYTES,
        "estimated_file_bytes": 0,
        "content": "required_road_corridor_only",
        "split_if_over_hard_limit": True,
        "split_name_pattern": "%s-{part}" % SHEET_ID,
    }]
    manifest = {
        "map": MAP_ID,
        "display_name": MAP_DISPLAY_NAME,
        "survey_group": SURVEY_GROUP,
        "sheet": SHEET_ID,
        "extraction": "required_road_corridor_only",
        "included_routes": sorted(ROUTES),
        "excluded": "unused_area_of_source_sheet",
        "format": "assetto_corsa_source_sheet_models",
        "hard_file_limit_bytes": 2_000_000_000,
        "target_file_limit_bytes": TARGET_MAX_FILE_BYTES,
        "sheet_boundary_source": "HP1C original survey sheet",
        "split_policy": {
            "condition": "source_sheet_model_over_2GB",
            "unsplit_name": SHEET_ID,
            "split_names": ["%s-1" % SHEET_ID, "%s-2" % SHEET_ID],
            "extension": ".kn5",
        },
        "sheets": sheets,
        "models_ini_order": [item["model"] for item in sheets],
    }
    (OUTPUT / "tile_manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8"
    )


def write_route_data(centreline: list[Vector]) -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    route_points = [
        {"x": round(point.x, 3), "y": round(point.y, 3), "z": round(point.z, 3)}
        for point in centreline
    ]
    payload = {
        "name": MAP_DISPLAY_NAME,
        "source": "https://www.driving.com.hk/exam-routes-kowloon",
        "shared_road": "TIN_KWONG_SHARED_ROADS",
        "routes": {
            route_id: {"instructions": instructions, "centerline": route_points}
            for route_id, instructions in ROUTES.items()
        },
    }
    (OUTPUT / "routes.json").write_text(
        json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    write_tile_manifest(centreline)


def main() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    centreline = build_shared_road()
    write_route_data(centreline)
    OUTPUT.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(OUTPUT / (MAP_ID + "_blockout.blend")))
    print("Generated shared Tin Kwong Road blockout in", OUTPUT)


if __name__ == "__main__":
    main()
