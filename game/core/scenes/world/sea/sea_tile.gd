@tool
extends MeshInstance3D

#var material: ShaderMaterial
#var cpu_time: float = 0
#
#func _ready() -> void:
	#if Engine.is_editor_hint():
		#material = get_active_material(0)
#
#func _process(delta: float) -> void:
	#if Engine.is_editor_hint():
		#cpu_time += delta
		#material.set_shader_parameter("cpu_time", cpu_time)
