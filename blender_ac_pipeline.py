import bpy, os

def generate_ac_map():
    # Set up Scene Units to Meters for Assetto Corsa 1:1 Scale
    bpy.context.scene.unit_settings.system = 'METRIC'
    bpy.context.scene.unit_settings.scale_length = 1.0

    # Ensure/Select Map Mesh
    obj = bpy.context.active_object
    if not obj:
        # Create a default terrain grid if no object is selected
        bpy.ops.mesh.primitive_grid_add(x_subdivisions=100, y_subdivisions=100, size=500)
        obj = bpy.context.active_object

    obj.name = '1ROAD_main'
    
    # Attach Geometry Nodes Modifier for Road Curve Sweeping
    mod = obj.modifiers.get('AC_Road_GeoNodes')
    if not mod:
        mod = obj.modifiers.new(name='AC_Road_GeoNodes', type='NODES')
            
    # Export FBX to SDK directory
    export_path = os.path.abspath('./sdk_output/track_mesh.fbx')
    os.makedirs(os.path.dirname(export_path), exist_ok=True)
    
    bpy.ops.export_scene.fbx(
        filepath=export_path,
        use_selection=False,
        axis_forward='-Z',
        axis_up='Y'
    )
    print('Map FBX successfully generated and exported:', export_path)

if __name__ == '__main__':
    generate_ac_map()
