import bpy, os

def run_map_pipeline():
    # Set scene units to Meters for Assetto Corsa 1:1 scale
    bpy.context.scene.unit_settings.system = 'METRIC'
    bpy.context.scene.unit_settings.scale_length = 1.0

    # Locate active mesh or create base terrain grid
    obj = bpy.context.active_object
    if not obj:
        bpy.ops.mesh.primitive_grid_add(x_subdivisions=100, y_subdivisions=100, size=500)
        obj = bpy.context.active_object

    # Kunos physics naming convention
    obj.name = '1ROAD_main'
    
    # Attach Geometry Nodes modifier for road mesh curve
    if not obj.modifiers.get('AC_Road_GeoNodes'):
        obj.modifiers.new(name='AC_Road_GeoNodes', type='NODES')
            
    # Export FBX mesh for AC SDK (ksEditor)
    export_path = os.path.abspath('./sdk_output/track_mesh.fbx')
    os.makedirs(os.path.dirname(export_path), exist_ok=True)
    
    bpy.ops.export_scene.fbx(
        filepath=export_path,
        use_selection=False,
        axis_forward='-Z',
        axis_up='Y'
    )
    print('[BLENDER BACKEND] FBX exported successfully to:', export_path)

if __name__ == '__main__':
    run_map_pipeline()
