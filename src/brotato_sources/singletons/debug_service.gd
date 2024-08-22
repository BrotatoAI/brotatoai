extends Node

export (int, 1, 1000) var starting_wave: = 3
export (int) var starting_gold = 30
export (bool) var invulnerable = false
export (bool) var invisible = false
export (bool) var one_shot_enemies = false
export (bool) var instant_waves = false
export (bool) var no_fullscreen_on_launch = false
export (Array, Resource) var debug_weapons = []
export (Array, Resource) var debug_items = []
export (bool) var remove_starting_weapons = false
export (bool) var add_all_weapons = false
export (bool) var add_all_items = false
export (bool) var unlock_all_chars = false
export (bool) var unlock_all_challenges = false
export (bool) var unlock_all_difficulties = false
export (bool) var generate_full_unlocked_save_file = false
export (bool) var reinitialize_save = false
export (bool) var reinitialize_steam_data = false
export (bool) var disable_saving = false
export (bool) var randomize_equipment = false
export (bool) var randomize_waves = false
export (bool) var hide_wave_timer = false
export (bool) var nullify_enemy_speed = false
export (bool) var no_enemies = false
export (Array, Resource) var debug_enemies = []
export (String) var spawn_specific_elite = ""

var debug_items_added = false
var debug_weapons_added = false
var starting_weapons_removed = false


func reset_for_new_run()->void :
	debug_items_added = false
	debug_weapons_added = false
	starting_weapons_removed = false


func handle_player_spawn_debug_options()->void :
	if remove_starting_weapons and not starting_weapons_removed:
		RunData.weapons = []
		starting_weapons_removed = true

	if DebugService.randomize_equipment:
		var weapon = Utils.get_rand_element(ItemService.weapons)
		for _i in range(6):
			var _weapon = RunData.add_weapon(weapon)

		for i in 10:
			var item = Utils.get_rand_element(ItemService.items)
			RunData.add_item(item)

		for i in 30:
			var upg = Utils.get_rand_element(ItemService.upgrades)
			RunData.add_item(upg)

	if add_all_weapons and not debug_weapons_added:
		for weapon in ItemService.weapons:
			var _added_weapon = RunData.add_weapon(weapon)
		debug_weapons_added = true

	if add_all_items and not debug_items_added:
		for item in ItemService.items:
			RunData.add_item(item)
		debug_items_added = true

	if debug_weapons.size() > 0 and not debug_weapons_added:
		for weapon in debug_weapons:
			var _added_weapon = RunData.add_weapon(weapon)
		debug_weapons_added = true

	if debug_items.size() > 0 and not debug_items_added:
		for item in debug_items:
			RunData.add_item(item)

		debug_items_added = true


func log_run_info(upgrades:Array = [], consumables:Array = [])->void :

	if RunData.is_testing:return 

	var log_file = File.new()
	var error = log_file.open(ProgressData.LOG_PATH, File.WRITE)

	if error != OK:
		printerr("Could not open the file %s. Aborting save operation. Error code: %s" % 
		[ProgressData.LOG_PATH, error])
		return 

	log_file.store_line("Character: " + str(RunData.current_character.my_id))
	log_file.store_line("Wave: " + str(RunData.current_wave))
	log_file.store_line("Danger: " + str(RunData.get_current_difficulty()))
	log_file.store_line("Level ups: " + str(upgrades.size()))
	log_file.store_line("Consumables: " + str(consumables.size()))
	log_file.store_line("Gold: " + str(RunData.gold))
	log_file.store_line("Bonus Gold: " + str(RunData.bonus_gold))

	var items = ""

	for item in RunData.items:
		items += item.my_id + ", "

	log_file.store_line("Items: " + str(items))

	var weapons = ""

	for item in RunData.weapons:
		weapons += item.my_id + ", "

	log_file.store_line("Weapons: " + str(weapons))

	log_file.close()


func log_data(text:String)->void :

	if RunData.is_testing:return 

	var log_file = File.new()
	var _error = log_file.open(ProgressData.LOG_PATH, File.READ_WRITE)
	log_file.seek_end()
	log_file.store_string("\n" + text)
	log_file.close()
