class_name Boat
extends Node3D

@onready var models: Node3D = %Models
@onready var buoy_probes: Node3D = %BuoyProbes

# ===
# Public
# ===

func get_probes() -> Array[Marker3D]:
	var sanitized_probes: Array[Marker3D] = []
	if buoy_probes:
		var probes: Array = buoy_probes.get_children()
		for probe in probes:
			if probe is Marker3D:
				sanitized_probes.append(probe)
	return sanitized_probes
