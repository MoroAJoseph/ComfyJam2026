class_name Enums
extends RefCounted

'''
--- Developer Guidelines ---

- NONE/UNASSIGNED (Index 0): 
	- Use ONLY for Optional/Assignable states (e.g., Equipment).
	- Allows 'if enum_value:' to act as an "is_set" check.

- Categorical Enums (No NONE):
	- Use for fixed systems (e.g., AudioBus, DayPhase, Rarity).
	- ALWAYS use explicit comparison (e.g., 'if phase == DayPhase.DAWN:')
	- Never use 'if enum_value:' on these, as index 0 is a valid state.
''' 

# ===
# UI
# ===

enum GUIScale {
	QUARTER, 	# 1/4
	THIRD,		# 1/3
	HALF,		# 1/2
	FULL,		# 1
	DOUBLE,		# 2
	TRIPLE,		# 3
	QUADRUPLE	# 4
}

enum RenderQuality { 
	LOW, 
	MEDIUM, 
	HIGH 
}

enum MenuOption {
	MAIN,
	PAUSE,
	SETTINGS,
	DOCK,
	SAND_WITCH,
	CREDITS
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
# Audio
# ===

enum AudioBus {
	MASTER,
	MUSIC,
	SFX
}

# ===
# Gameplay
# ===

enum DayPhase {
	MIDNIGHT,
	DAWN,
	DAY,
	MIDDAY,
	DUSK,
	NIGHT
}

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
	NONE,
	RAFT,
	ROW_SMALL, 
	SHIP_SMALL, 
	SHIP_MEDIUM_2 
}

enum ToolType {
	NONE
}

enum BarrelType {
	WOOD,
	IRON,
	GOLD
}

enum BlockType { 
	NONE, 
	SAND, 
	DIRT, 
	STONE, 
	GRASS, 
	COAL_ORE, 
	COAL 
}

enum BlockCategory { 
	NONE, 
	TERRAIN, 	# ex. Dirt
	RESOURCE, 	# ex. Ore
	CONSTRUCTED # ex. Structural
}

enum BlockCapability {
	GENERATE, 	# Generates in the world
	CRAFT, 		# Created from crafting
	PLACE, 		# Places the block in the world
	COLLECT 	# Creates a BlockItem to collect
}
