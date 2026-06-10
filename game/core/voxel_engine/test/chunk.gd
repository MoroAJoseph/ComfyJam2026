class_name TestVoxelEngineChunk extends StaticBody3D

var mesh_instance: MeshInstance3D
var material: Material

func _init(mat: Material) -> void:
	material = mat

func _ready() -> void:
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = ArrayMesh.new()
	add_child(mesh_instance)

func update_visuals(geo: Dictionary) -> void:
	if geo.verts.is_empty():
		mesh_instance.mesh.clear_surfaces()
		return

	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = geo.verts
	arr[Mesh.ARRAY_NORMAL] = geo.norms
	arr[Mesh.ARRAY_COLOR] = geo.cols
	
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	mesh_instance.mesh = array_mesh
	
	# ADDED: Apply the material here, after the surface exists
	if material:
		mesh_instance.set_surface_override_material(0, material)
