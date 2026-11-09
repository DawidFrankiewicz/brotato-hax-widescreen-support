extends Node

const DESIGN_SIZE := Vector2(1920, 1080)

var _title: WeakRef
var _title_background: WeakRef
var _shop: WeakRef
var _character: WeakRef
var _main: WeakRef
var _backdrops: Array = []
var _pause_menus: Array = []

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
	_refit_backdrops()
	_refit_pause_menus()


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
	elif _is_menu_backdrop(node):
		_backdrops.append(weakref(node))
		call_deferred("_fit_backdrop", node)
	elif node.name == "PauseMenu" and node.get_node_or_null("Menus") != null:
		_pause_menus.append(weakref(node))
		call_deferred("_fit_pause_menu", node)
	elif node.name == "BackgroundButton" and node is OptionButton:
		if not node.is_connected("item_selected", self, "_on_zone_background_selected"):
			node.connect("item_selected", self, "_on_zone_background_selected")


func _refit(node_ref: WeakRef, method_name: String) -> void:
	if node_ref == null:
		return
	var node = node_ref.get_ref()
	if node != null and is_instance_valid(node):
		call(method_name, node)


func _is_title_background(node: Node) -> bool:
	var parent = node.get_parent()
	return parent != null and parent.name == "AnimatedBackgroundContainer" and node is Control


func _is_menu_backdrop(node: Node) -> bool:
	if not node is TextureRect or node.name != "Background":
		return false
	var parent = node.get_parent()
	if parent == null or parent.name == "CanvasLayer":
		return false
	return not _is_under(node, "AnimatedBackgroundContainer")


func _is_under(node: Node, ancestor_name: String) -> bool:
	var current = node.get_parent()
	while current != null:
		if current.name == ancestor_name:
			return true
		current = current.get_parent()
	return false


func _refit_backdrops() -> void:
	var alive = []
	for backdrop_ref in _backdrops:
		var backdrop = backdrop_ref.get_ref()
		if backdrop != null and is_instance_valid(backdrop):
			alive.append(backdrop_ref)
			_fit_backdrop(backdrop)
	_backdrops = alive


func _refit_pause_menus() -> void:
	var alive = []
	for menu_ref in _pause_menus:
		var menu = menu_ref.get_ref()
		if menu != null and is_instance_valid(menu):
			alive.append(menu_ref)
			_fit_pause_menu(menu)
	_pause_menus = alive


func _fit_pause_menu(pause_menu: Node) -> void:
	var menus = pause_menu.get_node_or_null("Menus")
	if menus == null:
		return
	var window_size = get_viewport().get_visible_rect().size
	menus.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	menus.rect_min_size.x = min(DESIGN_SIZE.x, window_size.x)
	if pause_menu is Container:
		pause_menu.queue_sort()


func _fit_backdrop(art: TextureRect) -> void:
	var window_size = get_viewport().get_visible_rect().size
	art.anchor_left = 0
	art.anchor_top = 0
	art.anchor_right = 0
	art.anchor_bottom = 0
	art.expand = true
	art.stretch_mode = TextureRect.STRETCH_SCALE
	art.rect_position = Vector2.ZERO
	art.rect_size = window_size


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
		if child.is_queued_for_deletion():
			continue
		if _is_title_background(child):
			_title_background = weakref(child)
			_fit_title_background(child)


func _on_zone_background_selected(_index: int) -> void:
	call_deferred("_apply_zone_background")


func _apply_zone_background() -> void:
	var background = RunData.get_background()
	if background == null:
		return
	var sprite = background.get_tiles_sprite()
	_apply_zone_background_to(get_tree().get_root(), background, sprite)


func _apply_zone_background_to(node: Node, background, sprite) -> void:
	if node.has_method("_update_bg"):
		node.call("_update_bg")
	if node.name == "TileMap" and node.get_parent() != null and node.get_parent().name == "Main" and node.tile_set != null:
		node.tile_set.tile_set_texture(0, sprite)
		var outline = node.get_node_or_null("Outline")
		if outline != null:
			outline.modulate = background.outline_color
	for child in node.get_children():
		_apply_zone_background_to(child, background, sprite)


func _fit_title_background(background: Node) -> void:
	if not is_instance_valid(background) or background.is_queued_for_deletion():
		return
	# The previous art is freed on the same frame. Kill its tweens first, or
	# set_loops() keeps stepping a dead node and Godot reports an infinite loop.
	_kill_mist_tweens()
	if background.has_node("BackgroundMistBack"):
		_fit_classic_title_background(background)
	elif background is Control:
		_fit_scaled_scene(background)


func _kill_mist_tweens() -> void:
	if _tween_back and is_instance_valid(_tween_back):
		_tween_back.kill()
	_tween_back = null
	if _tween_front and is_instance_valid(_tween_front):
		_tween_front.kill()
	_tween_front = null


func _fit_scaled_scene(background: Control) -> void:
	var window_size = get_viewport().get_visible_rect().size
	if background.anchor_right > 0.5 or background.anchor_bottom > 0.5 or background.rect_size.x > 200.0:
		background.anchor_left = 0
		background.anchor_top = 0
		background.anchor_right = 0
		background.anchor_bottom = 0
		background.margin_left = 0
		background.margin_top = 0
		background.margin_right = DESIGN_SIZE.x
		background.margin_bottom = DESIGN_SIZE.y
		background.rect_position = Vector2.ZERO
	background.rect_pivot_offset = Vector2.ZERO
	background.rect_scale = Vector2(window_size.x / DESIGN_SIZE.x, window_size.y / DESIGN_SIZE.y)


func _fit_classic_title_background(background: Node) -> void:
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

	var tween = create_tween().bind_node(mist).set_loops().set_trans(Tween.TRANS_QUAD)
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
