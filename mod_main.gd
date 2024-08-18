extends Node

func _init() -> void:
	var dir = ModLoaderMod.get_unpacked_dir().plus_file("Hax-WidescreenSupport")
	ModLoaderMod.install_script_extension(dir + "/extensions/main.gd")
	ModLoaderMod.install_script_extension(dir + "/extensions/shop.gd")

	# Override default project settings
	ProjectSettings.set_setting("display/window/stretch/aspect", "expand")
	ProjectSettings.save_custom("res://override.cfg")

func _ready() -> void:
	ModLoaderLog.info("Ready!", "Hax-WidescreenSupport:Main")