class_name Chunk 
extends StaticBody3D

@export var mat: ShaderMaterial

@onready var collision_shape = $CollisionShape3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

var biome_noise: Noise = FastNoiseLite.new()
var chunk_data: ChunkData = ChunkData.new()
var mesh_data: MeshData = MeshData.new()
var meshing_algorithm: MeshingAlgorithm

func _ready() -> void:
	if mat:
		mesh_instance.material_override = mat
	
	if mesh_data.IsEmpty(): return
	mesh_instance.mesh = ArrayMesh.new()
	commit_mesh()

func generate_data(terrain_algorithm: TerrainAlgorithm) -> void:
	var geometry = meshing_algorithm.ScriptGeometry if meshing_algorithm else null
	terrain_algorithm.generate_data(position, biome_noise, chunk_data, geometry)

func create_mesh() -> void:
	meshing_algorithm.GenerateMesh(chunk_data, mesh_data)
	
func remesh() -> void:
	mesh_data.Reset()
	create_mesh()
	mesh_instance.mesh = ArrayMesh.new()
	commit_mesh()
	
func remove_voxel(pos: Vector3i) -> void:
	chunk_data.RemoveVoxel(pos.x, pos.y, pos.z)
	
func commit_mesh() -> void:
	# Packs positions, normals, raw UV paths, and TANGENT.x indices on the C# side
	mesh_data.Commit()
	
	# Rebuild the mesh surfaces using our newly updated arrays
	mesh_instance.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_data.GetSurfaceArray())
	
	# Update physics bounds safely to prevent falling through newly updated geometry seams
	if mesh_instance.mesh.get_surface_count() > 0:
		collision_shape.shape = mesh_instance.mesh.create_trimesh_shape()
	else:
		collision_shape.shape = null
