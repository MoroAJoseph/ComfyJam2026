@abstract
class_name TerrainAlgorithm extends Resource

enum Voxel{SAND, GRASS, MOUNTAIN, SNOW, AIR}

@export var max_height: int
@export var noise: TerrainNoise

var name: String = "noName"

# We pass a geometry object or a boolean so algorithms can query world space positions
@abstract func generate_data(position: Vector3, biome_noise: Noise, chunk_data, geometry: RefCounted = null) -> void
@abstract func create_name() -> String
