extends "res://main.gd"

func _ready():
	resize_elements()

	var _size_changed_value = get_tree().get_root().connect("size_changed", self, "resize_elements")
	var _size_changed_value_2 = get_tree().get_root().connect("size_changed", self, "init_camera")

# Override calculations to fix arena centering
func init_camera() -> void:
	var window_size = get_viewport().get_visible_rect().size

	var max_pos = ZoneService.current_zone_max_position
	var min_pos = ZoneService.current_zone_min_position

	var zone_w = max_pos.x - min_pos.x
	var zone_h = max_pos.y - min_pos.y

	_camera.center_horizontal_pos = zone_w / 2
	_camera.center_vertical_pos = zone_h / 2

	if zone_w + EDGE_SIZE * 2 <= window_size.x:
		_camera.center_horizontal = true
		_camera.limit_right = 10000000
		_camera.limit_left = -10000000
	else:
		_camera.center_horizontal = false
		_camera.limit_right = max_pos.x + EDGE_SIZE
		_camera.limit_left = min_pos.x - EDGE_SIZE

	if zone_h + EDGE_SIZE * 2 <= window_size.y:
		_camera.center_vertical = true
		_camera.limit_bottom = 10000000
		_camera.limit_top = -10000000
	else:
		_camera.center_vertical = false
		_camera.limit_bottom = max_pos.y + EDGE_SIZE
		_camera.limit_top = min_pos.y - EDGE_SIZE * 2

func resize_elements():
	var window_size = get_viewport().get_visible_rect().size
	# Set backgrount width to match window size
	_background.rect_size.y = window_size.x
	_background.rect_position.x = window_size.x

	# Set extra height to fix weird gray bar in top left corner
	_background.rect_size.x = window_size.y + 2
	_background.margin_top = -1