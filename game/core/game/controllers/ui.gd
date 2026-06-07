class_name GameUIController
extends Node

@onready var paused_backdrop: ColorRect = %PausedBackdrop
@onready var hud_layer: UIHUDLayer = %HUDLayer
@onready var menus_layer: UIMenusLayer = %MenusLayer
@onready var loading_layer: UILoadingLayer = %LoadingLayer

# ===
# Built-In
# ===

func _ready() -> void:
	if paused_backdrop:
		paused_backdrop.hide()
	EventBus.subscribe(GameEvent.PausedUpdated, _handle_game_pause_updated)
	EventBus.subscribe(UIEvent.StartLoading, _handle_ui_start_loading)
	EventBus.subscribe(UIEvent.StopLoading, _handle_ui_stop_loading)
	EventBus.subscribe(UIEvent.HideAllMenus, _handle_ui_hide_all_menus)
	EventBus.subscribe(UIEvent.ToggleMenu, _handle_ui_toggle_menu)
	EventBus.subscribe(UIEvent.ToggleHUD, _handle_ui_toggle_hud)

func _exit_tree() -> void:
	EventBus.unsubscribe(GameEvent.PausedUpdated, _handle_game_pause_updated)
	EventBus.unsubscribe(UIEvent.StartLoading, _handle_ui_start_loading)
	EventBus.unsubscribe(UIEvent.StopLoading, _handle_ui_stop_loading)
	EventBus.unsubscribe(UIEvent.HideAllMenus, _handle_ui_hide_all_menus)
	EventBus.unsubscribe(UIEvent.ToggleMenu, _handle_ui_toggle_menu)
	EventBus.unsubscribe(UIEvent.ToggleHUD, _handle_ui_toggle_hud)

# ===
# Event Handlers
# ===

# --- Game ---
func _handle_game_pause_updated(event: GameEvent.PausedUpdated) -> void:
	if paused_backdrop:
		paused_backdrop.visible = event.is_paused

# --- UI ---
func _handle_ui_start_loading(_event: UIEvent.StartLoading) -> void:
	if loading_layer:
		loading_layer.start()

func _handle_ui_stop_loading(_event: UIEvent.StopLoading) -> void:
	if loading_layer:
		loading_layer.stop()

func _handle_ui_hide_all_menus(_event: UIEvent.HideAllMenus) -> void:
	if menus_layer:
		menus_layer.hide_all()

func _handle_ui_toggle_menu(event: UIEvent.ToggleMenu) -> void:
	menus_layer.toggle(
		event.option, 
		event.is_visible
	)

func _handle_ui_toggle_hud(event: UIEvent.ToggleHUD) -> void:
	hud_layer.toggle(
		event.is_visible
	)
