extends "res://main.gd"

func init_camera() -> void:
	var max_pos = ZoneService.current_zone_max_position
	var min_pos = ZoneService.current_zone_min_position

	var zone_w = max_pos.x - min_pos.x
	var zone_h = max_pos.y - min_pos.y

	_camera.center_horizontal_pos = zone_w / 2
	_camera.center_vertical_pos = zone_h / 2
	
	if zone_w + EDGE_SIZE * 2 <= get_viewport().get_visible_rect().size.x:
		_camera.center_horizontal = true
	else:
		_camera.limit_right = max_pos.x + EDGE_SIZE
		_camera.limit_left = min_pos.x - EDGE_SIZE

	if zone_h + EDGE_SIZE * 2 <= get_viewport().get_visible_rect().size.y:
		_camera.center_vertical = true
	else:
		_camera.limit_bottom = max_pos.y + EDGE_SIZE
		_camera.limit_top = min_pos.y - EDGE_SIZE * 2