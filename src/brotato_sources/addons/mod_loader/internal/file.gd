class_name _ModLoaderFile
extends Reference





const LOG_NAME: = "ModLoader:File"







static func get_json_as_dict(path:String)->Dictionary:
	var file: = File.new()

	if not file.file_exists(path):
		file.close()
		return {}

	var error: = file.open(path, File.READ)
	if not error == OK:
		ModLoaderLog.error("Error opening file. Code: %s" % error, LOG_NAME)

	var content: = file.get_as_text()
	return _get_json_string_as_dict(content)




static func _get_json_string_as_dict(string:String)->Dictionary:
	if string == "":
		return {}
	var parsed: = JSON.parse(string)
	if parsed.error:
		ModLoaderLog.error("Error parsing JSON", LOG_NAME)
		return {}
	if not parsed.result is Dictionary:
		ModLoaderLog.error("JSON is not a dictionary", LOG_NAME)
		return {}
	return parsed.result



static func load_zips_in_folder(folder_path:String)->Dictionary:
	var URL_MOD_STRUCTURE_DOCS: = "https://github.com/GodotModding/godot-mod-loader/wiki/Mod-Structure"
	var zip_data: = {}

	var mod_dir: = Directory.new()
	var mod_dir_open_error: = mod_dir.open(folder_path)
	if not mod_dir_open_error == OK:
		ModLoaderLog.info("Can't open mod folder %s (Error: %s)" % [folder_path, mod_dir_open_error], LOG_NAME)
		return {}
	var mod_dir_listdir_error: = mod_dir.list_dir_begin()
	if not mod_dir_listdir_error == OK:
		ModLoaderLog.error("Can't read mod folder %s (Error: %s)" % [folder_path, mod_dir_listdir_error], LOG_NAME)
		return {}

	
	while true:
		
		var mod_zip_file_name: = mod_dir.get_next()

		
		if mod_zip_file_name == "":
			
			break

		
		if not mod_zip_file_name.get_extension() == "zip" and not mod_zip_file_name.get_extension() == "pck":
			continue

		
		if mod_dir.current_is_dir():
			
			continue

		var mod_zip_path: = folder_path.plus_file(mod_zip_file_name)
		var mod_zip_global_path: = ProjectSettings.globalize_path(mod_zip_path)
		var is_mod_loaded_successfully: = ProjectSettings.load_resource_pack(mod_zip_global_path, false)

		
		
		var current_mod_dirs: = _ModLoaderPath.get_dir_paths_in_dir(_ModLoaderPath.get_unpacked_mods_dir_path())

		
		var current_mod_dirs_backup: = current_mod_dirs.duplicate()

		
		for previous_mod_dir in ModLoaderStore.previous_mod_dirs:
			current_mod_dirs.erase(previous_mod_dir)

		
		if current_mod_dirs.empty():
			ModLoaderLog.fatal(
				"The mod zip at path \"%s\" does not have the correct file structure. For more information, please visit \"%s\"."
				 % [mod_zip_global_path, URL_MOD_STRUCTURE_DOCS], 
				LOG_NAME
			)
			continue

		
		zip_data[current_mod_dirs[0].get_slice("/", 3)] = mod_zip_global_path

		
		ModLoaderStore.previous_mod_dirs = current_mod_dirs_backup

		
		
		
		
		
		
		
		if OS.has_feature("editor") and not ModLoaderStore.has_shown_editor_zips_warning:
			ModLoaderLog.warning(str(
				"Loading any resource packs (.zip/.pck) with `load_resource_pack` will WIPE the entire virtual res:// directory. ", 
				"If you have any unpacked mods in ", _ModLoaderPath.get_unpacked_mods_dir_path(), ", they will not be loaded. ", 
				"Please unpack your mod ZIPs instead, and add them to ", _ModLoaderPath.get_unpacked_mods_dir_path()), LOG_NAME)
			ModLoaderStore.has_shown_editor_zips_warning = true

		ModLoaderLog.debug("Found mod ZIP: %s" % mod_zip_global_path, LOG_NAME)

		
		if not is_mod_loaded_successfully:
			
			ModLoaderLog.error("%s failed to load." % mod_zip_file_name, LOG_NAME)
			continue

		
		ModLoaderLog.success("%s loaded." % mod_zip_file_name, LOG_NAME)

	mod_dir.list_dir_end()

	return zip_data






static func _save_string_to_file(save_string:String, filepath:String)->bool:
	
	var file_directory: = filepath.get_base_dir()
	var dir: = Directory.new()

	_code_note(str(
		"View error codes here:", 
		"https://docs.godotengine.org/en/stable/classes/class_%40globalscope.html#enum-globalscope-error"
	))

	if not dir.dir_exists(file_directory):
		var makedir_error: = dir.make_dir_recursive(file_directory)
		if not makedir_error == OK:
			ModLoaderLog.fatal("Encountered an error (%s) when attempting to create a directory, with the path: %s" % [makedir_error, file_directory], LOG_NAME)
			return false

	var file: = File.new()

	
	var fileopen_error: = file.open(filepath, File.WRITE)

	if not fileopen_error == OK:
		ModLoaderLog.fatal("Encountered an error (%s) when attempting to write to a file, with the path: %s" % [fileopen_error, filepath], LOG_NAME)
		return false

	file.store_string(save_string)
	file.close()

	return true



static func save_dictionary_to_json_file(data:Dictionary, filepath:String)->bool:
	var json_string: = JSON.print(data, "	")
	return _save_string_to_file(json_string, filepath)






static func remove_file(file_path:String)->bool:
	var dir: = Directory.new()

	if not dir.file_exists(file_path):
		ModLoaderLog.error("No file found at \"%s\"" % file_path, LOG_NAME)
		return false

	var error: = dir.remove(file_path)

	if error:
		ModLoaderLog.error(
			"Encountered an error (%s) when attempting to remove the file, with the path: %s"
			 % [error, file_path], 
			LOG_NAME
		)
		return false

	return true





static func file_exists(path:String)->bool:
	var file: = File.new()
	return file.file_exists(path)


static func dir_exists(path:String)->bool:
	var dir: = Directory.new()
	return dir.dir_exists(path)










static func _code_note(_msg:String):
	pass
