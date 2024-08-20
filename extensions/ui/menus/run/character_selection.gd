extends "res://ui/menus/run/character_selection.gd"

func _ready():
	var window_size = get_viewport().get_visible_rect().size

	if (window_size.x > 1920):
		# Change background size
		$Background.expand = true
		rect_size = window_size
