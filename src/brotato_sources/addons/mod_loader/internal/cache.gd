class_name _ModLoaderCache
extends Reference




const CACHE_FILE_PATH = "user://mod_loader_cache.json"
const LOG_NAME = "ModLoader:Cache"



static func init_cache(_ModLoaderStore)->void :
	if not _ModLoaderFile.file_exists(CACHE_FILE_PATH):
		_init_cache_file()
		return 

	_load_file(_ModLoaderStore)



static func add_data(key:String, data:Dictionary)->Dictionary:
	if ModLoaderStore.cache.has(key):
		ModLoaderLog.error("key: \"%s\" already exists in \"ModLoaderStore.cache\"" % key, LOG_NAME)
		return {}

	ModLoaderStore.cache[key] = data

	return ModLoaderStore.cache[key]



static func get_data(key:String)->Dictionary:
	if not ModLoaderStore.cache.has(key):
		ModLoaderLog.error("key: \"%s\" not found in \"ModLoaderStore.cache\"" % key, LOG_NAME)
		return {}

	return ModLoaderStore.cache[key]



static func get_cache()->Dictionary:
	return ModLoaderStore.cache


static func has_key(key:String)->bool:
	return ModLoaderStore.cache.has(key)



static func update_data(key:String, data:Dictionary)->Dictionary:
	
	if has_key(key):
		
		ModLoaderStore.cache[key].merge(data, true)
	else :
		ModLoaderLog.info("key: \"%s\" not found in \"ModLoaderStore.cache\" added as new data instead." % key, LOG_NAME, true)
		
		add_data(key, data)

	return ModLoaderStore.cache[key]



static func remove_data(key:String)->void :
	if not ModLoaderStore.cache.has(key):
		ModLoaderLog.error("key: \"%s\" not found in \"ModLoaderStore.cache\"" % key, LOG_NAME)
		return 

	ModLoaderStore.cache.erase(key)



static func save_to_file()->void :
	_ModLoaderFile.save_dictionary_to_json_file(ModLoaderStore.cache, CACHE_FILE_PATH)




static func _load_file(_ModLoaderStore = ModLoaderStore)->void :
	_ModLoaderStore.cache = _ModLoaderFile.get_json_as_dict(CACHE_FILE_PATH)



static func _init_cache_file()->void :
	_ModLoaderFile.save_dictionary_to_json_file({}, CACHE_FILE_PATH)
