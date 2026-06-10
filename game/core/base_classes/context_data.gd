class_name ContextData
extends RefCounted

# ===
# Abstract
# ===

func reset() -> void:
	assert(false, "Reset method not implemented")

# ===
# Concrete
# ===

func _authorize_write() -> bool:
	var stack = get_stack()
	if stack.size() < 3: return false

	var caller_frame = stack[2]
	var caller = caller_frame.get("object")
	
	# Direct check
	if caller is ContextProvider or caller == self:
		return true
		
	# Fallback check: If 'caller' is null, check the script resource path
	var source_path = caller_frame.get("source")
	if source_path is String and source_path.contains("/providers/"):
		return true

	push_error("Security Violation: Unauthorized write by %s" % str(caller))
	return false
