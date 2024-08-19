


















extends Node


signal logged(entry)
signal current_config_changed(config)


const LOG_NAME: = "ModLoader"




var UNPACKED_DIR: = "res://mods-unpacked/" setget , deprecated_direct_access_UNPACKED_DIR



var mod_data: = {} setget , deprecated_direct_access_mod_data




func _init()->void :
	
	_check_autoload_positions()

	
	if ModLoaderStore.REQUIRE_CMD_LINE and not _ModLoaderCLI.is_running_with_command_line_arg("--enable-mods"):
		return 

	
	ModLoaderLog._rotate_log_file()

	
	ModLoaderLog.debug_json_print("Autoload order", _ModLoaderGodot.get_autoload_array(), LOG_NAME)

	
	ModLoaderLog.info("game_install_directory: %s" % _ModLoaderPath.get_local_folder_dir(), LOG_NAME)

	if not ModLoaderStore.ml_options.enable_mods:
		ModLoaderLog.info("Mods are currently disabled", LOG_NAME)
		return 

	
	var _success_user_profile_load: = ModLoaderUserProfile._load()

	_load_mods()

	ModLoaderStore.is_initializing = false


func _ready():
	
	
	if not ModLoaderStore.user_profiles.has("default"):
		var _success_user_profile_create: = ModLoaderUserProfile.create_profile("default")

	
	var _success_update_mod_lists: = ModLoaderUserProfile._update_mod_lists()


func _exit_tree()->void :
	
	_ModLoaderCache.save_to_file()


func _load_mods()->void :
	
	
	var zip_data: = _load_mod_zips()

	if zip_data.empty():
		ModLoaderLog.info("No zipped mods found", LOG_NAME)
	else :
		ModLoaderLog.success("DONE: Loaded %s mod files into the virtual filesystem" % zip_data.size(), LOG_NAME)

	
	
	
	for mod_id in zip_data.keys():
		var zip_path:String = zip_data[mod_id]
		_init_mod_data(mod_id, zip_path)


	
	
	var setup_mods: = _setup_mods()
	if setup_mods > 0:
		ModLoaderLog.success("DONE: Setup %s mods" % setup_mods, LOG_NAME)
	else :
		ModLoaderLog.info("No mods were setup", LOG_NAME)

	
	ModLoaderUserProfile._update_disabled_mods()

	
	
	
	
	for dir_name in ModLoaderStore.mod_data:
		var mod:ModData = ModLoaderStore.mod_data[dir_name]
		mod.load_manifest()
		if mod.manifest.get("config_schema") and not mod.manifest.config_schema.empty():
			mod.load_configs()

	ModLoaderLog.success("DONE: Loaded all meta data", LOG_NAME)

	
	
	
	for dir_name in ModLoaderStore.mod_data:
		var mod:ModData = ModLoaderStore.mod_data[dir_name]
		if not mod.is_loadable:
			continue
		_ModLoaderDependency.check_load_before(mod)


	
	
	
	for dir_name in ModLoaderStore.mod_data:
		var mod:ModData = ModLoaderStore.mod_data[dir_name]
		if not mod.is_loadable:
			continue
		var _is_circular: = _ModLoaderDependency.check_dependencies(mod, false)


	
	
	for dir_name in ModLoaderStore.mod_data:
		var mod:ModData = ModLoaderStore.mod_data[dir_name]
		if not mod.is_loadable:
			continue
		var _is_circular: = _ModLoaderDependency.check_dependencies(mod)

	
	ModLoaderStore.mod_load_order = _ModLoaderDependency.get_load_order(ModLoaderStore.mod_data.values())

	
	var mod_i: = 1
	for mod in ModLoaderStore.mod_load_order:
		mod = mod as ModData
		ModLoaderLog.info("mod_load_order -> %s) %s" % [mod_i, mod.dir_name], LOG_NAME)
		mod_i += 1

	
	for mod in ModLoaderStore.mod_load_order:
		mod = mod as ModData

		
		if not mod.is_active:
			continue

		ModLoaderLog.info("Initializing -> %s" % mod.manifest.get_mod_id(), LOG_NAME)
		_init_mod(mod)

	ModLoaderLog.debug_json_print("mod data", ModLoaderStore.mod_data, LOG_NAME)

	ModLoaderLog.success("DONE: Completely finished loading mods", LOG_NAME)

	_ModLoaderScriptExtension.handle_script_extensions()

	ModLoaderLog.success("DONE: Installed all script extensions", LOG_NAME)

	ModLoaderStore.is_initializing = false



func _reload_mods()->void :
	_reset_mods()
	_load_mods()



func _reset_mods()->void :
	_disable_mods()
	ModLoaderStore.mod_data.clear()
	ModLoaderStore.mod_load_order.clear()
	ModLoaderStore.mod_missing_dependencies.clear()
	ModLoaderStore.script_extensions.clear()



func _disable_mods()->void :
	for mod in ModLoaderStore.mod_data:
		_disable_mod(ModLoaderStore.mod_data[mod])




func _check_autoload_positions()->void :
	var ml_options:Object = preload("res://addons/mod_loader/options/options.tres").current_options
	var override_cfg_path: = _ModLoaderPath.get_override_path()
	var is_override_cfg_setup: = _ModLoaderFile.file_exists(override_cfg_path)
	
	
	if is_override_cfg_setup:
		ModLoaderLog.info("override.cfg setup detected, ModLoader will be the last autoload loaded.", LOG_NAME)
		return 

	
	
	
	if ml_options.allow_modloader_autoloads_anywhere:
		_ModLoaderGodot.check_autoload_order("ModLoaderStore", "ModLoader", true)
	else :
		var _pos_ml_store: = _ModLoaderGodot.check_autoload_position("ModLoaderStore", 0, true)
		var _pos_ml_core: = _ModLoaderGodot.check_autoload_position("ModLoader", 1, true)




func _load_mod_zips()->Dictionary:
	var zip_data: = {}

	if not ModLoaderStore.ml_options.steam_workshop_enabled:
		var mods_folder_path: = _ModLoaderPath.get_path_to_mods()

		
		var loaded_zip_data: = _ModLoaderFile.load_zips_in_folder(mods_folder_path)
		zip_data.merge(loaded_zip_data)
	else :
		
		var loaded_workshop_zip_data: = _ModLoaderSteam.load_steam_workshop_zips()
		zip_data.merge(loaded_workshop_zip_data)

	return zip_data




func _setup_mods()->int:
	
	var unpacked_mods_path: = _ModLoaderPath.get_unpacked_mods_dir_path()

	var dir: = Directory.new()
	if not dir.open(unpacked_mods_path) == OK:
		ModLoaderLog.error("Can't open unpacked mods folder %s." % unpacked_mods_path, LOG_NAME)
		return - 1
	if not dir.list_dir_begin() == OK:
		ModLoaderLog.error("Can't read unpacked mods folder %s." % unpacked_mods_path, LOG_NAME)
		return - 1

	var unpacked_mods_count: = 0
	
	while true:
		
		var mod_dir_name: = dir.get_next()

		
		if mod_dir_name == "":
			
			break

		if (
			
			 not dir.current_is_dir()
			
			 or mod_dir_name.begins_with(".")
		):
			continue

		if ModLoaderStore.ml_options.disabled_mods.has(mod_dir_name):
			ModLoaderLog.info("Skipped setting up mod: \"%s\"" % mod_dir_name, LOG_NAME)
			continue

		
		if not ModLoaderStore.mod_data.has(mod_dir_name):
			_init_mod_data(mod_dir_name)

		unpacked_mods_count += 1

	dir.list_dir_end()
	return unpacked_mods_count





func _init_mod_data(mod_id:String, zip_path: = "")->void :
		
	var local_mod_path: = _ModLoaderPath.get_unpacked_mods_dir_path().plus_file(mod_id)

	var mod: = ModData.new()
	if not zip_path.empty():
		mod.zip_name = _ModLoaderPath.get_file_name_from_path(zip_path)
		mod.zip_path = zip_path
	mod.dir_path = local_mod_path
	mod.dir_name = mod_id
	var mod_overwrites_path: = mod.get_optional_mod_file_path(ModData.optional_mod_files.OVERWRITES)
	mod.is_overwrite = _ModLoaderFile.file_exists(mod_overwrites_path)
	mod.is_locked = true if mod_id in ModLoaderStore.ml_options.locked_mods else false
	ModLoaderStore.mod_data[mod_id] = mod

	
	
	
	
	
	if ModLoaderStore.DEBUG_ENABLE_STORING_FILEPATHS:
		mod.file_paths = _ModLoaderPath.get_flat_view_dict(local_mod_path)




func _init_mod(mod:ModData)->void :
	var mod_main_path: = mod.get_required_mod_file_path(ModData.required_mod_files.MOD_MAIN)
	var mod_overwrites_path: = mod.get_optional_mod_file_path(ModData.optional_mod_files.OVERWRITES)

	
	if mod.is_overwrite:
		ModLoaderLog.debug("Overwrite script detected -> %s" % mod_overwrites_path, LOG_NAME)
		var mod_overwrites_script: = load(mod_overwrites_path)
		mod_overwrites_script.new()
		ModLoaderLog.debug("Initialized overwrite script -> %s" % mod_overwrites_path, LOG_NAME)

	ModLoaderLog.debug("Loading script from -> %s" % mod_main_path, LOG_NAME)
	var mod_main_script:GDScript = ResourceLoader.load(mod_main_path)
	ModLoaderLog.debug("Loaded script -> %s" % mod_main_script, LOG_NAME)

	var argument_found:bool = false
	for method in mod_main_script.get_script_method_list():
		if method.name == "_init":
			if method.args.size() > 0:
				argument_found = true

	var mod_main_instance:Node
	if argument_found:
		mod_main_instance = mod_main_script.new(self)
		ModLoaderDeprecated.deprecated_message("The mod_main.gd _init argument (modLoader = ModLoader) is deprecated. Remove it from your _init to avoid crashes in the next major version.", "6.1.0")
	else :
		mod_main_instance = mod_main_script.new()
	mod_main_instance.name = mod.manifest.get_mod_id()

	ModLoaderStore.saved_mod_mains[mod_main_path] = mod_main_instance

	ModLoaderLog.debug("Adding child -> %s" % mod_main_instance, LOG_NAME)
	add_child(mod_main_instance, true)





func _disable_mod(mod:ModData)->void :
	if mod == null:
		ModLoaderLog.error("The provided ModData does not exist", LOG_NAME)
		return 
	var mod_main_path: = mod.get_required_mod_file_path(ModData.required_mod_files.MOD_MAIN)

	if not ModLoaderStore.saved_mod_mains.has(mod_main_path):
		ModLoaderLog.error("The provided Mod %s has no saved mod main" % mod.manifest.get_mod_id(), LOG_NAME)
		return 

	var mod_main_instance:Node = ModLoaderStore.saved_mod_mains[mod_main_path]
	if mod_main_instance.has_method("_disable"):
		mod_main_instance._disable()
	else :
		ModLoaderLog.warning("The provided Mod %s does not have a \"_disable\" method" % mod.manifest.get_mod_id(), LOG_NAME)

	ModLoaderStore.saved_mod_mains.erase(mod_main_path)
	_ModLoaderScriptExtension.remove_all_extensions_of_mod(mod)

	remove_child(mod_main_instance)





func install_script_extension(child_script_path:String)->void :
	ModLoaderDeprecated.deprecated_changed("ModLoader.install_script_extension", "ModLoaderMod.install_script_extension", "6.0.0")
	ModLoaderMod.install_script_extension(child_script_path)


func register_global_classes_from_array(new_global_classes:Array)->void :
	ModLoaderDeprecated.deprecated_changed("ModLoader.register_global_classes_from_array", "ModLoaderMod.register_global_classes_from_array", "6.0.0")
	ModLoaderMod.register_global_classes_from_array(new_global_classes)


func add_translation_from_resource(resource_path:String)->void :
	ModLoaderDeprecated.deprecated_changed("ModLoader.add_translation_from_resource", "ModLoaderMod.add_translation", "6.0.0")
	ModLoaderMod.add_translation(resource_path)


func append_node_in_scene(modified_scene:Node, node_name:String = "", node_parent = null, instance_path:String = "", is_visible:bool = true)->void :
	ModLoaderDeprecated.deprecated_changed("ModLoader.append_node_in_scene", "ModLoaderMod.append_node_in_scene", "6.0.0")
	ModLoaderMod.append_node_in_scene(modified_scene, node_name, node_parent, instance_path, is_visible)


func save_scene(modified_scene:Node, scene_path:String)->void :
	ModLoaderDeprecated.deprecated_changed("ModLoader.save_scene", "ModLoaderMod.save_scene", "6.0.0")
	ModLoaderMod.save_scene(modified_scene, scene_path)


func get_mod_config(mod_dir_name:String = "", key:String = "")->ModConfig:
	ModLoaderDeprecated.deprecated_changed("ModLoader.get_mod_config", "ModLoaderConfig.get_config", "6.0.0")
	return ModLoaderConfig.get_config(mod_dir_name, ModLoaderConfig.DEFAULT_CONFIG_NAME)


func deprecated_direct_access_UNPACKED_DIR()->String:
	ModLoaderDeprecated.deprecated_message("The const \"UNPACKED_DIR\" was removed, use \"ModLoaderMod.get_unpacked_dir()\" instead", "6.0.0")
	return _ModLoaderPath.get_unpacked_mods_dir_path()


func deprecated_direct_access_mod_data()->Dictionary:
	ModLoaderDeprecated.deprecated_message("The var \"mod_data\" was removed, use \"ModLoaderMod.get_mod_data_all()\" instead", "6.0.0")
	return ModLoaderStore.mod_data
