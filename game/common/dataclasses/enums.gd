class_name Enums
extends RefCounted

# ===
# UI
# ===

enum MenuOption {
	MAIN,
	PAUSE,
	SETTINGS,
	DOCK,
	SAND_WITCH
}

enum MainMenuAction { 
	OPEN, 
	CLOSE, 
	NEW, 
	PLAY, 
	EXIT, 
	SETTINGS 
}

enum PauseMenuAction { 
	OPEN, 
	CLOSE, 
	RESUME, 
	SETTINGS, 
	EXIT, 
	QUIT 
}

enum SettingsMenuAction { 
	OPEN,
	CLOSE 
}

enum DockMenuAction {
	OPEN,
	CLOSE,
	PURCHASE
}

enum SandWitchAction {
	OPEN,
	CLOSE
}

# ===
# Gameplay
# ===

enum RarityType {
	COMMON,
	RARE,
	EPIC,
	LEGENDARY
}

enum ChestType {
	WOOD,
	IRON,
	GOLD,
	MYSTIC
}

enum BoatType { 
	ROW_SMALL, 
	SHIP_SMALL, 
	SHIP_MEDIUM_2 
}

enum ToolType {
	
}
