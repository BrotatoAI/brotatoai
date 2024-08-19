
class_name ModLoaderMod
extends Object


const LOG_NAME: = "ModLoader:Mod"


















static func install_script_extension(child_script_path:String)->void :

	var mod_id:String = ModLoaderUtils.get_string_in_between(child_script_path, "res://mods-unpacked/", "/")
	var mod_data:ModData = get_mod_data(mod_id)
	if not ModLoaderStore.saved_extension_paths.has(mod_data.manifest.get_mod_id()):
		ModLoaderStore.saved_extension_paths[mod_data.manifest.get_mod_id()] = []
	ModLoaderStore.saved_extension_paths[mod_data.manifest.get_mod_id()].append(child_script_path)

	
	
	if ModLoaderStore.is_initializing:
		ModLoaderStore.script_extensions.push_back(child_script_path)

	
	else :
		_ModLoaderScriptExtension.apply_extension(child_script_path)













static func register_global_classes_from_array(new_global_classes:Array)->void :
	ModLoaderUtils.register_global_classes_from_array(new_global_classes)
	var _savecustom_error:int = ProjectSettings.save_custom(_ModLoaderPath.get_override_path())











static func add_translation(resource_path:String)->void :
	if not _ModLoaderFile.file_exists(resource_path):
		ModLoaderLog.fatal("Tried to load a translation resource from a file that doesn't exist. The invalid path was: %s" % [resource_path], LOG_NAME)
		return 

	var translation_object:Translation = load(resource_path)
	TranslationServer.add_translation(translation_object)
	ModLoaderLog.info("Added Translation from Resource -> %s" % resource_path, LOG_NAME)













static func append_node_in_scene(modified_scene:Node, node_name:String = "", node_parent = null, instance_path:String = "", is_visible:bool = true)->void :
	var new_node:Node
	if not instance_path == "":
		new_node = load(instance_path).instance()
	else :
		new_node = Node.instance()
	if not node_name == "":
		new_node.name = node_name
	if is_visible == false:
		new_node.visible = false
	if not node_parent == null:
		var tmp_node:Node = modified_scene.get_node(node_parent)
		tmp_node.add_child(new_node)
		new_node.set_owner(modified_scene)
	else :
		modified_scene.add_child(new_node)
		new_node.set_owner(modified_scene)









static func save_scene(modified_scene:Node, scene_path:String)->void :
	var packed_scene: = PackedScene.new()
	var _pack_error: = packed_scene.pack(modified_scene)
	ModLoaderLog.debug("packing scene -> %s" % packed_scene, LOG_NAME)
	packed_scene.take_over_path(scene_path)
	ModLoaderLog.debug("save_scene - taking over path - new path -> %s" % packed_scene.resource_path, LOG_NAME)
	ModLoaderStore.saved_objects.append(packed_scene)









static func get_mod_data(mod_id:String)->ModData:
	if not ModLoaderStore.mod_data.has(mod_id):
		ModLoaderLog.error("%s is an invalid mod_id" % mod_id, LOG_NAME)
		return null

	return ModLoaderStore.mod_data[mod_id]






static func get_mod_data_all()->Dictionary:
	return ModLoaderStore.mod_data






static func get_unpacked_dir()->String:
	return _ModLoaderPath.get_unpacked_mods_dir_path()









static func is_mod_loaded(mod_id:String)->bool:
	if ModLoaderStore.is_initializing:
		ModLoaderLog.warning(
			"The ModLoader is not fully initialized. " + 
			"Calling \"is_mod_loaded()\" in \"_init()\" may result in an unexpected return value as mods are still loading.", 
			LOG_NAME
		)

	
	if not ModLoaderStore.mod_data.has(mod_id) or not ModLoaderStore.mod_data[mod_id].is_loadable:
		return false

	return true
