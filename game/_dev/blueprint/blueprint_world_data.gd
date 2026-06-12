class_name BlueprintWorldData
extends Resource

@export var chunk_matrix: Dictionary[Vector3i, PackedInt32Array] = {}
@export var world_zone_data: Array[WorldZoneData] = []
