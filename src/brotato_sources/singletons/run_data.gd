extends Node

signal levelled_up
signal gold_changed(new_value)
signal bonus_gold_changed(new_value)
signal xp_added(current_xp, max_xp)
signal stat_added(stat_name, value, db_mod)
signal stat_removed(stat_name, value, db_mod)
signal stats_updated

signal lifesteal_effect(value)
signal healing_effect(value, tracking_text)

const ENDLESS_HARVESTING_DECREASE: = 20

export (Array, Resource) var backgrounds = []
export (Array, Color) var background_colors = []

var effect_keys_full_serialization = [
	"burn_chance", "structures", "explode_on_hit", "explode_on_death", "explode_on_consumable", "convert_stats_end_of_wave", "convert_stats_half_wave"
]

var effect_keys_with_weapon_stats = [
	"projectiles_on_death", "alien_eyes"
]

var remove_speed_effect_cache: = {}
var items_nb_cache: = {}
var max_consumable_stats_gained_this_wave: = []
var tracked_item_effects: = {}
var _are_stats_dirty = false

var current_run_accessibility_settings:Dictionary

var current_living_enemies: = 0
var current_living_trees: = 0
var resumed_from_state: = false
var nb_of_waves: = 20

var elites_spawn: = []
var current_zone: = 0
var current_level: = 0
var current_xp: = 0.0
var max_weapons:int
var current_wave:int
var current_difficulty:int
var gold:int
var bonus_gold:int
var weapons:Array
var items:Array
var appearances_displayed:Array
var run_won:bool
var effects:Dictionary
var challenges_completed_this_run: = []
var reload_music = true
var current_character:CharacterData
var starting_weapon:WeaponData
var active_set_effects: = []
var active_sets = {}
var unique_effects: = []
var additional_weapon_effects: = []
var tier_iv_weapon_effects: = []
var tier_i_weapon_effects: = []
var locked_shop_items = []
var current_background = null
var shop_effects_checked = false

var instant_waves = true
var invulnerable = false

var difficulty_unlocked = - 1
var max_endless_wave_record_beaten = - 1
var is_endless_run = false

var chal_hoarder_value = 0
var chal_hoarder_completed = false

var chal_recycling_current = 0
var chal_recycling_value = 0
var chal_recycling_completed = false

var chal_hungry_value = 0
var chal_hungry_completed = false
var consumables_picked_up_this_run = 0

var is_testing = true


func _ready()->void :
	chal_hungry_value = ChallengeService.get_chal("chal_hungry").value
	chal_hoarder_value = ChallengeService.get_chal("chal_hoarder").value
	chal_recycling_value = ChallengeService.get_chal("chal_recycling").value

	# if DebugService.unlock_all_challenges:
	for chal in ChallengeService.challenges:
		ChallengeService.complete_challenge(chal.my_id)

	if DebugService.reinitialize_steam_data:
		print("steam reset data")
		var _reset = Steam.resetAllStats(true)


func reset(restart:bool = false)->void :

	current_run_accessibility_settings = ProgressData.settings.enemy_scaling.duplicate()

	reset_background()

	active_sets = {}
	active_set_effects = []
	unique_effects = []
	additional_weapon_effects = []
	tier_iv_weapon_effects = []
	tier_i_weapon_effects = []
	weapons = []
	items = []

	effects = init_effects()
	tracked_item_effects = init_tracked_effects()
	init_appearances_displayed()

	if not restart:
		starting_weapon = null
		current_character = null
		is_endless_run = false
	else :
		add_character(current_character)

		if starting_weapon:
			var _weapon = add_weapon(starting_weapon, true)

		add_starting_items_and_weapons()

		var difficulty = ItemService.get_element(ItemService.difficulties, "", get_current_difficulty())

		for effect in difficulty.effects:
			effect.apply()

	DebugService.reset_for_new_run()

	elites_spawn = []
	init_elites_spawn()

	shop_effects_checked = false
	current_zone = 0
	current_level = 0
	current_xp = 0
	max_weapons = 6
	bonus_gold = 0
	challenges_completed_this_run = []
	run_won = false
	locked_shop_items = []
	difficulty_unlocked = - 1
	max_endless_wave_record_beaten = - 1
	gold = DebugService.starting_gold
	current_wave = DebugService.starting_wave
	current_difficulty = - 1
	is_testing = false

	if DebugService.randomize_equipment:
		gold = Utils.get_random_int(10, 500)
		current_level = Utils.get_random_int(10, 26)

	if DebugService.randomize_waves:
		current_wave = Utils.get_random_int(9, 20)

	chal_hoarder_completed = false

	chal_recycling_current = 0
	chal_recycling_completed = false

	chal_hungry_completed = false
	consumables_picked_up_this_run = 0

	
	instant_waves = DebugService.instant_waves
	invulnerable = DebugService.invulnerable

	TempStats.reset()
	LinkedStats.reset()
	ItemService.init_unlocked_pool()

	InputService.hide_mouse = true





func reset_cache()->void :
	remove_speed_effect_cache = init_remove_speed_data()
	items_nb_cache = {}
	var copied_array = []

	for stat in effects["consumable_stats_while_max"]:
		copied_array.push_back(stat.duplicate())

	max_consumable_stats_gained_this_wave = copied_array

	for stat in max_consumable_stats_gained_this_wave:
		if stat.size() > 2:
			stat[2] = 0


func init_elites_spawn(base_wave:int = 10, horde_chance:float = 0.4)->void :
	elites_spawn = []
	var diff = get_current_difficulty()
	var nb_elites = 0
	var possible_elites = ItemService.elites.duplicate()

	if current_character != null and current_character.my_id == "character_jack":
		horde_chance = 0.0

	if diff < 2:
		return 
	elif diff < 4:
		nb_elites = 1
	else :
		nb_elites = 3

	var wave = Utils.get_random_int(base_wave + 1, base_wave + 2)

	for i in nb_elites:

		var type = EliteType.HORDE if Utils.get_chance_success(horde_chance) else EliteType.ELITE

		if DebugService.spawn_specific_elite != "":
			type = EliteType.ELITE
			wave = DebugService.starting_wave

		if i == 1:
			wave = Utils.get_random_int(base_wave + 4, base_wave + 5)
		elif i == 2:
			wave = Utils.get_random_int(base_wave + 7, base_wave + 8)
			type = EliteType.ELITE

		var elite_id = Utils.get_rand_element(possible_elites).my_id if type == EliteType.ELITE else ""

		for elite in possible_elites:
			if elite.my_id == elite_id:
				possible_elites.erase(elite)
				break

		if DebugService.spawn_specific_elite != "":
			elite_id = DebugService.spawn_specific_elite

		elites_spawn.push_back([wave, type, elite_id])


func is_elite_wave(type:int = - 1)->bool:
	var is_elite = false

	for elite_spawn in elites_spawn:
		if elite_spawn[0] == current_wave and (type == - 1 or elite_spawn[1] == type):
			is_elite = true
			break

	return is_elite


func is_in_last_waves()->bool:
	return current_wave >= nb_of_waves - 1


func init_appearances_displayed()->void :
	appearances_displayed = []


func remove_bonus_gold(value:int)->void :
	set_bonus_gold(bonus_gold - value)


func add_bonus_gold(value:int)->void :
	set_bonus_gold(bonus_gold + value)


func set_bonus_gold(value:int)->void :
	bonus_gold = max(0, value) as int
	emit_signal("bonus_gold_changed", bonus_gold)


func add_xp(value:int)->void :
	current_xp += value * (1 + (Utils.get_stat("xp_gain") / 100.0))
	var next_level_xp = get_next_level_xp_needed()
	emit_signal("xp_added", current_xp, next_level_xp)

	while current_xp >= next_level_xp:
		level_up()
		emit_signal("xp_added", current_xp, next_level_xp)
		next_level_xp = get_next_level_xp_needed()


func get_next_level_xp_needed()->int:
	return get_xp_needed(current_level + 1)


func get_xp_needed(level:int)->int:
	return (pow(3 + level, 2)) as int


func get_endless_factor(p_wave:int = - 1)->float:

	var wave = p_wave if p_wave != - 1 else current_wave
	var endless_wave = max(0, wave - 20)
	var endless_mult = 2.0 + max(0.0, (wave - 35) * 0.2)
	var endless_factor = max(0.0, ((endless_wave * (endless_wave + 1)) / 2) / 100.0) * endless_mult

	return endless_factor


func get_additional_elites_endless()->Array:
	var new_elites = []
	if RunData.current_wave > RunData.nb_of_waves:
		var nb_of_additional_elites = ceil((RunData.current_wave - 20.0) / 10.0)
		for i in nb_of_additional_elites:
			new_elites.push_back(Utils.get_rand_element(ItemService.elites).my_id)

	return new_elites


func level_up()->void :
	current_xp = max(0, current_xp - get_next_level_xp_needed())
	current_level += 1
	emit_signal("levelled_up")

	if current_level >= 20:
		ChallengeService.complete_challenge("chal_student")


func add_gold(value:int)->void :
	gold += value
	emit_signal("gold_changed", gold)

	if LinkedStats.update_on_gold_chance:
		LinkedStats.reset()

	if gold >= chal_hoarder_value and not chal_hoarder_completed:
		chal_hoarder_completed = true
		ChallengeService.complete_challenge("chal_hoarder")


func remove_gold(value:int)->void :
	gold = max(0, gold - value) as int
	emit_signal("gold_changed", gold)

	if LinkedStats.update_on_gold_chance:
		LinkedStats.reset()


func add_character(character:CharacterData)->void :
	current_character = character
	add_item(character)


func add_item(item:ItemData)->void :
	items.push_back(item)
	apply_item_effects(item)
	add_item_displayed(item)
	update_item_related_effects()
	LinkedStats.reset()
	check_bait_chal(item.my_id)
	check_scavenger_chal()


func check_scavenger_chal()->void :
	var parsed_items = {}
	var nb_unique_commons = 0

	for item in items:
		if item.tier <= Tier.COMMON and not parsed_items.has(item.my_id):
			parsed_items[item.my_id] = true
			nb_unique_commons += 1

	if nb_unique_commons >= ChallengeService.get_chal("chal_scavenger").value:
		ChallengeService.complete_challenge("chal_scavenger")


func check_bait_chal(item_id:String)->void :
	if item_id == "item_bait":
		var nb_baits = 0

		for player_item in items:
			if player_item.my_id == "item_bait":
				nb_baits += 1

		if nb_baits >= ChallengeService.get_chal("chal_baited").value:
			ChallengeService.complete_challenge("chal_baited")


func remove_item(item:ItemData)->void :
	items.erase(item)
	unapply_item_effects(item)
	remove_item_displayed(item)
	update_item_related_effects()
	LinkedStats.reset()


func add_weapon(weapon:WeaponData, is_starting:bool = false)->WeaponData:

	var new_weapon = weapon.duplicate()

	if is_starting:
		starting_weapon = weapon

	weapons.push_back(new_weapon)
	apply_item_effects(new_weapon)
	update_sets()
	update_item_related_effects()
	LinkedStats.reset()

	check_bourgeoisie_chal()

	return new_weapon


func check_bourgeoisie_chal()->void :
	var legendaries = 0

	for weapon in weapons:
		if weapon.tier >= Tier.LEGENDARY:
			legendaries += 1

	if legendaries >= ChallengeService.get_chal("chal_bourgeoisie").value:
		ChallengeService.complete_challenge("chal_bourgeoisie")


func remove_weapon(weapon:WeaponData)->int:
	var removed_weapon_tracked_value = 0
	for current_weapon in weapons:
		if current_weapon.my_id == weapon.my_id:
			removed_weapon_tracked_value = current_weapon.tracked_value
			weapons.erase(current_weapon)
			break
	unapply_item_effects(weapon)
	update_sets()
	update_item_related_effects()
	LinkedStats.reset()
	ChallengeService.check_stat_challenges()
	return removed_weapon_tracked_value


func remove_all_weapons()->void :
	for weapon in weapons:
		unapply_item_effects(weapon)

	weapons = []
	update_sets()
	update_item_related_effects()
	LinkedStats.reset()
	ChallengeService.check_stat_challenges()


func add_weapon_dmg_dealt(pos:int, dmg_dealt:int)->void :
	if weapons.size() > pos:
		weapons[pos].dmg_dealt_last_wave += dmg_dealt


func reset_weapons_dmg_dealt()->void :
	for weapon in weapons:
		weapon.dmg_dealt_last_wave = 0


func update_sets()->void :

	for effect in active_set_effects:
		effect[1].unapply()

	active_set_effects = []
	active_sets = {}

	for weapon in weapons:
		for set in weapon.sets:
			if active_sets.has(set.my_id):
				active_sets[set.my_id] += 1
			else :
				active_sets[set.my_id] = 1

	for key in active_sets:
		if active_sets[key] >= 2:
			var set = ItemService.get_set(key)
			var set_effects = set.set_bonuses[min(active_sets[key] - 2, set.set_bonuses.size() - 1)]

			for effect in set_effects:
				effect.apply()
				active_set_effects.push_back([key, effect])


func get_unique_weapon_ids()->Array:
	var unique_weapon_ids = []

	for weapon in weapons:
		if not unique_weapon_ids.has(weapon.weapon_id):
			unique_weapon_ids.push_back(weapon.weapon_id)

	return unique_weapon_ids


func update_item_related_effects()->void :
	update_unique_bonuses()
	update_additional_weapon_bonuses()
	update_tier_iv_weapon_bonuses()
	update_tier_i_weapon_bonuses()


func update_unique_bonuses()->void :
	for effect in unique_effects:
		effects[effect[0]] -= effect[1]

	unique_effects = []
	var unique_weapon_ids = get_unique_weapon_ids()

	for i in unique_weapon_ids.size():
		for effect in effects["unique_weapon_effects"]:
			effects[effect[0]] += effect[1]
			unique_effects.push_back(effect)


func update_additional_weapon_bonuses()->void :
	for effect in additional_weapon_effects:
		effects[effect[0]] -= effect[1]

	additional_weapon_effects = []

	for weapon in weapons:
		for effect in effects["additional_weapon_effects"]:
			effects[effect[0]] += effect[1]
			additional_weapon_effects.push_back(effect)


func update_tier_iv_weapon_bonuses()->void :
	for effect in tier_iv_weapon_effects:
		effects[effect[0]] -= effect[1]

	tier_iv_weapon_effects = []

	for weapon in weapons:
		if weapon.tier >= Tier.LEGENDARY:
			for effect in effects["tier_iv_weapon_effects"]:
				effects[effect[0]] += effect[1]
				tier_iv_weapon_effects.push_back(effect)


func update_tier_i_weapon_bonuses()->void :
	for effect in tier_i_weapon_effects:
		effects[effect[0]] -= effect[1]

	tier_i_weapon_effects = []

	for weapon in weapons:
		if weapon.tier <= Tier.COMMON:
			for effect in effects["tier_i_weapon_effects"]:
				effects[effect[0]] += effect[1]
				tier_i_weapon_effects.push_back(effect)


func apply_item_effects(item_data:ItemParentData)->void :
	for effect in item_data.effects:
		effect.apply()
	ChallengeService.check_stat_challenges()


func unapply_item_effects(item_data:ItemParentData)->void :
	for effect in item_data.effects:
		effect.unapply()
	ChallengeService.check_stat_challenges()


func add_item_displayed(new_item:ItemData)->void :
	for new_appearance in new_item.item_appearances:

		if new_appearance == null:
			print("appearance is null : " + str(new_item.name))
			continue

		var display_appearance: = true

		if new_appearance.position != 0:
			var appearance_to_erase = null

			for appearance in appearances_displayed:
				if appearance.position != new_appearance.position or new_appearance.position == 0:
					continue

				if new_appearance.display_priority >= appearance.display_priority:
					appearance_to_erase = appearance
				else :
					display_appearance = false

				break

			if appearance_to_erase:
				appearances_displayed.erase(appearance_to_erase)

		if display_appearance:
			appearances_displayed.push_back(new_appearance)

		appearances_displayed.sort_custom(Sorter, "sort_depth_ascending")


func remove_item_displayed(_item_to_remove:ItemData)->void :
	init_appearances_displayed()
	
	for item in items:
		add_item_displayed(item)


func has_weapon_slot_available(weapon_type:int = - 1)->bool:

	if weapon_type == - 1:
		return weapons.size() < effects["weapon_slot"]
	else :
		var nb = 0

		for weapon in weapons:
			if weapon.type == weapon_type:
				nb += 1

		var max_slots = effects["max_melee_weapons"] if weapon_type == WeaponType.MELEE else effects["max_ranged_weapons"]

		return weapons.size() < effects["weapon_slot"] and nb < min(effects["weapon_slot"], max_slots)


func has_max_weapons()->bool:
	return weapons.size() <= max_weapons + RunData.effects["weapon_slot"]


func manage_life_steal(weapon_stats:WeaponStats)->void :
	if randf() < weapon_stats.lifesteal:
		emit_signal("lifesteal_effect", 1)


func get_stat(stat_name:String)->float:
	return effects[stat_name.to_lower()] * get_stat_gain(stat_name)


func get_stat_gain(stat_name:String)->float:

	if not effects.has("gain_" + stat_name.to_lower()):
		return 1.0

	return (1 + (effects["gain_" + stat_name.to_lower()] / 100.0))


func can_combine(weapon_data:WeaponData)->bool:
	var nb_duplicates = 0

	for weapon in weapons:
		if weapon.my_id == weapon_data.my_id:
			nb_duplicates += 1

	return nb_duplicates >= 2 and weapon_data.upgrades_into != null and weapon_data.tier < RunData.effects["max_weapon_tier"]


func get_dmg(value:int)->int:
	var percent_dmg_bonus = (1 + (Utils.get_stat("stat_percent_damage") / 100.0))
	return max(1, (max(1, value) * percent_dmg_bonus)) as int


func get_weapon_min_tier()->int:
	var min_tier = Tier.LEGENDARY

	for weapon in weapons:
		if weapon.tier < min_tier:
			min_tier = weapon.tier

	return min_tier


func sort_appearances()->void :
	appearances_displayed.sort_custom(Sorter, "sort_depth_ascending")


func init_remove_speed_data()->Dictionary:
	var data = {"value":0, "max_value":0}

	if effects["remove_speed"].size() > 0:
		for remove_speed_data in effects["remove_speed"]:
			data.value += remove_speed_data[1]
			data.max_value = max(data.max_value, remove_speed_data[2])

	return data


func get_remove_speed_data()->Dictionary:
	return remove_speed_effect_cache


func get_armor_coef(armor:int)->float:
	var percent_dmg_taken = 10.0 / (10.0 + (abs(armor) / 1.5))





	if armor < 0:
		percent_dmg_taken = (1.0 - percent_dmg_taken) + 1.0

	return percent_dmg_taken


func get_hp_regeneration_timer(hp_regen:int)->float:





	if hp_regen <= 0:
		return 99.0

	var timer_duration = 5.0 / (1.0 + (abs(hp_regen - 1) / 2.25))

	return timer_duration


func reset_background()->void :
	if ProgressData.settings.background == 0:
		current_background = Utils.get_rand_element(backgrounds)
	else :
		current_background = RunData.backgrounds[ProgressData.settings.background - 1]


func get_background()->Resource:
	return current_background


func get_background_gradient_color()->Resource:
	return Utils.get_rand_element(background_colors)


func add_stat(stat_name:String, value:int)->void :
	effects[stat_name] += value
	emit_signal("stat_added", stat_name, value, 0.0)
	_are_stats_dirty = true


func remove_stat(stat_name:String, value:int)->void :
	effects[stat_name] -= value
	emit_signal("stat_removed", stat_name, value)
	_are_stats_dirty = true


func emit_stats_updated()->void :
	if not _are_stats_dirty:
		return 
	_are_stats_dirty = false
	emit_signal("stats_updated")
	ChallengeService.check_stat_challenges()


func get_current_difficulty()->int:
	if current_difficulty >= 0:
		return current_difficulty
	if current_character != null:
		
		var diff_info = ProgressData.get_character_difficulty_info(current_character.my_id, current_zone)
		return diff_info.difficulty_selected_value
	return 0


func get_currency()->int:
	return get_stat("stat_max_hp") as int if effects["hp_shop"] else gold


func remove_currency(value:int)->void :
	if effects["hp_shop"]:
		remove_stat("stat_max_hp", value)
	else :
		remove_gold(value)


func get_nb_item(item_id:String, use_cache:bool = true)->int:
	var nb = 0

	if use_cache and items_nb_cache.has(item_id):
		return items_nb_cache[item_id]

	for item in items:
		if item_id == item.my_id:
			nb += 1

	if use_cache:
		items_nb_cache[item_id] = nb

	return nb


func get_nb_different_items_of_tier(tier:int = Tier.COMMON)->int:
	var nb = 0
	var parsed_items = {}

	for item in items:
		if item.tier == tier and not parsed_items.has(item.my_id) and not item.my_id.begins_with("character_"):
			parsed_items[item.my_id] = true
			nb += 1

	return nb


func add_recycled(value:int = 1)->void :
	chal_recycling_current += value
	if chal_recycling_current >= chal_recycling_value and not chal_recycling_completed:
		chal_recycling_completed = true
		ChallengeService.complete_challenge("chal_recycling")


func apply_weapon_selection_back()->void :
	weapons = []
	items = []
	effects = init_effects()
	Utils.last_elt_selected = current_character
	current_character = null
	init_appearances_displayed()
	var _error = get_tree().change_scene(MenuData.character_selection_scene)


func add_starting_items_and_weapons()->void :
	if effects["starting_item"].size() > 0:
		for item_id in effects["starting_item"]:
			for i in item_id[1]:
				var item = ItemService.get_element(ItemService.items, item_id[0])
				add_item(item)

	if effects["starting_weapon"].size() > 0:
		for weapon_id in effects["starting_weapon"]:
			for i in weapon_id[1]:
				var weapon = ItemService.get_element(ItemService.weapons, weapon_id[0])
				var _weapon = add_weapon(weapon)


func handle_explosion(key:String, pos:Vector2)->void :
	if effects[key].size() > 0:
		var explosion_chance = 0.0

		for explosion in effects[key]:
			explosion_chance += explosion.chance

		if Utils.get_chance_success(explosion_chance):
			var dmg = 0
			var first = effects[key][0]
			var exploding_effect = ExplodingEffect.new()

			for explosion in effects[key]:
				var explosion_stats = WeaponService.init_base_stats(explosion.stats, "", [], [exploding_effect])
				dmg += explosion_stats.damage

			var _inst = WeaponService.explode(first, pos, dmg, first.stats.accuracy, first.stats.crit_chance, first.stats.crit_damage, first.stats.burning_data, false, [], first.tracking_text)


func update_recycling_tracking_value(item_data:ItemParentData)->void :
	if RunData.get_nb_item("item_recycling_machine") > 0:
		var value = ItemService.get_value(RunData.current_wave, item_data.value, true, true, item_data.my_id)
		RunData.tracked_item_effects["item_recycling_machine"] += (value * (RunData.effects["recycling_gains"] / 100.0)) as int


func get_state(
		reset:bool = false, 
		shop_items:Array = [], 
		reroll_price:int = 0, 
		last_reroll_price:int = 0, 
		initial_free_rerolls:int = 0, 
		free_rerolls:int = 0
	)->Dictionary:

	if reset:
		return {
			"has_run_state":false
		}

	return {
		"has_run_state":true, 
		"enemy_scaling":current_run_accessibility_settings.duplicate(), 
		"nb_of_waves":nb_of_waves, 
		"current_zone":current_zone, 
		"current_level":current_level, 
		"current_xp":current_xp, 
		"max_weapons":max_weapons, 
		"current_wave":current_wave, 
		"current_difficulty":current_difficulty, 
		"gold":gold, 
		"bonus_gold":bonus_gold, 
		"elites_spawn":elites_spawn, 
		"shop_effects_checked":shop_effects_checked, 

		"weapons":weapons.duplicate(), 
		"items":items.duplicate(), 
		"effects":effects.duplicate(), 
		"challenges_completed_this_run":challenges_completed_this_run, 
		"current_character":current_character, 
		"starting_weapon":starting_weapon, 
		"active_set_effects":active_set_effects.duplicate(), 
		"unique_effects":unique_effects.duplicate(), 
		"additional_weapon_effects":additional_weapon_effects.duplicate(), 
		"tier_iv_weapon_effects":tier_iv_weapon_effects.duplicate(), 
		"tier_i_weapon_effects":tier_i_weapon_effects.duplicate(), 
		"locked_shop_items":locked_shop_items, 
		"current_background":current_background, 
		"appearances_displayed":appearances_displayed.duplicate(), 

		"active_sets":active_sets.duplicate(), 
		"difficulty_unlocked":difficulty_unlocked, 
		"max_endless_wave_record_beaten":max_endless_wave_record_beaten, 
		"is_endless_run":is_endless_run, 
		"chal_hoarder_value":chal_hoarder_value, 
		"chal_hoarder_completed":chal_hoarder_completed, 
		"chal_recycling_value":chal_recycling_value, 
		"chal_recycling_completed":chal_recycling_completed, 
		"chal_recycling_current":chal_recycling_current, 
		"chal_hungry_value":chal_hungry_value, 
		"chal_hungry_completed":chal_hungry_completed, 
		"consumables_picked_up_this_run":consumables_picked_up_this_run, 

		"shop_items":shop_items, 
		"reroll_price":reroll_price, 
		"last_reroll_price":last_reroll_price, 
		"initial_free_rerolls":initial_free_rerolls, 
		"free_rerolls":free_rerolls, 
		"tracked_item_effects":tracked_item_effects
	}


func resume_from_state(state:Dictionary)->void :

	resumed_from_state = true

	if state.has("enemy_scaling"):
		current_run_accessibility_settings = state.enemy_scaling
	else :
		current_run_accessibility_settings = ProgressData.settings.enemy_scaling.duplicate()

	nb_of_waves = state.nb_of_waves
	current_zone = state.current_zone
	current_level = state.current_level
	current_xp = state.current_xp
	max_weapons = state.max_weapons
	current_wave = state.current_wave
	if state.has("current_difficulty"):current_difficulty = state.current_difficulty
	gold = state.gold
	bonus_gold = state.bonus_gold

	if state.has("elites_spawn"):elites_spawn = state.elites_spawn
	if state.has("shop_effects_checked"):shop_effects_checked = state.shop_effects_checked

	weapons = state.weapons
	items = state.items
	effects = state.effects
	challenges_completed_this_run = state.challenges_completed_this_run
	current_character = state.current_character
	starting_weapon = state.starting_weapon
	active_set_effects = state.active_set_effects
	unique_effects = state.unique_effects
	additional_weapon_effects = state.additional_weapon_effects
	tier_iv_weapon_effects = state.tier_iv_weapon_effects
	tier_i_weapon_effects = state.tier_i_weapon_effects
	locked_shop_items = state.locked_shop_items
	current_background = state.current_background
	appearances_displayed = state.appearances_displayed

	active_sets = state.active_sets
	difficulty_unlocked = state.difficulty_unlocked
	max_endless_wave_record_beaten = state.max_endless_wave_record_beaten
	is_endless_run = state.is_endless_run
	chal_hoarder_value = state.chal_hoarder_value
	chal_hoarder_completed = state.chal_hoarder_completed

	if state.has("chal_recycling_value"):chal_recycling_value = state.chal_recycling_value
	if state.has("chal_recycling_completed"):chal_recycling_completed = state.chal_recycling_completed
	if state.has("chal_recycling_current"):chal_recycling_current = state.chal_recycling_current

	if state.has("chal_hungry_value"):chal_hungry_value = state.chal_hungry_value
	if state.has("chal_hungry_completed"):chal_hungry_completed = state.chal_hungry_completed
	if state.has("consumables_picked_up_this_run"):consumables_picked_up_this_run = state.consumables_picked_up_this_run

	if state.has("tracked_item_effects"):tracked_item_effects = state.tracked_item_effects

	LinkedStats.reset()


func init_tracked_effects()->Dictionary:
	return {
		"item_vigilante_ring":0, 
		"item_alien_eyes":0, 
		"item_baby_elephant":0, 
		"item_cyberball":0, 
		"item_baby_with_a_beard":0, 
		"item_bag":0, 
		"item_crown":0, 
		"item_cute_monkey":0, 
		"item_dangerous_bunny":0, 
		"item_hunting_trophy":0, 
		"item_metal_detector":0, 
		"item_piggy_bank":0, 
		"item_rip_and_tear":0, 
		"item_tree":0, 
		"item_anvil":0, 
		"item_grinds_magical_leaf":0, 
		"item_scared_sausage":0, 
		"item_recycling_machine":0, 
		"item_coupon":0, 
		"character_lich":0, 
		"item_riposte":0, 
		"item_adrenaline":0, 
		"item_spicy_sauce":0, 
		"item_tentacle":0, 
		"item_giant_belt":0, 
		"item_extra_stomach":0, 
		"character_glutton":0
	}


func init_stats(all_null_values:bool = false)->Dictionary:
	return {
		"stat_max_hp":10 if not all_null_values else 0, 
		"stat_armor":0, 
		"stat_crit_chance":0, 
		"stat_luck":0, 
		"stat_attack_speed":0, 
		"stat_elemental_damage":0, 
		"stat_hp_regeneration":0, 
		"stat_lifesteal":0, 
		"stat_melee_damage":0, 
		"stat_percent_damage":0, 
		"stat_dodge":0, 
		"stat_engineering":0, 
		"stat_range":0, 
		"stat_ranged_damage":0, 
		"stat_speed":0, 
		"stat_harvesting":0, 
		"xp_gain":0, 
		"number_of_enemies":0, 
		"consumable_heal":0, 
		"burning_cooldown_reduction":0, 
		"burning_spread":0, 
		"piercing":0, 
		"piercing_damage":0, 
		"pickup_range":0, 
		"chance_double_gold":0, 
		"bounce":0, 
		"bounce_damage":0, 
		"heal_when_pickup_gold":0, 
		"item_box_gold":0, 
		"knockback":0, 
		"hp_cap":999999 if not all_null_values else 0, 
		"speed_cap":999999 if not all_null_values else 0, 
		"lose_hp_per_second":0, 
		"map_size":0, 
		"dodge_cap":60, 
		"gold_drops":100 if not all_null_values else 0, 
		"enemy_health":0, 
		"enemy_damage":0, 
		"enemy_speed":0, 
		"boss_strength":0, 
		"explosion_size":0, 
		"explosion_damage":0, 
		"damage_against_bosses":0, 
		"giant_crit_damage":0, 
		"weapon_slot":6 if not all_null_values else 0, 
		"items_price":0, 
		"harvesting_growth":5 if not all_null_values else 0, 
		"hit_protection":0, 
		"weapons_price":0, 
	}


func init_effects()->Dictionary:
	var all_stats = init_stats()
	var all_effects = {
		"gain_stat_max_hp":0, 
		"gain_stat_armor":0, 
		"gain_stat_crit_chance":0, 
		"gain_stat_luck":0, 
		"gain_stat_attack_speed":0, 
		"gain_stat_elemental_damage":0, 
		"gain_stat_hp_regeneration":0, 
		"gain_stat_lifesteal":0, 
		"gain_stat_melee_damage":0, 
		"gain_stat_percent_damage":0, 
		"gain_stat_dodge":0, 
		"gain_stat_engineering":0, 
		"gain_stat_range":0, 
		"gain_stat_ranged_damage":0, 
		"gain_stat_speed":0, 
		"gain_stat_harvesting":0, 
		"no_melee_weapons":0, 
		"no_ranged_weapons":0, 
		"hp_start_wave":100, 
		"hp_start_next_wave":100, 
		"no_min_range":0, 
		"pacifist":0, 
		"cryptid":0, 
		"gain_pct_gold_start_wave":0, 
		"torture":0, 
		"recycling_gains":0, 
		"one_shot_trees":0, 
		"cant_stop_moving":0, 
		"max_ranged_weapons":999, 
		"max_melee_weapons":999, 
		"group_structures":0, 
		"double_hp_regen":0, 
		"can_attack_while_moving":1, 
		"trees":0, 
		"trees_start_wave":0, 
		"min_weapon_tier":0, 
		"max_weapon_tier":99, 
		"hp_shop":0, 
		"free_rerolls":0, 
		"instant_gold_attracting":0, 
		"inflation":0, 
		"double_boss":0, 
		"diff_gold_drops":0, 
		"gain_explosion_damage":0, 
		"gain_piercing_damage":0, 
		"gain_bounce_damage":0, 
		"gain_damage_against_bosses":0, 
		"neutral_gold_drops":0, 
		"enemy_gold_drops":0, 
		"wandering_bots":0, 
		"dmg_when_pickup_gold":[], 
		"dmg_when_death":[], 
		"dmg_when_heal":[], 
		"dmg_on_dodge":[], 
		"heal_on_dodge":[], 
		"remove_speed":[], 
		"starting_item":[], 
		"starting_weapon":[], 
		"projectiles_on_death":[], 
		"burn_chance":BurningData.new(), 
		"weapon_class_bonus":[], 
		"weapon_bonus":[], 
		"unique_weapon_effects":[], 
		"additional_weapon_effects":[], 
		"tier_iv_weapon_effects":[], 
		"tier_i_weapon_effects":[], 
		"gold_on_crit_kill":[], 
		"heal_on_crit_kill":0, 
		"temp_stats_while_not_moving":[], 
		"temp_stats_while_moving":[], 
		"temp_stats_on_hit":[], 
		"temp_stats_stacking":[], 
		"stats_end_of_wave":[], 
		"stat_links":[], 
		"structures":[], 
		"explode_on_hit":[], 
		"convert_stats_end_of_wave":[], 
		"explode_on_death":[], 
		"alien_eyes":[], 
		"double_hp_regen_below_half_health":0, 
		"upgrade_random_weapon":[], 
		"minimum_weapons_in_shop":0, 
		"destroy_weapons":0, 
		"extra_enemies_next_wave":0, 
		"extra_loot_aliens_next_wave":0, 
		"stats_next_wave":[], 
		"consumable_stats_while_max":[], 
		"explode_on_consumable":[], 
		"structures_cooldown_reduction":[], 
		"convert_stats_half_wave":[], 
		"stats_on_level_up":[], 
		"temp_stats_on_dodge":[], 
		"no_heal":0, 
		"tree_turrets":0, 
		"stats_below_half_health":[], 
		"guaranteed_shop_items":[], 
		"special_enemies_last_wave":0, 
		"specific_items_price":[], 
		"accuracy":0, 
		"projectiles":0, 
		"upgraded_baits":0
	}

	all_effects.merge(all_stats)

	return all_effects
