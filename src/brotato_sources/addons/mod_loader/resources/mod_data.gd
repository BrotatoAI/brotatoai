class_name ModData
extends Resource




const LOG_NAME: = "ModLoader:ModData"




const USE_EXTENDED_DEBUGLOG: = false




enum required_mod_files{
	MOD_MAIN, 
	MANIFEST, 
}

enum optional_mod_files{
	OVERWRITES
}


var zip_name: = ""

var zip_path: = ""

var dir_name: = ""

var dir_path: = ""

var is_loadable: = true

var is_overwrite: = false

var is_locked: = false

var is_active: = true

var importance: = 0

var manifest:ModManifest

var configs: = {}
var current_config:ModConfig setget _set_current_config


var file_paths:PoolStringArray = []



func load_manifest()->void :
	if not _has_required_files():
		return 

	ModLoaderLog.info("Loading mod_manifest (manifest.json) for -> %s" % dir_name, LOG_NAME)

	
	var manifest_path: = get_required_mod_file_path(required_mod_files.MANIFEST)
	var manifest_dict: = _ModLoaderFile.get_json_as_dict(manifest_path)

	if USE_EXTENDED_DEBUGLOG:
		ModLoaderLog.debug_json_print("%s loaded manifest data -> " % dir_name, manifest_dict, LOG_NAME)
	else :
		ModLoaderLog.debug(str("%s loaded manifest data -> " % dir_name, manifest_dict), LOG_NAME)

	var mod_manifest: = ModManifest.new(manifest_dict)

	is_loadable = _has_manifest(mod_manifest)
	if not is_loadable:return 
	is_loadable = _is_mod_dir_name_same_as_id(mod_manifest)
	if not is_loadable:return 
	manifest = mod_manifest



func load_configs()->void :
	
	if not manifest.load_mod_config_defaults():
		return 

	var config_dir_path: = _ModLoaderPath.get_path_to_mod_configs_dir(dir_name)
	var config_file_paths: = _ModLoaderPath.get_file_paths_in_dir(config_dir_path)
	for config_file_path in config_file_paths:
		_load_config(config_file_path)

	
	current_config = ModLoaderConfig.get_current_config(dir_name)



func _load_config(config_file_path:String)->void :
	var config_data: = _ModLoaderFile.get_json_as_dict(config_file_path)
	var mod_config = ModConfig.new(
		dir_name, 
		config_data, 
		config_file_path, 
		manifest.config_schema
	)

	
	configs[mod_config.name] = mod_config



func _set_current_config(new_current_config:ModConfig)->void :
	ModLoaderUserProfile.set_mod_current_config(dir_name, new_current_config)
	current_config = new_current_config
	ModLoader.emit_signal("current_config_changed", new_current_config)



func _is_mod_dir_name_same_as_id(mod_manifest:ModManifest)->bool:
	var manifest_id: = mod_manifest.get_mod_id()
	if not dir_name == manifest_id:
		ModLoaderLog.fatal("Mod directory name \"%s\" does not match the data in manifest.json. Expected \"%s\" (Format: {namespace}-{name})" % [dir_name, manifest_id], LOG_NAME)
		return false
	return true



func _has_required_files()->bool:
	for required_file in required_mod_files:
		var file_path: = get_required_mod_file_path(required_mod_files[required_file])

		if not _ModLoaderFile.file_exists(file_path):
			ModLoaderLog.fatal("ERROR - %s is missing a required file: %s" % [dir_name, file_path], LOG_NAME)
			is_loadable = false
	return is_loadable



func _has_manifest(mod_manifest:ModManifest)->bool:
	if mod_manifest == null:
		ModLoaderLog.fatal("Mod manifest could not be created correctly due to errors.", LOG_NAME)
		return false
	return true



func get_required_mod_file_path(required_file:int)->String:
	match required_file:
		required_mod_files.MOD_MAIN:
			return dir_path.plus_file("mod_main.gd")
		required_mod_files.MANIFEST:
			return dir_path.plus_file("manifest.json")
	return ""

func get_optional_mod_file_path(optional_file:int)->String:
	match optional_file:
		optional_mod_files.OVERWRITES:
			return dir_path.plus_file("overwrites.gd")
	return ""
