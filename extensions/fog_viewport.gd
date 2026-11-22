extends "res://visual_effects/fog_viewport.gd"

# The fog texture is 1920x1080 and the wave scale falls toward 1, so late
# waves leave the sides of a wide screen outside the darkness. Lights stay
# in the same world mapping because their positions divide by the sprite scale.


func _initialize() -> void:
	._initialize()
	_cover_screen()


func _process(delta: float) -> void:
	_cover_screen()
	._process(delta)


func _cover_screen() -> void:
	if is_queued_for_deletion():
		return
	if fog_sprite == null or not is_instance_valid(fog_sprite):
		return
	var screen = get_tree().root.get_visible_rect().size
	# A few pixels of overlap hide rounding gaps at the edges.
	var covered = Vector2(
		ceil(max(screen.x, 1920.0)) + 4.0,
		ceil(max(screen.y, 1080.0)) + 4.0
	)
	if not size.is_equal_approx(covered):
		size = covered
	var darkness = get_node_or_null("ColorRect")
	if darkness is Control and not darkness.rect_size.is_equal_approx(covered):
		darkness.rect_position = Vector2.ZERO
		darkness.rect_size = covered
