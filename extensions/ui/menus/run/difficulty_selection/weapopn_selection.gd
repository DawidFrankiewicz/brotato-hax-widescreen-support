extends "res://ui/menus/run/weapon_selection.gd"

func _ready():
	# Change background mode
	$Background.expand = true
	resize_elements()

	var _size_changed_value = get_tree().get_root().connect("size_changed", self, "resize_elements")

func resize_elements():
	var window_size = get_viewport().get_visible_rect().size
	
	rect_size = window_size