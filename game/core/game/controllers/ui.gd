class_name GameUIController
extends Node

@onready var hud_layer: UIHUDLayer = %HUDLayer
@onready var menus_layer: UIMenusLayer = %MenusLayer
@onready var loading_layer: UILoadingLayer = %LoadingLayer

# ===
# Built-In
# ===

func _ready() -> void:
	EventBus.subscribe(UIEvent.StartLoading, _handle_ui_start_loading)
	EventBus.subscribe(UIEvent.StopLoading, _handle_ui_stop_loading)
	EventBus.subscribe(UIEvent.HideAllMenus, _handle_ui_hide_all_menus)
	EventBus.subscribe(UIEvent.ToggleMenu, _handle_ui_toggle_menu)
	EventBus.subscribe(UIEvent.ToggleHUD, _handle_ui_toggle_hud)
	EventBus.subscribe(DockEvent.Interact, _handle_dock_interact)

# ===
# Event Handlers
# ===

func _handle_dock_interact(_event: DockEvent.Interact) -> void:
	menus_layer.toggle(
		UIContext.MenuOption.UPGRADES, 
		true
	)

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
