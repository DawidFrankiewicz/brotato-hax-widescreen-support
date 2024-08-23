extends "res://ui/menus/title_screen/title_screen.gd"

func _ready():
	resize_elements()
	var _size_changed_value = get_tree().get_root().connect("size_changed", self, "resize_elements")
	
func resize_elements():
	var window_size = get_viewport().get_visible_rect().size

	# Center container
	set_anchors_and_margins_preset(Control.PRESET_HCENTER_WIDE)
	rect_position = Vector2(window_size.x / 2, 0)
	margin_left = (window_size.x - 1920) / 2
	margin_right = -((window_size.x - 1920) / 2)

	# Center background
	$Background.rect_position = Vector2(-($Background.rect_size.x - 1920) / 2, 0)

	# Center UI
	$MarginContainer.rect_size = Vector2(1920, 1080)
