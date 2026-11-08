extends Node

const DESIGN_SIZE := Vector2(1920, 1080)

var _title: WeakRef
var _title_background: WeakRef
var _shop: WeakRef
var _character: WeakRef
var _main: WeakRef

var _tween_back: SceneTreeTween
var _tween_front: SceneTreeTween

const BACKGROUND_ANIMATION_TIME := 3.0
const BACKGROUND_SIZE_MULTIPLIER := 1.08
const ANIMATED_BACKGROUND_SIZE_MULTIPLIER := 1.16


func _ready() -> void:
	ModLoaderLog.info("Ready!", "Hax-WidescreenSupport:Main")
	_apply_stretch()
	var _node_added = get_tree().connect("node_added", self, "_on_node_added")
	var _size_changed = get_tree().get_root().connect("size_changed", self, "_on_size_changed")


func _apply_stretch() -> void:
	var window_size = get_viewport().get_visible_rect().size
	get_tree().set_screen_stretch(
		SceneTree.STRETCH_MODE_2D,
		SceneTree.STRETCH_ASPECT_EXPAND,
		window_size
	)
	window_size = get_viewport().get_visible_rect().size
	Utils.project_width = window_size.x
	Utils.project_height = window_size.y


func _on_size_changed() -> void:
	_apply_stretch()
	_refit(_title, "_fit_title")
	_refit(_title_background, "_fit_title_background")
	_refit(_shop, "_fit_shop")
	_refit(_character, "_fit_character")
	_refit(_main, "_fit_main")


func _on_node_added(node: Node) -> void:
	# Match scene roots by name. Referencing class_name BaseShop recompiles
	# base_shop.gd, which this Godot build rejects at line 211.
	if node.name == "TitleScreen" and node.get_node_or_null("Menus") != null:
		_title = weakref(node)
		call_deferred("_fit_title", node)
	elif (node.name == "Shop" or node.name == "CoopShop") and node.get_node_or_null("Content") != null:
		_shop = weakref(node)
		call_deferred("_fit_shop", node)
	elif node.name == "CharacterSelection" and node.get_node_or_null("Background") != null:
		_character = weakref(node)
		call_deferred("_fit_character", node)
	elif node.name == "Main" and node.get_node_or_null("CanvasLayer/Background") != null:
		_main = weakref(node)
		call_deferred("_fit_main", node)
	elif _is_title_background(node):
		_title_background = weakref(node)
		call_deferred("_fit_title_background", node)


func _refit(node_ref: WeakRef, method_name: String) -> void:
	if node_ref == null:
		return
	var node = node_ref.get_ref()
	if node != null and is_instance_valid(node):
		call(method_name, node)


func _is_title_background(node: Node) -> bool:
	var parent = node.get_parent()
	return parent != null and parent.name == "AnimatedBackgroundContainer" and node.has_node("Background")


func _fit_title(title: Node) -> void:
	var window_size = get_viewport().get_visible_rect().size
	var menus = title.get_node_or_null("Menus")
	if menus == null:
		return
	menus.rect_position = Vector2((window_size.x - DESIGN_SIZE.x) / 2.0, (window_size.y - DESIGN_SIZE.y) / 2.0)
	menus.rect_size = DESIGN_SIZE

	var background_container = title.get_node_or_null("AnimatedBackgroundContainer")
	if background_container == null:
		return
	for child in background_container.get_children():
		if _is_title_background(child):
			_title_background = weakref(child)
			_fit_title_background(child)


func _fit_title_background(background: Node) -> void:
	if _tween_back:
		_tween_back.kill()
		_tween_back = null
	if _tween_front:
		_tween_front.kill()
		_tween_front = null

	var window_size = get_viewport().get_visible_rect().size
	var art = background.get_node_or_null("Background")
	if art is TextureRect:
		art.rect_size.x = window_size.x * BACKGROUND_SIZE_MULTIPLIER
		art.rect_size.y = window_size.y
		art.stretch_mode = TextureRect.STRETCH_SCALE
		art.rect_position = Vector2(-(window_size.x * BACKGROUND_SIZE_MULTIPLIER - window_size.x) / 2.0, 0)

	_fit_mist(background, "BackgroundMistBack", window_size, true)
	_fit_mist(background, "BackgroundMistFront", window_size, false)

	var mist_mid = background.get_node_or_null("BackgroundMistMid")
	if mist_mid is TextureRect:
		mist_mid.rect_size = window_size
		mist_mid.stretch_mode = TextureRect.STRETCH_SCALE
		mist_mid.rect_position = Vector2.ZERO

	var post = background.get_node_or_null("BackgroundPostProcessing")
	if post is TextureRect:
		post.rect_size = window_size
		post.stretch_mode = TextureRect.STRETCH_SCALE
		post.rect_position = Vector2.ZERO


func _fit_mist(background: Node, node_name: String, window_size: Vector2, from_left: bool) -> void:
	var mist = background.get_node_or_null(node_name)
	if not mist is TextureRect:
		return

	var player = mist.get_node_or_null("AnimationPlayer")
	if player:
		player.stop()

	var wide = window_size.x * ANIMATED_BACKGROUND_SIZE_MULTIPLIER
	mist.rect_size = Vector2(wide, window_size.y)
	mist.stretch_mode = TextureRect.STRETCH_SCALE

	var inset = Vector2(-(wide - window_size.x), 0)
	var covered = Vector2.ZERO
	mist.rect_position = inset if from_left else covered

	var tween = create_tween().set_loops().set_trans(Tween.TRANS_QUAD)
	if from_left:
		_tween_back = tween
		tween.tween_property(mist, "rect_position", covered, BACKGROUND_ANIMATION_TIME)
		tween.tween_property(mist, "rect_position", inset, BACKGROUND_ANIMATION_TIME)
	else:
		_tween_front = tween
		tween.tween_property(mist, "rect_position", inset, BACKGROUND_ANIMATION_TIME)
		tween.tween_property(mist, "rect_position", covered, BACKGROUND_ANIMATION_TIME)


func _fit_shop(shop: Node) -> void:
	var content = shop.get_node_or_null("Content")
	if content == null:
		return
	var window_size = get_viewport().get_visible_rect().size
	var side = (window_size.x - DESIGN_SIZE.x) / 2.0
	content.margin_left = side
	content.margin_right = -side


func _fit_character(selection: Node) -> void:
	var window_size = get_viewport().get_visible_rect().size
	selection.rect_size = window_size
	var background = selection.get_node_or_null("Background")
	if background is TextureRect:
		background.expand = true
		background.rect_size = window_size


func _fit_main(main_node: Node) -> void:
	var background = main_node.get_node_or_null("CanvasLayer/Background")
	if background == null:
		return
	var window_size = get_viewport().get_visible_rect().size
	background.rect_size.y = window_size.x
	background.rect_position.x = window_size.x
	background.rect_size.x = window_size.y + 2
	background.margin_top = -1
