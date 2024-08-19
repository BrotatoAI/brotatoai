class_name _ModLoaderSteam
extends Node

const LOG_NAME: = "ModLoader:ThirdParty:Steam"







static func load_steam_workshop_zips()->Dictionary:
	var zip_data: = {}
	var workshop_folder_path: = _get_path_to_workshop()

	ModLoaderLog.info("Checking workshop items, with path: \"%s\"" % workshop_folder_path, LOG_NAME)

	var workshop_dir: = Directory.new()
	var workshop_dir_open_error: = workshop_dir.open(workshop_folder_path)
	if not workshop_dir_open_error == OK:
		ModLoaderLog.error("Can't open workshop folder %s (Error: %s)" % [workshop_folder_path, workshop_dir_open_error], LOG_NAME)
		return {}
	var workshop_dir_listdir_error: = workshop_dir.list_dir_begin()
	if not workshop_dir_listdir_error == OK:
		ModLoaderLog.error("Can't read workshop folder %s (Error: %s)" % [workshop_folder_path, workshop_dir_listdir_error], LOG_NAME)
		return {}

	
	while true:
		
		var item_dir: = workshop_dir.get_next()
		var item_path: = workshop_dir.get_current_dir() + "/" + item_dir

		ModLoaderLog.info("Checking workshop item path: \"%s\"" % item_path, LOG_NAME)

		
		if item_dir == "":
			break

		
		if not workshop_dir.current_is_dir():
			continue

		
		zip_data.merge(_ModLoaderFile.load_zips_in_folder(ProjectSettings.globalize_path(item_path)))

	workshop_dir.list_dir_end()

	return zip_data











static func _get_path_to_workshop()->String:
	if ModLoaderStore.ml_options.override_path_to_workshop:
		return ModLoaderStore.ml_options.override_path_to_workshop

	var game_install_directory: = _ModLoaderPath.get_local_folder_dir()
	var path: = ""

	
	var path_array: = game_install_directory.split("/")
	path_array.resize(path_array.size() - 3)

	
	path = "/".join(path_array)

	
	path = path.plus_file("workshop/content/" + _get_steam_app_id())

	return path






static func _get_steam_app_id()->String:
	var game_install_directory: = _ModLoaderPath.get_local_folder_dir()
	var steam_app_id: = ""
	var file: = File.new()

	if file.open(game_install_directory.plus_file("steam_data.json"), File.READ) == OK:
		var file_content:Dictionary = parse_json(file.get_as_text())
		file.close()

		if not file_content.has("app_id"):
			ModLoaderLog.error("The steam_data file does not contain an app ID. Mod uploading will not work.", LOG_NAME)
			return ""

		steam_app_id = file_content.app_id
	else :
		ModLoaderLog.error("Can't open steam_data file, \"%s\". Please make sure the file exists and is valid." % game_install_directory.plus_file("steam_data.json"), LOG_NAME)

	return steam_app_id
