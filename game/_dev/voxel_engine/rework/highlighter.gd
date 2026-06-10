class_name DEVVoxelEngineHighlighter 
extends MeshInstance3D

var build_context: DEVVoxelEngineBuildContext

var last_hovered_chunk_world_coordinate: Vector3i
var last_hovered_voxel_local_coordinate: Vector3i

# ===
# Built-In
# ===

func _init(
	p_build_context: DEVVoxelEngineBuildContext
) -> void:
	build_context = p_build_context
	print_debug("VoxelEngine: Highlighter Created")

func _ready() -> void:
	var shader_material: ShaderMaterial = load("res://core/voxel_engine/block_highlight.tres")
	material_override = shader_material
	_update_mesh()
	print_debug("VoxelEngine: Highlighter Ready")

func _process(_delta: float) -> void:
	if (
		last_hovered_chunk_world_coordinate != build_context.hovered_chunk_world_coordinate or
		last_hovered_voxel_local_coordinate != build_context.hovered_voxel_local_coordinate
	):
		var chunk_coord: Vector3i = build_context.rid_to_coordinate[build_context.last_hovered_hit_rid]
		var data: PackedByteArray = build_context.chunks_data[chunk_coord]
		_update_geometry(data)
		_update_position()


# ===
# Private
# ===

func _update_position() -> void:
	var chunk_origin: Vector3i = build_context.voxel_class.chunk_to_world(
		build_context.hovered_chunk_world_coordinate, 
		build_context.chunk_size
	)
	var voxel_world: Vector3i = build_context.voxel_class.voxel_to_world(
		build_context.hovered_voxel_local_coordinate, 
		chunk_origin
	)
	global_position = voxel_world
	visible = true

func _update_mesh() -> void:
	mesh = null
	rotation_degrees = Vector3.ZERO
	
	if build_context.voxel_class is VoxelEngineCube:
			mesh = BoxMesh.new()
			mesh.size = Vector3.ONE
	elif build_context.voxel_class is VoxelEngineHexagon:
			var hex_mesh: CylinderMesh = CylinderMesh.new()
			hex_mesh.radial_segments = 6
			hex_mesh.cap_top = true
			hex_mesh.cap_bottom = true
			hex_mesh.top_radius = 1.0
			hex_mesh.bottom_radius = 1.0
			hex_mesh.height = 1.0
			mesh = hex_mesh

func _update_geometry(
	data: PackedByteArray, 
) -> void:
	var color: Color = Color.WHITE 
	var geometry: Dictionary = build_context.voxel_class.get_single_voxel_geometry(
		build_context.hovered_voxel_local_coordinate, 
		data, 
		build_context.hovered_chunk_world_coordinate, 
		build_context.chunks_data, 
		build_context.chunk_size, 
		[color]
	)
	
	var array_mesh: ArrayMesh = ArrayMesh.new()
	
	if not geometry.vertices.is_empty():
		var surface_array: Array = []
		surface_array.resize(Mesh.ARRAY_MAX)
		surface_array[Mesh.ARRAY_VERTEX] = geometry.vertices
		surface_array[Mesh.ARRAY_NORMAL] = geometry.normals
		surface_array[Mesh.ARRAY_COLOR] = geometry.colors
		
		array_mesh.add_surface_from_arrays(
			Mesh.PRIMITIVE_TRIANGLES, 
			surface_array
		)
	
	mesh = array_mesh
