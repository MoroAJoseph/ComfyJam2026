extends PanelContainer

@onready var background: ColorRect = $Background
@onready var label: Label = $Label

func setup(rarity_name: String, color: Color) -> void:
	# Wait for ready if needed
	if not is_inside_tree(): await ready
	
	label.text = rarity_name.to_upper()
	background.color = color
	# Slightly darken the background so text is readable
	background.color.a = 0.5
