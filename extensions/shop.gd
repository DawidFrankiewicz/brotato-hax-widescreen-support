extends "res://ui/menus/shop/shop.gd"

func _ready():
	var window_size = get_viewport().get_visible_rect().size

	if (window_size.x > 1920):
		# Limit shop content to 1920 px width
		$Content.margin_left = (window_size.x - 1920) / 2
		$Content.margin_right = -((window_size.x - 1920) / 2)
