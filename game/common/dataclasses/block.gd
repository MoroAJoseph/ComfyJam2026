@tool
class_name BlockData
extends Resource

@export var type: Enums.BlockType
@export var display_name: String
@export var category: Enums.BlockCategory
@export var icon: Texture2D
@export var max_durability: int = 3
@export var required_strength: int = 1
@export var value: int = 10
@export var max_stack: int = 64
