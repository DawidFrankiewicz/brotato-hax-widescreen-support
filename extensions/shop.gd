extends "res://ui/menus/shop/shop.gd"

func _ready():
	resize_elements()

	var _size_changed_value = get_tree().get_root().connect("size_changed", self, "resize_elements")

func resize_elements():
	var window_size = get_viewport().get_visible_rect().size

	# Limit shop content to 1920 px width
	$Content.margin_left = (window_size.x - 1920) / 2
	$Content.margin_right = -((window_size.x - 1920) / 2)