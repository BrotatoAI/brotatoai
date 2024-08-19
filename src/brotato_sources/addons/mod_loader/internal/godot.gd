class_name _ModLoaderGodot
extends Object





const LOG_NAME: = "ModLoader:Godot"
const AUTOLOAD_CONFIG_HELP_MSG: = "To configure your autoloads, go to Project > Project Settings > Autoload."





static func check_autoload_order(autoload_name_before:String, autoload_name_after:String, trigger_error: = false)->bool:
	var autoload_name_before_index: = get_autoload_index(autoload_name_before)
	var autoload_name_after_index: = get_autoload_index(autoload_name_after)

	
	if not autoload_name_before_index < autoload_name_after_index:
		var error_msg: = (
			"Expected %s ( position: %s ) to be loaded before %s ( position: %s ). "
			 % [autoload_name_before, autoload_name_before_index, autoload_name_after, autoload_name_after_index]
		)
		var help_msg: = AUTOLOAD_CONFIG_HELP_MSG if OS.has_feature("editor") else ""

		if trigger_error:
			var final_message = error_msg + help_msg
			push_error(final_message)
			ModLoaderLog._write_to_log_file(final_message)
			ModLoaderLog._write_to_log_file(JSON.print(get_stack(), "  "))
			assert (false, final_message)

		return false

	return true





static func check_autoload_position(autoload_name:String, position_index:int, trigger_error: = false)->bool:
	var autoload_array: = get_autoload_array()
	var autoload_index: = autoload_array.find(autoload_name)
	var position_matches: = autoload_index == position_index

	if not position_matches and trigger_error:
		var error_msg: = (
			"Expected %s to be the autoload in position %s, but this is currently %s. "
			 % [autoload_name, str(position_index + 1), autoload_array[position_index]]
		)
		var help_msg: = AUTOLOAD_CONFIG_HELP_MSG if OS.has_feature("editor") else ""
		var final_message = error_msg + help_msg

		push_error(final_message)
		ModLoaderLog._write_to_log_file(final_message)
		ModLoaderLog._write_to_log_file(JSON.print(get_stack(), "  "))
		assert (false, final_message)

	return position_matches



static func get_autoload_array()->Array:
	var autoloads: = []

	
	for prop in ProjectSettings.get_property_list():
		var name:String = prop.name
		if name.begins_with("autoload/"):
			autoloads.append(name.trim_prefix("autoload/"))

	return autoloads



static func get_autoload_index(autoload_name:String)->int:
	var autoloads: = get_autoload_array()
	var autoload_index: = autoloads.find(autoload_name)

	return autoload_index
