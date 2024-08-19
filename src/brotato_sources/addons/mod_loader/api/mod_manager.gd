

class_name ModLoaderModManager
extends Reference


const LOG_NAME: = "ModLoader:Manager"








static func uninstall_script_extension(extension_script_path:String)->void :
	
	
	_ModLoaderScriptExtension.remove_specific_extension_from_script(extension_script_path)














static func reload_mods()->void :

	
	
	ModLoader._reload_mods()













static func disable_mods()->void :

	
	
	ModLoader._disable_mods()
















static func disable_mod(mod_data:ModData)->void :

	
	
	ModLoader._disable_mod(mod_data)
