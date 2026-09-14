import bpy, os
def process_and_export():
    obj = bpy.context.active_object
    if obj:
        obj.name = '1ROAD_main'
        if not obj.modifiers.get('AC_Road_GeoNodes'):
            obj.modifiers.new(name='AC_Road_GeoNodes', type='NODES')
            
    export_path = os.path.abspath('./sdk_output/track_mesh.fbx')
    os.makedirs(os.path.dirname(export_path), exist_ok=True)
    
    bpy.ops.export_scene.fbx(
        filepath=export_path,
        use_selection=False,
        axis_forward='-Z',
        axis_up='Y'
    )
    print('FBX successfully exported for SDK:', export_path)

if __name__ == '__main__':
    process_and_export()
