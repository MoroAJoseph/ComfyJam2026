class_name BlockItem
extends Node3D

@export var merge_distance: float = 0.5
@export var min_merge_speed: float = 2.0
@export var max_merge_speed: float = 20.0
@export var merge_acceleration: float = 10.0

@onready var body: BuoyantRigidBody = %Body
@onready var collectable_area: Area3D = %CollectableArea
@onready var merge_area: Area3D = %MergeArea
@onready var mesh_instance: MeshInstance3D = %Mesh

var data: BlockItemData
var merge_target: BlockItem = null
var is_merging := false

# ===
# Built-In
# ===

func _ready() -> void:
	if not data: return
	merge_area.area_entered.connect(_on_merge_area_entered)
	
	var geom = VoxelEngineHexagon.get_single_textured_voxel_geometry(data.type)
	
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Pack the arrays into the SurfaceTool
	for i in range(geom.vertices.size()):
		st.set_normal(geom.normals[i])
		st.set_uv(geom.uvs[i])
		
		# Tangent data is stored as [x, y, z, w]
		# geom.tangents contains the data for all vertices (4 floats per vertex)
		var offset = i * 4
		var t := Plane(geom.tangents[offset], geom.tangents[offset+1], geom.tangents[offset+2], geom.tangents[offset+3])
		st.set_tangent(t)
		
		st.add_vertex(geom.vertices[i])
		
	mesh_instance.mesh = st.commit()

func _physics_process(_delta: float) -> void:
	if is_merging:
		return

	if merge_target == null:
		return

	if not is_instance_valid(merge_target):
		merge_target = null
		return

	var to_target := merge_target.body.global_position - body.global_position
	var distance := to_target.length()

	# Merge before movement
	if distance <= merge_distance:
		_perform_merge_logic(merge_target)
		return

	var direction := to_target.normalized()

	# Velocity-based homing prevents overshooting much better than force
	var speed: float = clamp(
		distance * merge_acceleration, 
		min_merge_speed, 
		max_merge_speed
	)
	body.linear_velocity = direction * speed

# ===
# Private
# ===

func _perform_merge_logic(target: BlockItem) -> void:
	if is_merging:
		return

	is_merging = true

	# Stop all motion
	body.linear_velocity = Vector3.ZERO
	body.angular_velocity = Vector3.ZERO

	# Snap directly to target
	body.global_position = target.body.global_position

	# Freeze while processing
	body.freeze = true

	var space_left := target.data.max_stack - target.data.stack_count

	if space_left > 0:
		var amount: int = min(data.stack_count, space_left)

		target.data.stack_count += amount
		data.stack_count -= amount

		if data.stack_count <= 0:
			queue_free()
		else:
			is_merging = false
			body.freeze = false
			merge_target = null
	else:
		is_merging = false
		body.freeze = false
		merge_target = null

# ===
# Signals
# ===

func _on_merge_area_entered(area: Area3D) -> void:
	var parent := area.get_parent()

	if parent is BlockItem and parent != self:
		var other: BlockItem = parent

		if other.data.type != data.type:
			return

		# Only one block should move toward the other
		if get_instance_id() > other.get_instance_id():
			merge_target = other
