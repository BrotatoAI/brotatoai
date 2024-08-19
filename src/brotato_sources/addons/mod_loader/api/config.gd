
class_name ModLoaderConfig
extends Object


const LOG_NAME: = "ModLoader:Config"
const DEFAULT_CONFIG_NAME: = "default"











static func create_config(mod_id:String, config_name:String, config_data:Dictionary)->ModConfig:
	
	var default_config:ModConfig = get_default_config(mod_id)
	if not default_config:
		ModLoaderLog.error(
			"Failed to create config \"%s\". No config schema found for \"%s\"."
			 % [config_name, mod_id], LOG_NAME
		)
		return null

	
	if config_name == "":
		ModLoaderLog.error(
			"Failed to create config \"%s\". The config name cannot be empty."
			 % config_name, LOG_NAME
		)
		return null

	
	if ModLoaderStore.mod_data[mod_id].configs.has(config_name):
		ModLoaderLog.error(
			"Failed to create config \"%s\". A config with the name \"%s\" already exists."
			 % [config_name, config_name], LOG_NAME
		)
		return null

	
	var config_file_path: = _ModLoaderPath.get_path_to_mod_configs_dir(mod_id).plus_file("%s.json" % config_name)

	
	var mod_config: = ModConfig.new(
		mod_id, 
		config_data, 
		config_file_path
	)

	
	if not mod_config.is_valid:
		return null

	
	ModLoaderStore.mod_data[mod_id].configs[config_name] = mod_config
	
	var is_save_success: = mod_config.save_to_file()

	if not is_save_success:
		return null

	ModLoaderLog.debug("Created new config \"%s\" for mod \"%s\"" % [config_name, mod_id], LOG_NAME)

	return mod_config









static func update_config(config:ModConfig)->ModConfig:
	
	var error_message: = config.validate()

	
	if config.name == DEFAULT_CONFIG_NAME:
		ModLoaderLog.error("The \"default\" config cannot be modified. Please create a new config instead.", LOG_NAME)
		return null

	
	if not config.is_valid:
		ModLoaderLog.error("Update for config \"%s\" failed validation with error message \"%s\"" % [config.name, error_message], LOG_NAME)
		return null

	
	var is_save_success: = config.save_to_file()

	if not is_save_success:
		ModLoaderLog.error("Failed to save config \"%s\" to \"%s\"." % [config.name, config.save_path], LOG_NAME)
		return null

	
	return config









static func delete_config(config:ModConfig)->bool:
	
	if config.name == DEFAULT_CONFIG_NAME:
		ModLoaderLog.error("Deletion of the default configuration is not allowed.", LOG_NAME)
		return false

	
	set_current_config(get_default_config(config.mod_id))

	
	var is_remove_success: = config.remove_file()

	if not is_remove_success:
		return false

	
	ModLoaderStore.mod_data[config.mod_id].configs.erase(config.name)

	return true






static func set_current_config(config:ModConfig)->void :
	ModLoaderStore.mod_data[config.mod_id].current_config = config










static func get_config_schema(mod_id:String)->Dictionary:
	
	var mod_configs: = get_configs(mod_id)

	
	if mod_configs.empty():
		return {}

	
	return mod_configs.default.schema











static func get_schema_for_prop(config:ModConfig, prop:String)->Dictionary:
	
	var prop_array: = prop.split(".")

	
	if prop_array.empty():
		return config.schema.properties[prop]

	
	var schema_for_prop: = _traverse_schema(config.schema.properties, prop_array)

	
	if schema_for_prop.empty():
		ModLoaderLog.error("No Schema found for property \"%s\" in config \"%s\" for mod \"%s\"" % [prop, config.name, config.mod_id], LOG_NAME)
		return {}

	return schema_for_prop












static func _traverse_schema(schema_prop:Dictionary, prop_key_array:Array)->Dictionary:
	
	if prop_key_array.empty():
		return schema_prop

	
	var prop_key:String = prop_key_array.pop_front()

	
	if not schema_prop.has(prop_key):
		return {}

	schema_prop = schema_prop[prop_key]

	
	if schema_prop.has("type") and schema_prop.type == "object" and not prop_key_array.empty():
		
		schema_prop = schema_prop.properties

	schema_prop = _traverse_schema(schema_prop, prop_key_array)

	return schema_prop






static func get_mods_with_config()->Array:
	
	var mods_with_config: = []

	
	for mod_id in ModLoaderStore.mod_data:
		
		
		var mod_data = ModLoaderStore.mod_data[mod_id]

		
		if not mod_data.configs.empty():
			mods_with_config.push_back(mod_data)

	
	return mods_with_config










static func get_configs(mod_id:String)->Dictionary:
	
	if not ModLoaderStore.mod_data.has(mod_id):
		ModLoaderLog.fatal("Mod ID \"%s\" not found" % [mod_id], LOG_NAME)
		return {}

	var config_dictionary:Dictionary = ModLoaderStore.mod_data[mod_id].configs

	
	if config_dictionary.empty():
		ModLoaderLog.debug("No config for mod id \"%s\"" % mod_id, LOG_NAME, true)
		return {}

	return config_dictionary











static func get_config(mod_id:String, config_name:String)->ModConfig:
	var configs: = get_configs(mod_id)

	if not configs.has(config_name):
		ModLoaderLog.error("No config with name \"%s\" found for mod_id \"%s\" " % [config_name, mod_id], LOG_NAME)
		return null

	return configs[config_name]











static func get_default_config(mod_id:String)->ModConfig:
	return get_config(mod_id, DEFAULT_CONFIG_NAME)









static func get_current_config(mod_id:String)->ModConfig:
	var current_config_name: = get_current_config_name(mod_id)
	var current_config: = get_config(mod_id, current_config_name)

	return current_config










static func get_current_config_name(mod_id:String)->String:
	
	if not ModLoaderStore.current_user_profile or not ModLoaderStore.user_profiles.has(ModLoaderStore.current_user_profile.name):
		
		ModLoaderLog.warning("Can't get current mod config for \"%s\", because no current user profile is present." % mod_id, LOG_NAME)
		return ""

	
	
	var current_user_profile = ModLoaderStore.current_user_profile

	
	if not current_user_profile.mod_list.has(mod_id) or not current_user_profile.mod_list[mod_id].has("current_config"):
		
		ModLoaderLog.error("Mod \"%s\" has no config file." % mod_id, LOG_NAME)
		return ""

	
	return current_user_profile.mod_list[mod_id].current_config
