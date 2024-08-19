class_name _ModLoaderDependency
extends Reference





const LOG_NAME: = "ModLoader:Dependency"















static func check_dependencies(mod:ModData, is_required: = true, dependency_chain: = [])->bool:
	var dependency_type: = "required" if is_required else "optional"
	
	var dependencies: = mod.manifest.dependencies if is_required else mod.manifest.optional_dependencies
	
	var mod_id: = mod.dir_name

	ModLoaderLog.debug("Checking dependencies - mod_id: %s %s dependencies: %s" % [mod_id, dependency_type, dependencies], LOG_NAME)

	
	if mod_id in dependency_chain:
		ModLoaderLog.debug("%s dependency check - circular dependency detected for mod with ID %s." % [dependency_type.capitalize(), mod_id], LOG_NAME)
		return true

	
	dependency_chain.append(mod_id)

	
	for dependency_id in dependencies:
		
		if not ModLoaderStore.mod_data.has(dependency_id) or not ModLoaderStore.mod_data[dependency_id].is_loadable:
			
			if not is_required:
				ModLoaderLog.info("Missing optional dependency - mod: -> %s dependency -> %s" % [mod_id, dependency_id], LOG_NAME)
				continue
			_handle_missing_dependency(mod_id, dependency_id)
			
			mod.is_loadable = false
		else :
			var dependency:ModData = ModLoaderStore.mod_data[dependency_id]

			
			dependency.importance += 1
			ModLoaderLog.debug("%s dependency -> %s importance -> %s" % [dependency_type.capitalize(), dependency_id, dependency.importance], LOG_NAME)

			
			if dependency.manifest.dependencies.size() > 0:
				if check_dependencies(dependency, is_required, dependency_chain):
					return true

	
	return false





static func check_load_before(mod:ModData)->void :
	
	if mod.manifest.load_before.size() == 0:
		return 

	ModLoaderLog.debug("Load before - In mod %s detected." % mod.dir_name, LOG_NAME)

	
	for load_before_id in mod.manifest.load_before:
		
		if not ModLoaderStore.mod_data.has(load_before_id):
			ModLoaderLog.debug("Load before - Skipping %s because it's missing" % load_before_id, LOG_NAME)
			continue

		var load_before_mod_dependencies: = ModLoaderStore.mod_data[load_before_id].manifest.dependencies as PoolStringArray

		
		if mod.dir_name in load_before_mod_dependencies:
			ModLoaderLog.debug("Load before - Skipping because it's already a dependency for %s" % load_before_id, LOG_NAME)
			continue

		
		load_before_mod_dependencies.append(mod.dir_name)
		ModLoaderStore.mod_data[load_before_id].manifest.dependencies = load_before_mod_dependencies

		ModLoaderLog.debug("Load before - Added %s as dependency for %s" % [mod.dir_name, load_before_id], LOG_NAME)



static func get_load_order(mod_data_array:Array)->Array:
	
	for mod in mod_data_array:
		mod = mod as ModData
		if mod.is_loadable:
			ModLoaderStore.mod_load_order.append(mod)

	
	ModLoaderStore.mod_load_order.sort_custom(CompareImportance, "_compare_importance")
	return ModLoaderStore.mod_load_order




static func _handle_missing_dependency(mod_id:String, dependency_id:String)->void :
	ModLoaderLog.error("Missing dependency - mod: -> %s dependency -> %s" % [mod_id, dependency_id], LOG_NAME)
	
	if not ModLoaderStore.mod_missing_dependencies.has(mod_id):
		
		ModLoaderStore.mod_missing_dependencies[mod_id] = []

	ModLoaderStore.mod_missing_dependencies[mod_id].append(dependency_id)



class CompareImportance:
	
	static func _compare_importance(a:ModData, b:ModData)->bool:
		if a.importance > b.importance:
			return true
		else :
			return false
