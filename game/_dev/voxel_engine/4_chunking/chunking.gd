class_name VoxelEngineChunking
extends Node3D

@export var cutoff: float = 0.5

#func _generate_hexagon_data() -> void:
	#var noise = FastNoiseLite.new()
	#noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	#
	#for x in range(dimensions.x):
		#for z in range(dimensions.z):
			#for y in range(dimensions.y):
				#
				#var height_factor = float(y) / float(dimensions.y)
				#if noise.get_noise_3d(x, y, z) > (cutoff + (height_factor * 0.5)):
					#hexagon_data[Vector3i(x, y, z)] = _get_random_color(y)
					#total_blocks += 1
