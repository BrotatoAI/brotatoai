extends Node

const VERSION = "1.0.1.3"
const STEAM_APP_ID = 1942280

var smallest_text_font = preload("res://resources/fonts/actual/base/font_smallest_text.tres")

var languages = {
	"english":"en", 
	"french":"fr", 
	"schinese":"zh", 
	"tchinese":"zh_TW", 
	"japanese":"ja", 
	"koreana":"ko", 
	"russian":"ru", 
	"polish":"pl", 
	"spanish":"es", 
	"brazilian":"pt", 
	"german":"de", 
	"turkish":"tr", 
	"italian":"it"
}

const MAX_DIFFICULTY: = 5
const MAX_SAVES_WITHOUT_BACKUP: = 5
const SMALLEST_FONT_BASE_SIZE: = 20
const FPS_LIMIT: = 60

var SAVE_PATH:String
var SAVE_LATEST_PATH:String
var SAVE_STABLE_PATH:String
var LOG_PATH:String

var save_status = SaveStatus.SAVE_OK


var steam_is_owned:bool = false
var steam_is_online:bool = false
var steam_id:int = 0

var zones_unlocked: = []
var characters_unlocked: = []

var upgrades_unlocked: = []
var consumables_unlocked: = []

var weapons_unlocked: = []
var items_unlocked: = []
var challenges_completed: = []

var difficulties_unlocked: = []
var current_run_state:Dictionary
var inactive_mods: = []

var overall_max_selectable_difficulty = 0

var _saves_without_backup = 0

var settings:Dictionary = {}

var data:Dictionary = {
	"enemies_killed":0, 
	"materials_collected":0, 
	"trees_killed":0
}


func _ready()->void :
	init_settings()
	randomize()
	current_run_state = RunData.get_state(true)
	add_unlocked_by_default()
	initialize_Steam()
	init_save_paths()
	RunData.reset()

	if DebugService.generate_full_unlocked_save_file:
		unlock_all()
		save()
	else :
		load_game_file()


func init_settings()->void :
	settings = {"version":"", "endless_mode_toggled":false}
	settings.merge(init_general_options())
	settings.merge(init_gameplay_options())


func init_general_options()->Dictionary:
	return {
		"volume":{
			"master":0.5, 
			"sound":0.75, 
			"music":0.25
		}, 
		"fullscreen":true, 
		"screenshake":true, 
		"language":"en", 
		"background":0, 
		"visual_effects":true, 
		"damage_display":true, 
		"optimize_end_waves":false, 
		"limit_fps":false, 
		"mute_on_focus_lost":false, 
		"pause_on_focus_lost":true, 
	}


func init_gameplay_options()->Dictionary:
	return {
		"mouse_only":false, 
		"manual_aim":false, 
		"manual_aim_on_mouse_press":false, 
		"hp_bar_on_character":true, 
		"hp_bar_on_bosses":true, 
		"keep_lock":true, 
		"endless_score_storing":0, 
		"enemy_scaling":{
			"health":1.0, 
			"damage":1.0, 
			"speed":1.0
		}, 
		"explosion_opacity":1.0, 
		"projectile_opacity":1.0, 
		"font_size":1.0, 
		"character_highlighting":false, 
		"weapon_highlighting":false, 
		"projectile_highlighting":false, 
		"alt_gold_sounds":false, 
		"darken_screen":true, 
	}


func save_run_state(
		shop_items:Array = [], 
		reroll_price:int = 0, 
		last_reroll_price:int = 0, 
		initial_free_rerolls:int = 0, 
		free_rerolls:int = 0
	)->void :

	current_run_state = RunData.get_state(false, shop_items, reroll_price, last_reroll_price, initial_free_rerolls, free_rerolls)
	save()


func reset_run_state()->void :
	current_run_state = RunData.get_state(true)
	ProgressData.settings.version = ProgressData.VERSION
	save()


func init_save_paths()->void :

	var dir = Directory.new()
	var dir_path = "user://" + get_user_id()
	var directory_exists = dir.dir_exists(dir_path)

	if not directory_exists:
		var err = dir.make_dir(dir_path)

		if err != OK:
			printerr("Could not create the directory %s. Error code: %s" % 
			[dir_path, err])
			return 

	SAVE_PATH = "user://" + get_user_id() + "/save.json"
	SAVE_LATEST_PATH = "user://" + get_user_id() + "/save_latest.json"
	SAVE_STABLE_PATH = "user://" + get_user_id() + "/save_stable.json"
	LOG_PATH = "user://" + get_user_id() + "/log.txt"

	print("SAVE_PATH : " + SAVE_PATH)


func get_user_id()->String:
	if steam_id != 0:
		return str(steam_id)
	else :
		return "user"


func initialize_Steam()->void :
	var INIT:Dictionary = Steam.steamInit()
	print("Did Steam initialize?: " + str(INIT))

	steam_is_online = Steam.loggedOn()
	steam_id = Steam.getSteamID()
	steam_is_owned = Steam.isSubscribed()

	print("steam_is_online: " + str(steam_is_online))
	print("steam_id: " + str(steam_id))
	print("steam_is_owned: " + str(steam_is_owned))
	Steam.requestUserStats(steam_id)
	var _err = Steam.connect("user_stats_received", self, "on_steam_stats_ready")

	var steam_lang = Steam.getCurrentGameLanguage()

	if steam_lang != "None" and languages.has(steam_lang):
		settings.language = languages.get(steam_lang)


func on_steam_stats_ready(_game:int, _result:int, _user:int)->void :
	pass





func _process(_delta:float)->void :
	Steam.run_callbacks()


func add_unlocked_by_default()->void :
	for zone in ZoneService.zones:
		if zone.unlocked_by_default:
			zones_unlocked.push_back(zone.my_id)

	for item in ItemService.items:
		if item.unlocked_by_default:
			items_unlocked.push_back(item.my_id)

	for weapon in ItemService.weapons:
		if weapon.unlocked_by_default and not weapons_unlocked.has(weapon.weapon_id):
			weapons_unlocked.push_back(weapon.weapon_id)

	for upgrade in ItemService.upgrades:
		if upgrade.unlocked_by_default and not upgrades_unlocked.has(upgrade.upgrade_id):
			upgrades_unlocked.push_back(upgrade.upgrade_id)

	for character in ItemService.characters:
		if character.unlocked_by_default:
			characters_unlocked.push_back(character.my_id)

	for consumable in ItemService.consumables:
		if consumable.unlocked_by_default:
			consumables_unlocked.push_back(consumable.my_id)

	for character in ItemService.characters:
		var character_diff_info = CharacterDifficultyInfo.new(character.my_id)

		for zone in ZoneService.zones:
			if zone.unlocked_by_default:
				character_diff_info.zones_difficulty_info.push_back(ZoneDifficultyInfo.new(zone.my_id))

		difficulties_unlocked.push_back(character_diff_info)


func unlock_all()->void :
	for zone in ZoneService.zones:
		if zone.unlocked_by_default:
			zones_unlocked.push_back(zone.my_id)

	for item in ItemService.items:
			items_unlocked.push_back(item.my_id)

	for weapon in ItemService.weapons:
		if not weapons_unlocked.has(weapon.weapon_id):
			weapons_unlocked.push_back(weapon.weapon_id)

	for upgrade in ItemService.upgrades:
		if not upgrades_unlocked.has(upgrade.upgrade_id):
			upgrades_unlocked.push_back(upgrade.upgrade_id)

	for character in ItemService.characters:
		characters_unlocked.push_back(character.my_id)

	for consumable in ItemService.consumables:
		if consumable.unlocked_by_default and not consumables_unlocked.has(consumable.my_id):
			consumables_unlocked.push_back(consumable.my_id)

	difficulties_unlocked = []

	for character in ItemService.characters:
		var character_diff_info = CharacterDifficultyInfo.new(character.my_id)

		for zone in ZoneService.zones:
			if zone.unlocked_by_default:
				var info = ZoneDifficultyInfo.new(zone.my_id)
				info.max_selectable_difficulty = MAX_DIFFICULTY
				character_diff_info.zones_difficulty_info.push_back(info)

		difficulties_unlocked.push_back(character_diff_info)

	ChallengeService.complete_all_challenges()


func save(path:String = SAVE_PATH)->void :

	if DebugService.disable_saving:
		return 

	var save_file = File.new()

	var error = save_file.open(path, File.WRITE)

	if error != OK:
		printerr("Could not open the file %s. Aborting save operation. Error code: %s" % 
		[path, error])
		return 

	save_file.store_line(to_json(zones_unlocked))
	save_file.store_line(to_json(characters_unlocked))

	save_file.store_line(to_json(upgrades_unlocked))
	save_file.store_line(to_json(consumables_unlocked))

	save_file.store_line(to_json(weapons_unlocked))
	save_file.store_line(to_json(items_unlocked))
	save_file.store_line(to_json(challenges_completed))

	var difficulties_unlocked_serialized = []

	for difficulty_unlocked in difficulties_unlocked:
		difficulties_unlocked_serialized.push_back(difficulty_unlocked.serialize())

	save_file.store_line(to_json(difficulties_unlocked_serialized))

	save_file.store_line(to_json(settings))

	save_file.store_line(to_json(data))

	save_file.store_line(to_json(serialize_run_state()))

	save_file.store_line(to_json(inactive_mods))

	if path == SAVE_PATH:
		_saves_without_backup += 1

		if _saves_without_backup >= MAX_SAVES_WITHOUT_BACKUP:
			var dir = Directory.new()
			var error_copy = dir.copy(SAVE_PATH, SAVE_LATEST_PATH)

			if error_copy != OK:
				print("error copy backup")

			_saves_without_backup = 0

	save_file.close()

	if save_status == SaveStatus.CORRUPTED_ALL_SAVES_NO_STEAM:
		save_status = SaveStatus.SAVE_OK


func load_game_file(path:String = SAVE_PATH)->void :
	var save_file = File.new()

	if not save_file.file_exists(path) or DebugService.reinitialize_save:
		print("No save loaded, create new.")
		save()
		return 

	save_file.open(path, File.READ)

	var parsed_zones = parse_json(save_file.get_line())
	var parsed_characters = parse_json(save_file.get_line())
	var parsed_upgrades = parse_json(save_file.get_line())
	var parsed_consumables = parse_json(save_file.get_line())
	var parsed_weapons = parse_json(save_file.get_line())
	var parsed_items = parse_json(save_file.get_line())
	var parsed_challenges = parse_json(save_file.get_line())
	var parsed_difficulties = parse_json(save_file.get_line())

	if (parsed_zones == null or parsed_characters == null or parsed_upgrades == null
		 or parsed_consumables == null or parsed_weapons == null or parsed_items == null
		 or parsed_challenges == null or parsed_difficulties == null
		):
			print(path + " is corrupted")
			if path == SAVE_PATH:
				save_status = SaveStatus.CORRUPTED_SAVE
				load_game_file(SAVE_LATEST_PATH)
			elif path == SAVE_LATEST_PATH:
				save_status = SaveStatus.CORRUPTED_SAVE_LATEST
				load_game_file(SAVE_STABLE_PATH)
			elif path == SAVE_STABLE_PATH:
				recreate_save_file_from_achievements()

			return 

	append_without_duplicates(zones_unlocked, parsed_zones)
	append_without_duplicates(characters_unlocked, parsed_characters)

	append_without_duplicates(upgrades_unlocked, parsed_upgrades)
	append_without_duplicates(consumables_unlocked, parsed_consumables)

	append_without_duplicates(weapons_unlocked, parsed_weapons)
	append_without_duplicates(items_unlocked, parsed_items)
	append_without_duplicates(challenges_completed, parsed_challenges)

	for difficulty_json in parsed_difficulties:
		for difficulty_unlocked in difficulties_unlocked:
			if difficulty_unlocked.character_id == difficulty_json.character_id:
					difficulty_unlocked.deserialize_and_merge(difficulty_json)

	for difficulty in difficulties_unlocked:
		for zone_difficulty_info in difficulty.zones_difficulty_info:
			if zone_difficulty_info.max_selectable_difficulty < overall_max_selectable_difficulty:
				zone_difficulty_info.max_selectable_difficulty = overall_max_selectable_difficulty

	var saved_settings = parse_json(save_file.get_line())

	if saved_settings != null and saved_settings is Dictionary:
		settings = Utils.merge_dictionaries(settings, saved_settings)

	var saved_data = parse_json(save_file.get_line())

	if saved_data != null and saved_data is Dictionary:
		data = Utils.merge_dictionaries(data, saved_data)

	if save_file.get_position() < save_file.get_len():
		var saved_run_state = parse_json(save_file.get_line())

		if saved_run_state != null and saved_run_state is Dictionary:
			var deserialized_run_state = deserialize_run_state(saved_run_state)
			current_run_state = Utils.merge_dictionaries(current_run_state, deserialized_run_state)

	if save_file.get_position() < save_file.get_len():
		var saved_inactive_mods = parse_json(save_file.get_line())

		if saved_inactive_mods != null and saved_inactive_mods is Array:
			inactive_mods = saved_inactive_mods

	save_backups(path)

	save_file.close()


func recreate_save_file_from_achievements()->void :
	if steam_id == 0:
		save_status = SaveStatus.CORRUPTED_ALL_SAVES_NO_STEAM
		print("not on steam, don't save")
		return 

	save_status = SaveStatus.CORRUPTED_ALL_SAVES_STEAM

	var max_diff = 0
	var characters_won = []

	for chal in ChallengeService.challenges:
		var steam_achievement = Steam.getAchievement(chal.my_id)

		if steam_achievement.achieved:
			ChallengeService.complete_challenge(chal.my_id)

			if (chal.my_id == "chal_difficulty_0" or chal.my_id == "chal_difficulty_1" or chal.my_id == "chal_difficulty_2"
			 or chal.my_id == "chal_difficulty_3" or chal.my_id == "chal_difficulty_4" or chal.my_id == "chal_difficulty_5"):
				max_diff = max(max_diff, chal.value + 1)

			characters_won.push_back("character_" + chal.my_id.trim_prefix("chal_"))

	for char_diff in ProgressData.difficulties_unlocked:
		for zone_difficulty_info in char_diff.zones_difficulty_info:
			zone_difficulty_info.max_selectable_difficulty = clamp(max_diff, zone_difficulty_info.max_selectable_difficulty, ProgressData.MAX_DIFFICULTY)

	for character in ItemService.characters:
		var character_difficulty = ProgressData.get_character_difficulty_info(character.my_id, RunData.current_zone)

		if characters_won.has(character.my_id):
				character_difficulty.max_difficulty_beaten.set_info(
					0, 
					20, 
					RunData.current_run_accessibility_settings.health, 
					RunData.current_run_accessibility_settings.damage, 
					RunData.current_run_accessibility_settings.speed, 
					false
				)

	data.enemies_killed = Steam.getStatInt("enemies_killed")
	data.materials_collected = Steam.getStatInt("materials_collected")
	data.trees_killed = Steam.getStatInt("trees_killed")

	save()
	save_backups()


func save_backups(path:String = SAVE_PATH)->void :
	var error_backup = OK
	var error_backup_latest = OK
	var error_backup_stable = OK
	var dir = Directory.new()

	if path == SAVE_PATH:
		error_backup_latest = dir.copy(SAVE_PATH, SAVE_LATEST_PATH)
		error_backup_stable = dir.copy(SAVE_PATH, SAVE_STABLE_PATH)
	elif path == SAVE_LATEST_PATH:
		error_backup = dir.copy(SAVE_LATEST_PATH, SAVE_PATH)
		error_backup_stable = dir.copy(SAVE_LATEST_PATH, SAVE_STABLE_PATH)
	elif path == SAVE_STABLE_PATH:
		error_backup = dir.copy(SAVE_STABLE_PATH, SAVE_PATH)
		error_backup_latest = dir.copy(SAVE_STABLE_PATH, SAVE_LATEST_PATH)

	if error_backup != OK or error_backup_latest != OK or error_backup_stable != OK:
		print("error copy backups")


func serialize_run_state()->Dictionary:

	if not current_run_state.has_run_state:
		return current_run_state

	var serialized_run_state = current_run_state.duplicate()

	serialized_run_state.weapons = []
	serialized_run_state.items = []
	serialized_run_state.appearances_displayed = []
	serialized_run_state.effects = []
	serialized_run_state.challenges_completed_this_run = []
	serialized_run_state.active_set_effects = []

	



	serialized_run_state.locked_shop_items = []
	serialized_run_state.shop_items = []
	serialized_run_state.appearances_displayed = []

	for appearance_displayed in current_run_state.appearances_displayed:
		serialized_run_state.appearances_displayed.push_back(appearance_displayed.serialize())

	for weapon in current_run_state.weapons:
		serialized_run_state.weapons.push_back(weapon.my_id)

	for item in current_run_state.items:
		serialized_run_state.items.push_back(item.my_id)

	if current_run_state.current_background != null:
		serialized_run_state.current_background = current_run_state.current_background.name.to_lower()

	if current_run_state.current_character != null:
		serialized_run_state.current_character = current_run_state.current_character.my_id

	if current_run_state.starting_weapon != null:
		serialized_run_state.starting_weapon = current_run_state.starting_weapon.my_id

	for challenge in current_run_state.challenges_completed_this_run:
		serialized_run_state.challenges_completed_this_run.push_back(challenge.my_id)

	for locked_item in current_run_state.locked_shop_items:
		serialized_run_state.locked_shop_items.push_back([locked_item[0].my_id, locked_item[1]])

	for active_set_effect in current_run_state.active_set_effects:
		var serialized_effect = active_set_effect[1].serialize()
		serialized_run_state.active_set_effects.push_back([active_set_effect[0], serialized_effect])

	for shop_item in current_run_state.shop_items:
		serialized_run_state.shop_items.push_back([shop_item[0].my_id, shop_item[1]])

	var serialized_effects = {}

	for key in current_run_state.effects:
		if RunData.effect_keys_full_serialization.has(key):
			if RunData.effects[key] is Array:
				serialized_effects[key] = []
				for element in current_run_state.effects[key]:
					serialized_effects[key].push_back(element.serialize())
			elif current_run_state.effects[key] != null:
				serialized_effects[key] = current_run_state.effects[key].serialize()

		elif RunData.effect_keys_with_weapon_stats.has(key):
			if RunData.effects[key] is Array:
				serialized_effects[key] = []
				for element in current_run_state.effects[key]:
					
					if element is Array:
						var array = []
						for effect in element:
							if effect is WeaponStats:
								array.push_back(effect.serialize())
							else :
								array.push_back(effect)
						serialized_effects[key].push_back(array)
					else :
						if element is WeaponStats:
							serialized_effects[key].push_back(element.serialize())
						else :
							serialized_effects[key].push_back(element)

		else :
			serialized_effects[key] = current_run_state.effects[key]

	serialized_run_state.effects = serialized_effects

	return serialized_run_state


func deserialize_run_state(state:Dictionary)->Dictionary:

	if not state.has_run_state:
		return state

	var deserialized_run_state = state.duplicate()

	deserialized_run_state.weapons = []
	deserialized_run_state.items = []
	deserialized_run_state.appearances_displayed = []
	deserialized_run_state.effects = []
	deserialized_run_state.challenges_completed_this_run = []
	deserialized_run_state.active_set_effects = []




	deserialized_run_state.locked_shop_items = []
	deserialized_run_state.shop_items = []
	deserialized_run_state.appearances_displayed = []
	deserialized_run_state.active_sets = {}

	for key in state.active_sets:
		deserialized_run_state.active_sets[int(key)] = state.active_sets[key]

	for appearance_displayed in state.appearances_displayed:
		var deserialized = ItemAppearanceData.new()
		deserialized.deserialize_and_merge(appearance_displayed)
		deserialized_run_state.appearances_displayed.push_back(deserialized)

	for weapon_id in state.weapons:
		var weapon_data = ItemService.get_element(ItemService.weapons, weapon_id)
		deserialized_run_state.weapons.push_back(weapon_data)

	for item_id in state.items:
		var item_data = ItemService.get_element(ItemService.items, item_id)
		var character_data = ItemService.get_element(ItemService.characters, item_id)

		if item_data != null:
			deserialized_run_state.items.push_back(item_data)
		elif character_data != null:
			deserialized_run_state.items.push_back(character_data)

	for bg in RunData.backgrounds:
		if bg.name.to_lower() == state.current_background:
			deserialized_run_state.current_background = bg
			break

	deserialized_run_state.current_character = ItemService.get_element(ItemService.characters, state.current_character)

	if state.starting_weapon != null:
		var weapon_data = ItemService.get_element(ItemService.weapons, state.starting_weapon)
		deserialized_run_state.starting_weapon = weapon_data

	for challenge_id in state.challenges_completed_this_run:
		for chal_data in ChallengeService.challenges:
			if chal_data.my_id == challenge_id:
				deserialized_run_state.challenges_completed_this_run.push_back(chal_data)
				break

	for locked_item in state.locked_shop_items:
		var item_data = ItemService.get_element(ItemService.items, locked_item[0])
		var weapon_data = ItemService.get_element(ItemService.weapons, locked_item[0])

		if item_data != null:
			deserialized_run_state.locked_shop_items.push_back([item_data, locked_item[1]])

		if weapon_data != null:
			deserialized_run_state.locked_shop_items.push_back([weapon_data, locked_item[1]])

	for shop_item in state.shop_items:
		var item_data = ItemService.get_element(ItemService.items, shop_item[0])
		var weapon_data = ItemService.get_element(ItemService.weapons, shop_item[0])

		if item_data != null:
			deserialized_run_state.shop_items.push_back([item_data, shop_item[1]])

		if weapon_data != null:
			deserialized_run_state.shop_items.push_back([weapon_data, shop_item[1]])

	for active_set_effect in state.active_set_effects:
		for effect in ItemService.effects:
			if effect.get_id() == active_set_effect[1].effect_id:
				var deserialized_effect = effect.new()
				deserialized_effect.deserialize_and_merge(active_set_effect[1])
				deserialized_run_state.active_set_effects.push_back([active_set_effect[0], deserialized_effect])
				break

	
	
	var weapon_effect_hashes = {}
	cache_effect_hashes(deserialized_run_state.weapons, weapon_effect_hashes)

	var deserialized_effects = {}

	for key in state.effects:
		if RunData.effect_keys_full_serialization.has(key):
			if state.effects[key] is Array:
				deserialized_effects[key] = []
				for serialized_effect in state.effects[key]:
					var instance = get_or_deserialize_effect(serialized_effect, weapon_effect_hashes)
					if instance:deserialized_effects[key].push_back(instance)
			elif state.effects[key] != null:
				if key == "burn_chance":
					var instance = BurningData.new()
					instance.deserialize_and_merge(state.effects[key])
					deserialized_effects[key] = instance
				else :
					var instance = get_or_deserialize_effect(state.effects[key], weapon_effect_hashes)
					if instance:deserialized_effects[key] = instance
		elif RunData.effect_keys_with_weapon_stats.has(key):
			if state.effects[key] is Array:
				deserialized_effects[key] = []
				for serialized_element in state.effects[key]:
					if serialized_element is Array:
						var array = []
						for serialized_effect in serialized_element:
							if serialized_effect is Dictionary:
								var instance = RangedWeaponStats.new()
								instance.deserialize_and_merge(serialized_effect)
								array.push_back(instance)
							else :
								array.push_back(serialized_effect)
						deserialized_effects[key].push_back(array)
					else :
						if serialized_element is Dictionary:
							var instance = RangedWeaponStats.new()
							instance.deserialize_and_merge(serialized_element)
							deserialized_effects[key].push_back(instance)
						else :
							deserialized_effects[key].push_back(serialized_element)

		else :
			deserialized_effects[key] = state.effects[key]

	deserialized_run_state.effects = deserialized_effects

	return deserialized_run_state


func get_or_deserialize_effect(serialized_effect:Dictionary, weapon_effect_hashes:Dictionary):
	var effect_hash = unsorted_dictionary_hash(serialized_effect)
	var weapon_effects = weapon_effect_hashes.get(effect_hash)
	if weapon_effects and weapon_effects.size() > 0 and weapon_effects.back().get_id() == serialized_effect.effect_id:
		
		
		
		
		var effect = weapon_effects.pop_back()
		if weapon_effects.size() == 0:
			var _removed = weapon_effect_hashes.erase(effect_hash)
		return effect
	
	for effect in ItemService.effects:
		if effect.get_id() == serialized_effect.effect_id:
			var instance = effect.new()
			instance.deserialize_and_merge(serialized_effect)
			return instance
	return null


func cache_effect_hashes(elements:Array, weapon_effect_hashes:Dictionary)->void :
		for element in elements:
			for effect in element.effects:
				var effect_hash = unsorted_dictionary_hash(effect.serialize())
				var existing_effects = weapon_effect_hashes.get(effect_hash)
				if existing_effects == null:
					weapon_effect_hashes[effect_hash] = [effect]
				else :
					existing_effects.push_back(effect)


func unsorted_dictionary_hash(dictionary:Dictionary)->int:
	
	
	
	var sort_keys = true
	return JSON.print(dictionary, "", sort_keys).hash()


func convert_to_int(array:Array)->Array:
	for i in array.size():
		array[i] = int(array[i])

	return array


func append_without_duplicates(array:Array, array_to_append:Array)->void :
	for element in array_to_append:
		if not array.has(element):
			array.push_back(element)


func apply_settings()->void :
	if settings.has("volume"):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(settings.volume.master ))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), linear2db(settings.volume.sound))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(settings.volume.music))

	TranslationServer.set_locale(settings.language)

	if not DebugService.no_fullscreen_on_launch:
		OS.window_fullscreen = settings.fullscreen

	smallest_text_font.size = SMALLEST_FONT_BASE_SIZE * settings.font_size
	RunData.reset_background()
	set_fps_limit(settings.limit_fps)


func set_font_size(value:float)->void :
	smallest_text_font.size = SMALLEST_FONT_BASE_SIZE * value
	settings.font_size = value


func set_fps_limit(enabled:bool)->void :
	Engine.target_fps = FPS_LIMIT if enabled else 0
	settings.limit_fps = enabled


func get_character_difficulty_info(character_id:String, zone_id:int)->ZoneDifficultyInfo:

	for character_difficulty_info in difficulties_unlocked:
		if character_difficulty_info.character_id != character_id:continue

		for zone_difficulty_info in character_difficulty_info.zones_difficulty_info:
			if zone_difficulty_info.zone_id != zone_id:continue

			return zone_difficulty_info

	return null


func add_data(key:String)->void :
	ProgressData.data[key] += 1
	var _stat = Steam.setStatInt(key, ProgressData.data[key])
	var _stored = Steam.storeStats()


func is_manual_aim()->bool:
	var trying_to_aim = Input.is_mouse_button_pressed(BUTTON_LEFT) or (InputService.using_gamepad and Input.get_vector("rjoy_left", "rjoy_right", "rjoy_up", "rjoy_down") != Vector2.ZERO)
	return settings.manual_aim or (settings.manual_aim_on_mouse_press and trying_to_aim)
