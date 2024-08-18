extends Node

func _init() -> void:
	var dir = ModLoaderMod.get_unpacked_dir().plus_file("Hax-WidescreenSupport")
	ModLoaderMod.install_script_extension(dir + "/extensions/main.gd")

func _ready() -> void:
	ModLoaderLog.info("Ready!", "Hax-WidescreenSupport:Main")