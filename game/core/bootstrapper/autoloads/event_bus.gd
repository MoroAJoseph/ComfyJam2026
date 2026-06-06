extends Node

# Map of Event Class (GDScript) to Array of Callables
var _subscribers: Dictionary[GDScript, Array] = {}

# Queue for handling nested events while emitting
var _event_queue: Array[Event] = []
var _is_emitting: bool = false

# ===
# Public
# ===

func subscribe(event_type: GDScript, callback: Callable) -> void:
	if not _subscribers.has(event_type):
		_subscribers[event_type] = []
	
	if not _subscribers[event_type].has(callback):
		_subscribers[event_type].append(callback)

func unsubscribe(event_type: GDScript, callback: Callable) -> void:
	if _subscribers.has(event_type):
		_subscribers[event_type].erase(callback)

func emit(event: Event) -> void:
	if _is_emitting:
		_event_queue.append(event)
		return
		
	_process_event(event)
	
	# Process nested/queued events after the main emission cycle
	while not _event_queue.is_empty():
		var next_event = _event_queue.pop_front()
		_process_event(next_event)

# ===
# Private
# ===

func _process_event(event: Event) -> void:
	_is_emitting = true
	var event_type = event.get_script()
	
	if _subscribers.has(event_type):
		# Cache current subscribers to prevent mutation issues during loop
		var current_subscribers = _subscribers[event_type].duplicate()
		
		for callback in current_subscribers:
			if callback.is_valid():
				callback.call(event)
			else:
				# Cleanup stale callbacks if they become invalid
				_subscribers[event_type].erase(callback)
	
	_is_emitting = false
