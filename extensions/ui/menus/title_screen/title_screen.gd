extends "res://ui/menus/title_screen/title_screen.gd"

var background_animation_time = 3
var background_size_multiplier = 1.08
var animated_background_size_multiplier = 1.16

var tween_back: SceneTreeTween
var tween_front: SceneTreeTween

func _ready():
	resize_elements()
	var _size_changed_value = get_tree().get_root().connect("size_changed", self, "resize_elements")
	
func resize_elements():
	if (tween_back):
		tween_back.kill()
		tween_back = null
	if (tween_front):
		tween_front.kill()
		tween_front = null

	var window_size = get_viewport().get_visible_rect().size

	# Center container
	set_anchors_and_margins_preset(Control.PRESET_HCENTER_WIDE)
	rect_position = Vector2(window_size.x / 2, 0)
	margin_left = (window_size.x - 1920) / 2
	margin_right = -((window_size.x - 1920) / 2)

	# Center UI container
	$MarginContainer.rect_size = Vector2(1920, 1080)

	# Post processing
	$BackgroundPostProcessing.rect_size = window_size
	$BackgroundPostProcessing.stretch_mode = 1
	$BackgroundPostProcessing.rect_position.x = -((window_size.x - 1920) / 2)

	# Background
	$Background.rect_size.x = window_size.x * background_size_multiplier
	$Background.stretch_mode = 1
	$Background.rect_position = Vector2(-((window_size.x * background_size_multiplier - 1920) / 2), 0)

	# Background Mist Back
	$BackgroundMistBack/AnimationPlayer.stop()
	$BackgroundMistBack.rect_size = Vector2(window_size.x * animated_background_size_multiplier, window_size.y)
	$BackgroundMistBack.stretch_mode = 1
	$BackgroundMistBack.rect_position.x = -((window_size.x * animated_background_size_multiplier - 1920) / 2)

	## Recreate animation with tween
	tween_back = create_tween().set_loops().set_trans(Tween.TRANS_QUAD)
	var _unused_1 = tween_back.tween_property($BackgroundMistBack, "rect_position", Vector2(-((window_size.x - 1920) / 2), 0), background_animation_time)
	var _unused_2 = tween_back.tween_property($BackgroundMistBack, "rect_position", Vector2(-((window_size.x * animated_background_size_multiplier - 1920) / 2), 0), background_animation_time)


	# Background Mist Mid
	$BackgroundMistMid.rect_size = window_size
	$BackgroundMistMid.stretch_mode = 1
	$BackgroundMistMid.rect_position.x = -((window_size.x - 1920) / 2)

	# Background Mist Front
	$BackgroundMistFront/AnimationPlayer.stop()
	$BackgroundMistFront.rect_size = Vector2(window_size.x * animated_background_size_multiplier, window_size.y)
	$BackgroundMistFront.stretch_mode = 1
	$BackgroundMistFront.rect_position.x = -((window_size.x - 1920) / 2)

	## Recreate animation with tween
	tween_front = create_tween().set_loops().set_trans(Tween.TRANS_QUAD)
	var _unused_3 = tween_front.tween_property($BackgroundMistFront, "rect_position", Vector2(-((window_size.x * animated_background_size_multiplier - 1920) / 2), 0), background_animation_time)
	var _unused_4 = tween_front.tween_property($BackgroundMistFront, "rect_position", Vector2(-((window_size.x - 1920) / 2), 0), background_animation_time)
