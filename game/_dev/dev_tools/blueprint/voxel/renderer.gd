class_name VoxelBlueprintRenderer
extends RefCounted

const BLOCK_COLORS: Dictionary = {
	Enums.BlockType.SAND: Color.ANTIQUE_WHITE,
	Enums.BlockType.DIRT: Color.SADDLE_BROWN,
	Enums.BlockType.STONE: Color.SLATE_GRAY,
	Enums.BlockType.COBBLESTONE: Color.DARK_GRAY,
	Enums.BlockType.MOSSY_COBBLESTONE: Color.FOREST_GREEN,
	Enums.BlockType.GRASS: Color.WEB_GREEN,
	Enums.BlockType.COAL_ORE: Color.DIM_GRAY,
	Enums.BlockType.COAL: Color.BLACK,
	Enums.BlockType.SILVER_ORE: Color.LIGHT_GRAY,
	Enums.BlockType.COPPER_ORE: Color.ORANGE_RED
}

static func render_matrix(parent: Node, matrix: Dictionary, chunk_size: int, use_hexagons: bool) -> void:

	var edge_alignment_basis := Basis.from_euler(Vector3(0, deg_to_rad(30), 0))

	const HEX_X := 1.5
	const HEX_Z := sqrt(3.0)

	for chunk_coord: Vector3i in matrix:

		var chunk_data: Dictionary = matrix[chunk_coord]
		var voxels: Dictionary = chunk_data["voxels"]
		var is_dock: bool = chunk_data.get("is_dock", false)

		var blocks_by_type := {}

		for pos: Vector3i in voxels:
			var type = voxels[pos]
			if not blocks_by_type.has(type):
				blocks_by_type[type] = []
			blocks_by_type[type].append(pos)

		for type in blocks_by_type:

			var positions: Array = blocks_by_type[type]

			var mm_instance := MultiMeshInstance3D.new()
			parent.add_child(mm_instance)

			var mat := StandardMaterial3D.new()
			mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

			var base_color = BLOCK_COLORS.get(type, Color.MAGENTA)
			if is_dock:
				base_color = Color.MAGENTA

			mat.albedo_color = base_color
			mm_instance.material_override = mat

			var mm := MultiMesh.new()
			mm.transform_format = MultiMesh.TRANSFORM_3D
			mm.instance_count = positions.size()

			if use_hexagons:
				var hex := CylinderMesh.new()
				hex.radial_segments = 6
				hex.top_radius = 1.0
				hex.bottom_radius = 1.0
				hex.height = 1.0
				mm.mesh = hex
			else:
				var box := BoxMesh.new()
				box.size = Vector3.ONE
				mm.mesh = box

			mm_instance.multimesh = mm

			var chunk_origin := Vector3(
				chunk_coord.x * chunk_size,
				0,
				chunk_coord.z * chunk_size
			)

			for i in range(positions.size()):

				var local_pos: Vector3i = positions[i]

				var world_pos: Vector3

				if use_hexagons:
					world_pos = Vector3(
						HEX_X * float(local_pos.x),
						float(local_pos.y),
						HEX_Z * (float(local_pos.z) + 0.5 * float(local_pos.x))
					)
				else:
					world_pos = Vector3(local_pos)

				mm.set_instance_transform(
					i,
					Transform3D(
						edge_alignment_basis if use_hexagons else Basis(),
						chunk_origin + world_pos
					)
				)
