
class_name ModLoaderUserProfile
extends Object


const LOG_NAME: = "ModLoader:UserProfile"


const FILE_PATH_USER_PROFILES: = "user://mod_user_profiles.json"













static func enable_mod(mod_id:String, user_profile: = ModLoaderStore.current_user_profile)->bool:
	return _set_mod_state(mod_id, user_profile.name, true)









static func disable_mod(mod_id:String, user_profile: = ModLoaderStore.current_user_profile)->bool:
	return _set_mod_state(mod_id, user_profile.name, false)










static func set_mod_current_config(mod_id:String, mod_config:ModConfig, user_profile: = ModLoaderStore.current_user_profile)->bool:
	
	if not _is_mod_id_in_mod_list(mod_id, user_profile.name):
		return false

	
	user_profile.mod_list[mod_id].current_config = mod_config.name

	
	var is_save_success: = _save()

	if is_save_success:
		ModLoaderLog.debug("Set the \"current_config\" of \"%s\" to \"%s\" in user profile \"%s\" " % [mod_id, mod_config.name, user_profile.name], LOG_NAME)

	return is_save_success








static func create_profile(profile_name:String)->bool:
	
	if ModLoaderStore.user_profiles.has(profile_name):
		ModLoaderLog.error("User profile with the name of \"%s\" already exists." % profile_name, LOG_NAME)
		return false

	var mod_list: = _generate_mod_list()

	var new_profile: = _create_new_profile(profile_name, mod_list)

	
	if not new_profile:
		return false

	
	ModLoaderStore.user_profiles[profile_name] = new_profile

	
	ModLoaderStore.current_user_profile = ModLoaderStore.user_profiles[profile_name]

	
	var is_save_success: = _save()

	if is_save_success:
		ModLoaderLog.debug("Created new user profile \"%s\"" % profile_name, LOG_NAME)

	return is_save_success








static func set_profile(user_profile:ModUserProfile)->bool:
	
	if not ModLoaderStore.user_profiles.has(user_profile.name):
		ModLoaderLog.error("User profile with name \"%s\" not found." % user_profile.name, LOG_NAME)
		return false

	
	ModLoaderStore.current_user_profile = ModLoaderStore.user_profiles[user_profile.name]

	
	var is_save_success: = _save()

	if is_save_success:
		ModLoaderLog.debug("Current user profile set to \"%s\"" % user_profile.name, LOG_NAME)

	return is_save_success








static func delete_profile(user_profile:ModUserProfile)->bool:
	
	if ModLoaderStore.current_user_profile.name == user_profile.name:
		ModLoaderLog.error(str(
			"You cannot delete the currently selected user profile \"%s\" " + 
			"because it is currently in use. Please switch to a different profile before deleting this one.") % user_profile.name, 
		LOG_NAME)
		return false

	
	if user_profile.name == "default":
		ModLoaderLog.error("You can't delete the default profile", LOG_NAME)
		return false

	
	if not ModLoaderStore.user_profiles.erase(user_profile.name):
		
		ModLoaderLog.error("User profile with name \"%s\" not found." % user_profile.name, LOG_NAME)
		return false

	
	var is_save_success: = _save()

	if is_save_success:
		ModLoaderLog.debug("Deleted user profile \"%s\"" % user_profile.name, LOG_NAME)

	return is_save_success





static func get_current()->ModUserProfile:
	return ModLoaderStore.current_user_profile








static func get_profile(profile_name:String)->ModUserProfile:
	if not ModLoaderStore.user_profiles.has(profile_name):
		ModLoaderLog.error("User profile with name \"%s\" not found." % profile_name, LOG_NAME)
		return null

	return ModLoaderStore.user_profiles[profile_name]





static func get_all_as_array()->Array:
	var user_profiles: = []

	for user_profile_name in ModLoaderStore.user_profiles.keys():
		user_profiles.push_back(ModLoaderStore.user_profiles[user_profile_name])

	return user_profiles










static func _update_disabled_mods()->void :
	var current_user_profile:ModUserProfile

	current_user_profile = get_current()

	
	if not current_user_profile:
		ModLoaderLog.info("There is no current user profile. The \"default\" profile will be created.", LOG_NAME)
		return 

	
	for mod_id in current_user_profile.mod_list:
		var mod_list_entry:Dictionary = current_user_profile.mod_list[mod_id]
		if ModLoaderStore.mod_data.has(mod_id):
			ModLoaderStore.mod_data[mod_id].is_active = mod_list_entry.is_active

	ModLoaderLog.debug(
		"Updated the active state of all mods, based on the current user profile \"%s\""
		 % current_user_profile.name, 
	LOG_NAME)





static func _update_mod_lists()->bool:
	
	
	var current_mod_list: = _generate_mod_list()

	
	for profile_name in ModLoaderStore.user_profiles.keys():
		var profile:ModUserProfile = ModLoaderStore.user_profiles[profile_name]

		
		profile.mod_list.merge(current_mod_list)

		var update_mod_list: = _update_mod_list(profile.mod_list)

		profile.mod_list = update_mod_list

	
	var is_save_success: = _save()

	if is_save_success:
		ModLoaderLog.debug("Updated the mod lists of all user profiles", LOG_NAME)

	return is_save_success






static func _update_mod_list(mod_list:Dictionary, mod_data: = ModLoaderStore.mod_data)->Dictionary:
	var updated_mod_list: = mod_list.duplicate(true)

	
	for mod_id in updated_mod_list.keys():
		var mod_list_entry:Dictionary = updated_mod_list[mod_id]

		
		
		if mod_list_entry.has("current_config") and _ModLoaderPath.get_path_to_mod_config_file(mod_id, mod_list_entry.current_config).empty():
			
			mod_list_entry.current_config = ModLoaderConfig.DEFAULT_CONFIG_NAME

		if (
			
			 not mod_data.has(mod_id) and 
			
			mod_list_entry.has("zip_path") and 
			
			 not mod_list_entry.zip_path.empty() and 
			
			 not _ModLoaderFile.file_exists(mod_list_entry.zip_path)
		):
			
			
			ModLoaderLog.debug(
				"Mod \"%s\" has been deleted from all user profiles as the corresponding zip file no longer exists at path \"%s\"."
				 % [mod_id, mod_list_entry.zip_path], 
				LOG_NAME, 
				true
			)

			updated_mod_list.erase(mod_id)
			continue

		updated_mod_list[mod_id] = mod_list_entry

	return updated_mod_list



static func _generate_mod_list()->Dictionary:
	var mod_list: = {}

	
	for mod_id in ModLoaderStore.mod_data.keys():
		mod_list[mod_id] = _generate_mod_list_entry(mod_id, true)

	
	for mod_id in ModLoaderStore.ml_options.disabled_mods:
		mod_list[mod_id] = _generate_mod_list_entry(mod_id, false)

	return mod_list




static func _generate_mod_list_entry(mod_id:String, is_active:bool)->Dictionary:
	var mod_list_entry: = {}

	
	mod_list_entry.is_active = is_active

	
	if ModLoaderStore.mod_data.has(mod_id):
		mod_list_entry.zip_path = ModLoaderStore.mod_data[mod_id].zip_path

	
	if is_active and not ModLoaderConfig.get_config_schema(mod_id).empty():
		var current_config:ModConfig = ModLoaderStore.mod_data[mod_id].current_config
		if current_config and current_config.is_valid:
			
			mod_list_entry.current_config = current_config.name
		else :
			
			mod_list_entry.current_config = ModLoaderConfig.DEFAULT_CONFIG_NAME

	return mod_list_entry



static func _set_mod_state(mod_id:String, profile_name:String, activate:bool)->bool:
	
	if not _is_mod_id_in_mod_list(mod_id, profile_name):
		return false

	
	if ModLoaderStore.mod_data.has(mod_id) and ModLoaderStore.mod_data[mod_id].is_locked:
		ModLoaderLog.error(
			"Unable to disable mod \"%s\" as it is marked as locked. Locked mods: %s"
			 % [mod_id, ModLoaderStore.ml_options.locked_mods], 
		LOG_NAME)
		return false

	
	
	ModLoaderStore.user_profiles[profile_name].mod_list[mod_id].is_active = activate
	
	ModLoaderStore.mod_data[mod_id].is_active = activate

	
	var is_save_success: = _save()

	if is_save_success:
		ModLoaderLog.debug("Mod activation state changed: mod_id=%s activate=%s profile_name=%s" % [mod_id, activate, profile_name], LOG_NAME)

	return is_save_success




static func _is_mod_id_in_mod_list(mod_id:String, profile_name:String)->bool:
	
	var user_profile: = get_profile(profile_name)
	if not user_profile:
		
		return false

	
	if not user_profile.mod_list.has(mod_id):
		ModLoaderLog.error("Mod id \"%s\" not found in the \"mod_list\" of user profile \"%s\"." % [mod_id, profile_name], LOG_NAME)
		return false

	
	return true




static func _create_new_profile(profile_name:String, mod_list:Dictionary)->ModUserProfile:
	var new_profile: = ModUserProfile.new()

	
	if profile_name == "":
		ModLoaderLog.error("Please provide a name for the new profile", LOG_NAME)
		return null

	
	new_profile.name = profile_name

	
	if mod_list.keys().size() == 0:
		ModLoaderLog.info("No mod_ids inside \"mod_list\" for user profile \"%s\" " % profile_name, LOG_NAME)
		return new_profile

	
	new_profile.mod_list = _update_mod_list(mod_list)

	return new_profile



static func _load()->bool:
	
	var data: = _ModLoaderFile.get_json_as_dict(FILE_PATH_USER_PROFILES)

	
	if data.empty():
		ModLoaderLog.error("No profile file found at \"%s\"" % FILE_PATH_USER_PROFILES, LOG_NAME)
		return false

	
	for profile_name in data.profiles.keys():
		
		var profile_data:Dictionary = data.profiles[profile_name]

		
		var new_profile: = _create_new_profile(profile_name, profile_data.mod_list)
		ModLoaderStore.user_profiles[profile_name] = new_profile

	
	ModLoaderStore.current_user_profile = ModLoaderStore.user_profiles[data.current_profile]

	return true



static func _save()->bool:
	
	var save_dict: = {
		"current_profile":"", 
		"profiles":{}
	}

	
	save_dict.current_profile = ModLoaderStore.current_user_profile.name

	
	for profile_name in ModLoaderStore.user_profiles.keys():
		var profile:ModUserProfile = ModLoaderStore.user_profiles[profile_name]

		
		save_dict.profiles[profile.name] = {}
		
		save_dict.profiles[profile.name].mod_list = profile.mod_list

	
	return _ModLoaderFile.save_dictionary_to_json_file(save_dict, FILE_PATH_USER_PROFILES)
