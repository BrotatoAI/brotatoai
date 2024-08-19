
class_name ModLoaderDeprecated
extends Node


const LOG_NAME: = "ModLoader:Deprecated"











static func deprecated_changed(old_method:String, new_method:String, since_version:String, show_removal_note:bool = true)->void :
	_deprecated_log(str(
		"DEPRECATED: ", 
		"The method \"%s\" has been deprecated since version %s. " % [old_method, since_version], 
		"Please use \"%s\" instead. " % new_method, 
		"The old method will be removed with the next major update, and will break your code if not changed. " if show_removal_note else ""
	))











static func deprecated_removed(old_method:String, since_version:String, show_removal_note:bool = true)->void :
	_deprecated_log(str(
		"DEPRECATED: ", 
		"The method \"%s\" has been deprecated since version %s, and is no longer available. " % [old_method, since_version], 
		"There is currently no replacement method. ", 
		"The method will be removed with the next major update, and will break your code if not changed. " if show_removal_note else ""
	))









static func deprecated_message(msg:String, since_version:String = "")->void :
	var since_text: = " (since version %s)" % since_version if since_version else ""
	_deprecated_log(str("DEPRECATED: ", msg, since_text))








static func _deprecated_log(msg:String)->void :
	if ModLoaderStore.ml_options.ignore_deprecated_errors or OS.has_feature("standalone"):
		ModLoaderLog.warning(msg, LOG_NAME)
	else :
		ModLoaderLog.fatal(msg, LOG_NAME)
