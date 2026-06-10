class_name DEVVoxelEngineBuildContext
extends RefCounted

var chunk_size: int
var voxel_class: VoxelEngineVoxel
var voxel_colors: Array[Color]

var chunks_data: Dictionary[Vector3i, PackedByteArray] = {}
var rid_to_coordinate: Dictionary[RID, Vector3i] = {}
var current_player_chunk: Vector3i = Vector3i.ZERO
var hovered_chunk_world_coordinate: Vector3i
var hovered_voxel_local_coordinate: Vector3i
var last_hovered_hit_rid: RID 

func get_total_voxel_count() -> int:
	var total: int = 0
	for data: PackedByteArray in chunks_data.values():
		for b: int in data:
			if b > 0:
				total += 1
	return total
