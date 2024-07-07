extends Node


const AUTHORNAME_MODNAME_DIR := "BaRRaK-BrotatoAI"
const AUTHORNAME_MODNAME_LOG_NAME := "BaRRaK-BrotatoAI:Main"

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""

# Before v6.1.0
# func _init(modLoader = ModLoader) -> void:
func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir() + AUTHORNAME_MODNAME_DIR + "/"
	extensions_dir_path = mod_dir_path + "extensions/"
	translations_dir_path = mod_dir_path + "translations/"
	
	# Add extensions
	ModLoaderMod.install_script_extension(extensions_dir_path + "main.gd")
	ModLoaderMod.install_script_extension(extensions_dir_path + "entities/units/movement_behaviors/player_movement_behavior.gd")
	# ModLoaderMod.install_script_extension(extensions_dir_path + "entities/units/player/player.gd")
	ModLoaderMod.install_script_extension(extensions_dir_path + "ui/menus/pages/main_menu.gd")

func _ready() -> void:
	ModLoaderLog.info("Ready!", AUTHORNAME_MODNAME_LOG_NAME)
