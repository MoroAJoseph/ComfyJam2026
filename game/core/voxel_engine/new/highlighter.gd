class_name NewVoxelEngineHighlighter 
extends MeshInstance3D

@export var highlight_material: ShaderMaterial

func _ready() -> void:
	if highlight_material:
		material_override = highlight_material
	visible = false

func update_highlight(world_pos: Vector3, show_highlight: bool) -> void:
	global_position = world_pos
	visible = show_highlight
