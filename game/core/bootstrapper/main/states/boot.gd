# Boot
extends MainState

@export var enabled := true

# ===
# Public
# ===

func enter(_prev_state_path: String, _data: Object) -> void:
	print_debug("Main: Entered Boot")
	
	if enabled:
		_subscribe_events()
		EventBus.emit(
			MainEvent.LoadBootsplash.new()
		)
	else:
		_transition_to(StateName.GAME, null)

func exit() -> void:
	_unsubscribe_events()

func _subscribe_events() -> void:
	EventBus.subscribe(MainEvent.BootsplashLoaded, _handle_main_bootsplash_loaded)

func _unsubscribe_events() -> void:
	EventBus.unsubscribe(MainEvent.BootsplashLoaded, _handle_main_bootsplash_loaded)

# ===
# Event Handlers
# ===

func _handle_main_bootsplash_loaded(_event: MainEvent.BootsplashLoaded) -> void:
	print_debug("Main: Bootsplash Loaded")
	_transition_to(StateName.GAME, null)
