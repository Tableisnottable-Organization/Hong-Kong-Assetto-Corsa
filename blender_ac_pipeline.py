import bpy
import os

def process_and_export():
    # Set up active object with AC Kunos Naming convention
    obj = bpy.context.active_object
    if obj:
        obj.name = '1ROAD_main'
        
        # Attach Geometry Nodes Modifier
        mod = obj.modifiers.get('AC_Road_GeoNodes')
        if not mod:
            obj.modifiers.new(name='AC_Road_GeoNodes', type='NODES')
            
    # Export FBX for Assetto Corsa SDK / ksEditor
    export_path = os.path.abspath('./sdk_output/track_mesh.fbx')
    os.makedirs(os.path.dirname(export_path), exist_ok=True)
    
    bpy.ops.export_scene.fbx(
        filepath=export_path,
        use_selection=False,
        axis_forward='-Z',
        axis_up='Y'
    )
    print('FBX successfully transferred to SDK pipeline:', export_path)

if __name__ == '__main__':
    process_and_export()
