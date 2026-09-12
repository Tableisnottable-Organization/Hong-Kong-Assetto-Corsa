"""Export the generated Blender scene to FBX for ksEditor."""

import sys
from pathlib import Path

import bpy


def argument(name: str) -> str:
    args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    for index, value in enumerate(args):
        if value == name and index + 1 < len(args):
            return args[index + 1]
    raise SystemExit("Missing argument: " + name)


output = Path(argument("--output")).resolve()
output.parent.mkdir(parents=True, exist_ok=True)
bpy.ops.export_scene.fbx(
    filepath=str(output),
    use_selection=False,
    apply_unit_scale=True,
    bake_space_transform=False,
    object_types={"MESH"},
    axis_forward="-Z",
    axis_up="Y",
    bake_anim=False,
)
print("Exported FBX:", output)
