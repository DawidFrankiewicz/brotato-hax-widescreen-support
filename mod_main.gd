extends Node

func _init() -> void:
	var dir = ModLoaderMod.get_unpacked_dir().plus_file("Hax-WidescreenSupport")
	ModLoaderMod.install_script_extension(dir + "/extensions/main.gd")
	ModLoaderMod.install_script_extension(dir + "/extensions/shop.gd")

func _ready() -> void:
	ModLoaderLog.info("Ready!", "Hax-WidescreenSupport:Main")

	# Set screen stretch
	var window_size = get_viewport().get_visible_rect().size
	get_tree().set_screen_stretch(
				SceneTree.STRETCH_MODE_2D,
				SceneTree.STRETCH_ASPECT_EXPAND,
				window_size
			)
