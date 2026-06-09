class_name ContextData
extends RefCounted

# ===
# Abstract
# ===

func reset() -> void:
	assert(false, "Reset method not implemented")

func to_dict() -> Dictionary[int, Variant]:
	assert(false, "To Dict method not implemented")
	return {}

func from_dict(_data: Dictionary[int, Variant]) -> void:
	assert(false, "From Dict method not implemented")

# ===
# Concrete
# ===

func to_bytes() -> PackedByteArray:
	return var_to_bytes(to_dict())

func from_bytes(data: PackedByteArray) -> void:
	var dict = bytes_to_var(data)
	if dict is Dictionary:
		from_dict(dict)
