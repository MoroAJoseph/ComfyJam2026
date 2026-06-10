extends BuoyantRigidBody

@onready var mesh_instance: MeshInstance3D = %Mesh

func apply_color(color: Color):
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	mesh_instance.set_surface_override_material(0, material)

func apply_texture():
	pass
