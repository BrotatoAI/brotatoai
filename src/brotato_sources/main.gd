extends Node

signal consumable_to_process_added(consumable_data)
signal upgrade_to_process_added(consumable_data)

export (PackedScene) var gold_bag_scene:PackedScene
export (PackedScene) var gold_scene:PackedScene
export (PackedScene) var consumable_scene:PackedScene
export (Resource) var turret_effect:Resource
export (Array) var gold_sprites:Array
export (Array, Resource) var gold_pickup_sounds:Array
export (Array, Resource) var gold_alt_pickup_sounds:Array
export (Resource) var level_up_sound:Resource
export (Array, Resource) var run_won_sounds:Array
export (Array, Resource) var run_lost_sounds:Array
export (Array, Resource) var end_wave_sounds:Array

func show_manual_cursor()->bool:
	return ProgressData.is_manual_aim() and not _cleaning_up

const EDGE_SIZE = 96
const MAX_GOLDS = 50
const MIN_MAP_SIZE = 12

const MOUSE_DIST_FROM_PLAYER_MANUAL_AIM = 200

var _cleaning_up: = false
var _golds: = []
var _consumables: = []
var _upgrades_to_process: = []
var _consumables_to_process: = []
var _end_wave_timer_timedout: = false

var _player:Player
var _is_run_lost:bool
var _is_run_won:bool
var _gold_bag:Node

var _landmine_timer:Timer = null
var _is_chal_ui_displayed = false

var _last_rjoy_input:Vector2 = Vector2.ZERO

var _proj_on_death_stat_cache:Dictionary = {}
var _items_spawned_this_wave: = 0
var _player_is_under_half_health: = false

var _nb_bosses_killed_this_wave: = 0
var _update_stats_on_gold_changed: = false
var _update_stats_on_enemies_changed: = false
var _update_stats_on_enemies_changed_timer:Timer = null
var _update_stats_on_neutrals_changed: = false
var _last_gold_amount_used_to_reload_stats: = 0
var _is_horde_wave: = false
var _is_elite_wave: = false
var _elite_killed_bonus: = 0
var _elite_killed: = false


var _convert_stats_half_wave_proced: = false

onready var _entities_container = $Entities
onready var _entity_spawner = $EntitySpawner
onready var _effects_manager = $EffectsManager
onready var _wave_manager = $WaveManager
onready var _floating_text_manager = $FloatingTextManager
onready var _camera = $Camera
onready var _screenshaker = $Camera / Screenshaker
onready var _items_container = $Items
onready var _consumables_container = $Consumables
onready var _births_container = $Births
onready var _pause_menu = $UI / PauseMenu
onready var _end_wave_timer = $EndWaveTimer
onready var _upgrades_ui = $UI / UpgradesUI as UpgradesUI
onready var _item_box_ui = $UI / ItemBoxUI as ItemBoxUI
onready var _wave_timer = $WaveTimer
onready var _player_life_bar = $"%PlayerLifeBar"
onready var _player_life_bar_container = $WorldUI / PlayerLifeBarContainer

onready var _wave_cleared_label = $UI / WaveClearedLabel
onready var _life_label = $UI / HUD / LifeContainer / UILifeBar / MarginContainer / LifeLabel
onready var _level_label = $UI / HUD / LifeContainer / UIXPBar / MarginContainer / LevelLabel
onready var _hud = $UI / HUD
onready var _life_bar = $UI / HUD / LifeContainer / UILifeBar
onready var _xp_bar = $UI / HUD / LifeContainer / UIXPBar
onready var _ui_gold = $UI / HUD / LifeContainer / UIGold
onready var _ui_bonus_gold = $UI / HUD / LifeContainer / UIBonusGold
onready var _ui_bonus_gold_pos = $UI / HUD / LifeContainer / UIBonusGold / Position2D
onready var _current_wave_label = $UI / HUD / WaveContainer / CurrentWaveLabel
onready var _wave_timer_label = $UI / HUD / WaveContainer / WaveTimerLabel
onready var _ui_wave_container = $UI / HUD / WaveContainer
onready var _ui_upgrades_to_process = $UI / HUD / ThingsToProcessContainer / Upgrades
onready var _ui_consumables_to_process = $UI / HUD / ThingsToProcessContainer / Consumables
onready var _ui_dim_screen = $UI / DimScreen
onready var _tile_map = $TileMap
onready var _tile_map_limits = $TileMapLimits
onready var _background = $CanvasLayer / Background
onready var _harvesting_timer = $HarvestingTimer
onready var _challenge_completed_ui = $UI / ChallengeCompletedUI

onready var _damage_vignette = $UI / DamageVignette
onready var _info_popup = $UI / InfoPopup
onready var _test_button = $"%TestButton"

func _ready()->void :

	if RunData.is_testing:_test_button.show()
	else :_test_button.hide()

	if DebugService.hide_wave_timer:_ui_wave_container.hide()

	
	RunData.shop_effects_checked = false
	RunData.current_living_enemies = 0
	RunData.current_living_trees = 0
	_convert_stats_half_wave_proced = false

	var _popup = _challenge_completed_ui.connect("started", self, "on_chal_popup")
	var _popout = _challenge_completed_ui.connect("finished", self, "on_chal_popout")

	_background.texture.gradient.colors[1] = RunData.get_background_gradient_color()
	_tile_map.tile_set.tile_set_texture(0, RunData.get_background().tiles_sprite)
	_tile_map.outline.modulate = RunData.get_background().outline_color

	TempStats.reset()

	var _temp_stats = TempStats.connect("temp_stats_updated", self, "on_stats_updated")
	var _stats = RunData.connect("stats_updated", self, "on_stats_updated")

	_gold_bag = Utils.instance_scene_on_main(gold_bag_scene, get_gold_bag_pos())
	var current_zone = ZoneService.get_zone_data(RunData.current_zone).duplicate()
	var current_wave_data = ZoneService.get_wave_data(RunData.current_zone, RunData.current_wave)

	var map_size_coef = (1 + (RunData.effects["map_size"] / 100.0))

	current_zone.width = max(MIN_MAP_SIZE, (current_zone.width * map_size_coef)) as int
	current_zone.height = max(MIN_MAP_SIZE, (current_zone.height * map_size_coef)) as int

	_tile_map.init(current_zone)
	_tile_map_limits.init(current_zone)

	ZoneService.current_zone_max_position = Vector2(current_zone.width * Utils.TILE_SIZE, current_zone.height * Utils.TILE_SIZE)

	_entity_spawner.init(
		_entities_container, 
		_births_container, 
		ZoneService.current_zone_min_position, 
		ZoneService.current_zone_max_position, 
		current_wave_data, 
		_wave_timer
	)

	_current_wave_label.text = Text.text("WAVE", [str(RunData.current_wave)]).to_upper()

	_wave_timer.wait_time = 1 if RunData.instant_waves else current_wave_data.wave_duration
	_wave_timer.start()
	_wave_timer_label.wave_timer = _wave_timer
	var _error_wave_timer = _wave_timer.connect("tick_started", self, "on_tick_started")

	var _error_group_spawn = _wave_manager.connect("group_spawn_timing_reached", _entity_spawner, "on_group_spawn_timing_reached")
	_wave_manager.init(_wave_timer, current_wave_data)

	var _error_upg_select = _upgrades_ui.connect("upgrade_selected", self, "on_upgrade_selected")
	var _error_take_button = _item_box_ui.connect("item_take_button_pressed", self, "on_item_box_take_button_pressed")
	var _error_discard_button = _item_box_ui.connect("item_discard_button_pressed", self, "on_item_box_discard_button_pressed")

	var _error_consumable_added = connect("consumable_to_process_added", _ui_consumables_to_process, "add_element")
	var _error_upgrade_added = connect("upgrade_to_process_added", _ui_upgrades_to_process, "add_element")

	var _error_level_up = RunData.connect("levelled_up", self, "on_levelled_up")
	var _error_level_up_floating_text = RunData.connect("levelled_up", _floating_text_manager, "on_levelled_up")
	var _error_xp_added = RunData.connect("xp_added", _xp_bar, "update_value")
	var _error_gold_ui = RunData.connect("gold_changed", _ui_gold, "on_gold_changed")
	var _error_gold_changed = RunData.connect("gold_changed", self, "on_gold_changed")
	var _error_bonus_gold_ui = RunData.connect("bonus_gold_changed", _ui_bonus_gold, "update_value")
	var _error_bonus_gold = RunData.connect("bonus_gold_changed", self, "on_bonus_gold_changed")
	on_bonus_gold_changed(RunData.bonus_gold)

	var _error_gamepad = InputService.connect("game_lost_focus", _pause_menu, "on_game_lost_focus")

	var _error_ui_upgrades_mouse_entered = _ui_upgrades_to_process.connect("ui_element_mouse_entered", self, "on_ui_element_mouse_entered")
	var _error_ui_consumables_mouse_entered = _ui_consumables_to_process.connect("ui_element_mouse_entered", self, "on_ui_element_mouse_entered")
	var _error_ui_upgrades_mouse_exited = _ui_upgrades_to_process.connect("ui_element_mouse_exited", self, "on_ui_element_mouse_exited")
	var _error_ui_consumables_mouse_exited = _ui_consumables_to_process.connect("ui_element_mouse_exited", self, "on_ui_element_mouse_exited")

	init_camera()
	set_level_label()
	_ui_dim_screen.color.a = 0

	var pct_val = RunData.effects["gain_pct_gold_start_wave"]
	var apply_pct_gold_wave = (pct_val > 0 and RunData.current_wave <= RunData.nb_of_waves) or pct_val < 0

	
	
	if pct_val < 0 and RunData.current_wave > RunData.nb_of_waves:
		pct_val = - 100.0

	if apply_pct_gold_wave:
		var val = RunData.gold * (pct_val / 100.0)
		RunData.add_gold(val)

		if RunData.effects["gain_pct_gold_start_wave"] > 0:
			RunData.tracked_item_effects["item_piggy_bank"] += val

	for stat_link in RunData.effects["stat_links"]:
		if stat_link[2] == "materials":
			_update_stats_on_gold_changed = true
		elif stat_link[2] == "living_enemy":
			_update_stats_on_enemies_changed = true
			_update_stats_on_enemies_changed_timer = Timer.new()
			_update_stats_on_enemies_changed_timer.wait_time = 1.0
			_update_stats_on_enemies_changed_timer.one_shot = true
			add_child(_update_stats_on_enemies_changed_timer)
		elif stat_link[2] == "living_tree":
			_update_stats_on_neutrals_changed = true

	if ProgressData.is_manual_aim():
		InputService.hide_mouse = false

	var _error_options_1 = _pause_menu.menu_gameplay_options.connect("character_highlighting_changed", self, "on_character_highlighting_changed")
	var _error_options_2 = _pause_menu.menu_gameplay_options.connect("hp_bar_on_character_changed", self, "on_hp_bar_on_character_changed")
	var _error_options_3 = _pause_menu.menu_gameplay_options.connect("weapon_highlighting_changed", self, "on_weapon_highlighting_changed")
	var _error_options_4 = _pause_menu.menu_gameplay_options.connect("darken_screen_changed", self, "on_darken_screen_changed")

	_is_horde_wave = RunData.is_elite_wave(EliteType.HORDE)
	_is_elite_wave = RunData.is_elite_wave(EliteType.ELITE)

	DebugService.log_run_info()
	RunData.reset_weapons_dmg_dealt()
	RunData.reset_cache()


func _input(event:InputEvent)->void :
	var is_right_stick_motion = event is InputEventJoypadMotion and (event.axis == JOY_AXIS_2 or event.axis == JOY_AXIS_3) and abs(event.axis_value) > 0.5
	var is_mouse_press = event is InputEventMouseButton

	if (is_mouse_press or is_right_stick_motion) and not _cleaning_up:
		if ProgressData.settings.manual_aim_on_mouse_press and not ProgressData.settings.manual_aim:
			if is_mouse_press:
				if event.pressed:
					InputService.hide_mouse = false
				else :
					InputService.hide_mouse = true
			else :
				InputService.hide_mouse = false

	if InputService.using_gamepad and not InputService.hide_mouse and not ProgressData.is_manual_aim():
		InputService.hide_mouse = true


func add_timer(cooldown:int)->Timer:
	var timer = Timer.new()
	timer.wait_time = cooldown
	add_child(timer)
	timer.start()
	return timer


func on_ui_element_mouse_entered(ui_element:Node, text:String)->void :
	if _cleaning_up:
		_info_popup.display(ui_element, tr(text))


func on_ui_element_mouse_exited(_ui_element:Node)->void :
	_info_popup.hide()


func on_character_highlighting_changed(value:int)->void :
	if not is_instance_valid(_player) or not _player.is_inside_tree():return 
	_player.highlight.visible = value


func on_weapon_highlighting_changed(value:int)->void :
	if not is_instance_valid(_player) or not _player.is_inside_tree():return 
	_player.update_weapon_highlighting(value)


func on_darken_screen_changed(_value:int)->void :
	_damage_vignette.update_from_hp()


func on_hp_bar_on_character_changed(value:int)->void :
	if not is_instance_valid(_player) or not _player.is_inside_tree():return 

	if value:
		_player_life_bar.update_value(_player.current_stats.health, _player.max_stats.health)

		if _player.current_stats.health < _player.max_stats.health:
			_player_life_bar.show()

		if not _player.is_connected("health_updated", self, "on_player_health_updated"):
			var _error_hp_lifebar = _player.connect("health_updated", self, "on_player_health_updated")


func on_stats_updated()->void :
	reload_stats()


func reload_stats()->void :
	_player.update_player_stats()

	LinkedStats.reset()

	for weapon in _player.current_weapons:
		if is_instance_valid(weapon):
			weapon.init_stats(false)

	for struct in _entity_spawner.structures:
		if is_instance_valid(struct):
			struct.reload_data()

	_proj_on_death_stat_cache.clear()


func _physics_process(_delta:float)->void :
	_gold_bag.global_position = get_gold_bag_pos()

	var life_bar_effects = _player.life_bar_effects()
	_life_bar.update_color_from_effects(life_bar_effects)
	_player_life_bar.update_color_from_effects(life_bar_effects)

	# ANCHOR : Aim
	if not _cleaning_up and ProgressData.is_manual_aim() and InputService.using_gamepad:
		var rjoy = Input.get_vector("rjoy_left", "rjoy_right", "rjoy_up", "rjoy_down").normalized()
		var player_pos = _player.get_global_transform_with_canvas().origin

		player_pos.y -= 32
		if rjoy.length() > 0.5:
			get_viewport().warp_mouse(player_pos + MOUSE_DIST_FROM_PLAYER_MANUAL_AIM * rjoy)
			_last_rjoy_input = rjoy
		else :
			get_viewport().warp_mouse(player_pos + MOUSE_DIST_FROM_PLAYER_MANUAL_AIM * _last_rjoy_input)

	if not _convert_stats_half_wave_proced and _wave_timer.time_left <= _wave_timer.wait_time / 2.0 and RunData.effects["convert_stats_half_wave"].size() > 0:
		_convert_stats_half_wave_proced = true
		Utils.convert_stats(RunData.effects["convert_stats_half_wave"], false)


func on_tick_started()->void :
	_wave_timer_label.modulate = Color.red


func on_bonus_gold_changed(value:int)->void :
	if value == 0:
		_ui_bonus_gold.hide()


func init_camera()->void :
	var max_pos = ZoneService.current_zone_max_position
	var min_pos = ZoneService.current_zone_min_position

	var zone_w = max_pos.x - min_pos.x
	var zone_h = max_pos.y - min_pos.y

	_camera.center_horizontal_pos = zone_w / 2
	_camera.center_vertical_pos = zone_h / 2

	if zone_w + EDGE_SIZE * 2 <= Utils.project_width:
		_camera.center_horizontal = true
	else :
		_camera.limit_right = max_pos.x + EDGE_SIZE
		_camera.limit_left = min_pos.x - EDGE_SIZE

	if zone_h + EDGE_SIZE * 2 <= Utils.project_height:
		_camera.center_vertical = true
	else :
		_camera.limit_bottom = max_pos.y + EDGE_SIZE
		_camera.limit_top = min_pos.y - EDGE_SIZE * 2


func _on_player_died(_p_player:Player)->void :
	# _player_life_bar.hide()
	
	# ANCHOR : Restart, died
	print_debug('player died...')
	
	var controller = $"/root/Main/AIController2D"
	controller.reset()
#
#	ProgressData.reset_run_state()
#	RunData.reset(true)
#	TempStats.reset()
	
	# _ready()

	# var _error = get_tree().change_scene(MenuData.game_scene)
	# get_tree().set_pause(false)
	
	###

	# if RunData.current_wave <= RunData.nb_of_waves:
	#	_is_run_lost = true
	# else :
	#	_is_run_won = true
	# clean_up_room(false, _is_run_lost, _is_run_won)
	# _end_wave_timer.start()
	# ProgressData.reset_run_state()
	# ChallengeService.complete_challenge("chal_rookie")


func _on_enemy_died(enemy:Enemy)->void :
	RunData.current_living_enemies -= 1

	if _update_stats_on_enemies_changed and _update_stats_on_enemies_changed_timer.is_stopped():
		reload_stats()
		_update_stats_on_enemies_changed_timer.start()

	if not _cleaning_up:
		if enemy is Boss:
			if RunData.effects["double_boss"]:
				_nb_bosses_killed_this_wave += 1

			if RunData.current_wave < RunData.nb_of_waves:
				_elite_killed = true

			if (_nb_bosses_killed_this_wave >= 2 or not RunData.effects["double_boss"]) and RunData.current_wave == RunData.nb_of_waves:

				if RunData.is_endless_run:
					var additional_groups = ZoneService.get_additional_groups(int((RunData.current_wave / 10.0) * 3))
					for i in additional_groups.size():
						additional_groups[i].spawn_timing = _wave_timer.wait_time - _wave_timer.time_left + i

					_wave_manager.add_groups(additional_groups)

				else :
					_wave_timer.wait_time = 0.1
					_wave_timer.start()


		if RunData.effects["dmg_when_death"].size() > 0:
			var dmg_taken = handle_stat_damages(RunData.effects["dmg_when_death"])
			RunData.tracked_item_effects["item_cyberball"] += dmg_taken[1]


		if RunData.effects["projectiles_on_death"].size() > 0:
			for proj_on_death_effect in RunData.effects["projectiles_on_death"]:
				for i in proj_on_death_effect[0]:
					var stats = proj_on_death_effect[1]

					if _proj_on_death_stat_cache.has(i):
						stats = _proj_on_death_stat_cache[i]
					else :
						stats = WeaponService.init_ranged_stats(proj_on_death_effect[1])
						_proj_on_death_stat_cache[i] = stats

					var _projectile = WeaponService.manage_special_spawn_projectile(
						enemy, 
						stats, 
						proj_on_death_effect[2], 
						_entity_spawner, 
						rand_range( - PI, PI), 
						"item_baby_with_a_beard"
					)

		RunData.handle_explosion("explode_on_death", enemy.global_position)

		spawn_loot(enemy, EntityType.ENEMY)

		ProgressData.add_data("enemies_killed")


func _on_neutral_died(neutral:Neutral)->void :
	RunData.current_living_trees -= 1

	if _update_stats_on_neutrals_changed:
		reload_stats()

	if not _cleaning_up:
		spawn_loot(neutral, EntityType.NEUTRAL)

		if RunData.effects["tree_turrets"] > 0:
			for _i in RunData.effects["tree_turrets"]:
				var pos = _entity_spawner.get_spawn_pos_in_area(neutral.global_position, 200)
				_entity_spawner.queue_to_spawn_structures.push_back([EntityType.STRUCTURE, turret_effect.scene, pos, turret_effect])


func spawn_loot(unit:Unit, entity_type:int)->void :

	if not unit.can_drop_loot:
		return 

	if unit.stats.can_drop_consumables:
		spawn_consumables(unit)

	var gold_drops = (RunData.effects["gold_drops"] / 100.0)

	if entity_type == EntityType.ENEMY:
		gold_drops += RunData.effects["enemy_gold_drops"] / 100.0

	var wave_factor = RunData.current_wave * 0.015
	var diff_factor = (RunData.effects["diff_gold_drops"] / 100.0)
	var spawn_chance = (1.0 + diff_factor) * gold_drops if (RunData.current_wave < 5) else max(0.5 * gold_drops, (1.0 - wave_factor + diff_factor) * gold_drops)

	if _is_horde_wave:
		spawn_chance *= 0.65

	if unit.stats.always_drop_consumables:
		spawn_chance = 1.0

	if entity_type == EntityType.ENEMY and not Utils.get_chance_success(spawn_chance):
		return 

	if _golds.size() > MAX_GOLDS:
		var gold_boosted = Utils.get_rand_element(_golds)
		gold_boosted.value += unit.stats.value
		gold_boosted.scale += Vector2(unit.stats.value * 0.05, unit.stats.value * 0.05)
	else :
		spawn_gold(unit, entity_type)


func spawn_consumables(unit:Unit)->void :
	var luck = (Utils.get_stat("stat_luck") / 100.0)
	var drop_chance = min(1.0, unit.stats.base_drop_chance * (1 + luck))

	if RunData.current_wave > RunData.nb_of_waves:
		drop_chance /= (1.0 + RunData.get_endless_factor())

	if Utils.get_chance_success(drop_chance) or unit.stats.always_drop_consumables:
		var pos = unit.global_position
		var consumable_to_spawn:Resource
		var item_chance = (unit.stats.item_drop_chance * (1 + luck)) / (1 + _items_spawned_this_wave)

		if unit.stats.always_drop_consumables and unit.stats.item_drop_chance >= 1.0 and RunData.current_wave <= RunData.nb_of_waves:
			item_chance = 1.0

		if Utils.get_chance_success(item_chance):
			consumable_to_spawn = ItemService.item_box

			if unit is Boss and RunData.current_wave <= RunData.nb_of_waves:
				consumable_to_spawn = ItemService.legendary_item_box

			_items_spawned_this_wave += 1
		else :
			var consumable_tier = Utils.get_random_int(unit.stats.min_consumable_tier, unit.stats.max_consumable_tier)
			consumable_to_spawn = ItemService.get_consumable_to_drop(consumable_tier)

		var dist = rand_range(50, 100 + unit.stats.gold_spread)
		var consumable = consumable_scene.instance()
		consumable.consumable_data = consumable_to_spawn
		consumable.global_position = pos
		_consumables_container.call_deferred("add_child", consumable)
		consumable.call_deferred("set_texture", consumable_to_spawn.icon)
		var _error = consumable.connect("picked_up", self, "on_consumable_picked_up")
		consumable.push_back_destination = ZoneService.get_rand_pos_in_area(pos, dist, 0)
		_consumables.push_back(consumable)


func on_consumable_picked_up(consumable:Node)->void :
	RunData.consumables_picked_up_this_run += 1
	_consumables.erase(consumable)

	if (consumable.consumable_data.my_id == "consumable_item_box" or consumable.consumable_data.my_id == "consumable_legendary_item_box") and RunData.effects["item_box_gold"] != 0:
		RunData.add_gold(RunData.effects["item_box_gold"])
		RunData.tracked_item_effects["item_bag"] += RunData.effects["item_box_gold"]

	if consumable.consumable_data.to_be_processed_at_end_of_wave:
		_consumables_to_process.push_back(consumable.consumable_data)
		emit_signal("consumable_to_process_added", consumable.consumable_data)

	if RunData.consumables_picked_up_this_run >= RunData.chal_hungry_value:
		ChallengeService.complete_challenge("chal_hungry")

	if RunData.effects["consumable_stats_while_max"].size() > 0 and _player.current_stats.health >= _player.max_stats.health:
		for i in RunData.effects["consumable_stats_while_max"].size():
			var stat = RunData.effects["consumable_stats_while_max"][i]
			var has_max = (stat.size() > 2
				 and RunData.max_consumable_stats_gained_this_wave.size() > i
				 and RunData.max_consumable_stats_gained_this_wave[i].size() > 2)

			var reached_max = false

			if has_max:
				reached_max = RunData.max_consumable_stats_gained_this_wave[i][2] >= stat[2]

			if not has_max or not reached_max:
				RunData.add_stat(stat[0], stat[1])

				if stat[0] == "stat_max_hp":
					RunData.tracked_item_effects["item_extra_stomach"] += stat[1]

				if has_max:
					RunData.max_consumable_stats_gained_this_wave[i][2] += stat[1]

		RunData.emit_stats_updated()

	if not _cleaning_up:
		RunData.handle_explosion("explode_on_consumable", consumable.global_position)

	RunData.apply_item_effects(consumable.consumable_data)


func spawn_gold(unit:Unit, entity_type:int)->void :
	var pos = unit.global_position
	var value = unit.stats.value

	if entity_type == EntityType.NEUTRAL:
		value += (value * round(RunData.effects["neutral_gold_drops"] / 100.0))
	elif entity_type == EntityType.ENEMY and RunData.effects["enemy_gold_drops"] > 1.0:
		value += (value * round(RunData.effects["enemy_gold_drops"] / 100.0))

	for i in value:
		var dist = rand_range(50, 100 + unit.stats.gold_spread)
		var gold = gold_scene.instance()

		if RunData.bonus_gold > 0:
			var gold_value = gold.value
			gold.value += min(gold.value, RunData.bonus_gold)
			gold.boosted = 2
			gold.scale.x = 1.25
			gold.scale.y = 1.25
			RunData.remove_bonus_gold(gold_value)

		gold.global_position = pos
		gold.rotation = rand_range(0, 2 * PI)
		_items_container.call_deferred("add_child", gold)
		gold.call_deferred("set_texture", gold_sprites[randi() % 11])
		var _error = gold.connect("picked_up", self, "on_gold_picked_up")
		var _error_effects = gold.connect("picked_up", _effects_manager, "on_gold_picked_up")
		var _error_floating_text = gold.connect("picked_up", _floating_text_manager, "on_gold_picked_up")
		gold.push_back_destination = ZoneService.get_rand_pos_in_area(pos, dist, 0)
		_golds.push_back(gold)

		if randf() < (RunData.effects["instant_gold_attracting"] / 100.0):
			gold.attracted_by = _player


func on_gold_picked_up(gold:Node)->void :
	_golds.erase(gold)
	if ProgressData.settings.alt_gold_sounds:
		SoundManager.play(Utils.get_rand_element(gold_alt_pickup_sounds), - 5, 0.2)
	else :
		SoundManager.play(Utils.get_rand_element(gold_pickup_sounds), 0, 0.2)

	var value = gold.value

	if Utils.get_chance_success(RunData.effects["chance_double_gold"] / 100.0):
		RunData.tracked_item_effects["item_metal_detector"] += value
		value *= 2
		gold.boosted *= 2

	if Utils.get_chance_success(RunData.effects["heal_when_pickup_gold"] / 100.0):
		RunData.emit_signal("healing_effect", 1, "item_cute_monkey")

	if gold.attracted_by == _player:

		if RunData.effects["dmg_when_pickup_gold"].size() > 0:
			var dmg_taken = handle_stat_damages(RunData.effects["dmg_when_pickup_gold"])
			RunData.tracked_item_effects["item_baby_elephant"] += dmg_taken[1]

		RunData.add_gold(value)
		RunData.add_xp(value)
		ProgressData.add_data("materials_collected")
	else :
		RunData.add_bonus_gold(value)


func on_levelled_up()->void :
	SoundManager.play(level_up_sound, 0, 0, true)
	var level = RunData.current_level
	emit_signal("upgrade_to_process_added", ItemService.upgrade_to_process_icon, level)
	_upgrades_to_process.push_back(level)
	set_level_label()
	RunData.add_stat("stat_max_hp", 1)
	for stat_level_up in RunData.effects["stats_on_level_up"]:
		RunData.add_stat(stat_level_up[0], stat_level_up[1])
	RunData.emit_stats_updated()
	RunData.emit_signal("healing_effect", 1)


func set_level_label()->void :
	_level_label.text = "LV." + str(RunData.current_level)



func set_life_label(current_health:int, max_health:int)->void :
	_life_label.text = str(max(current_health, 0.0)) + " / " + str(max_health)


func connect_visual_effects(unit:Unit)->void :
	var _error_effects = unit.connect("took_damage", _effects_manager, "_on_unit_took_damage")
	var _error_floating_text = unit.connect("took_damage", _floating_text_manager, "_on_unit_took_damage")


func clean_up_room(is_last_wave:bool = false, is_run_lost:bool = false, is_run_won:bool = false)->void :

	if is_run_lost:
		DebugService.log_data("is_run_lost")
		_wave_timer_label.is_run_lost = true
		_wave_timer.stop()
		_wave_timer.tick_timer.stop()
		_end_wave_timer.wait_time = 2.5
		SoundManager.play(Utils.get_rand_element(run_lost_sounds), - 5, 0, true)
		_ui_dim_screen.dim()
		MusicManager.tween( - 20)
	elif is_run_won:
		DebugService.log_data("is_run_won")
		apply_run_won()

	if RunData.is_endless_run:

		if RunData.current_wave % 10 == 0 and RunData.current_wave >= 20:
			RunData.init_elites_spawn(RunData.current_wave, 0.0)

		DebugService.log_data("is_endless_run")

		if RunData.current_wave >= 20:
			var character_difficulty = ProgressData.get_character_difficulty_info(RunData.current_character.my_id, RunData.current_zone)

			character_difficulty.max_endless_wave_beaten.set_info(
				RunData.get_current_difficulty(), 
				RunData.current_wave, 
				RunData.current_run_accessibility_settings.health, 
				RunData.current_run_accessibility_settings.damage, 
				RunData.current_run_accessibility_settings.speed, 
				true
			)

	if not RunData.is_testing:
		ProgressData.save()

	SoundManager.play(Utils.get_rand_element(end_wave_sounds))
	_cleaning_up = true
	_effects_manager.clean_up_room()
	_floating_text_manager.clean_up_room()

	DebugService.log_data("attract bonus_gold and consumables...")
	if _golds.size() > 0:
		var attracted_by = null




		_ui_bonus_gold.show()
		attracted_by = _gold_bag
		_player.disable_gold_pickup()

		if ProgressData.settings.optimize_end_waves:
			var bonus_gold_value = 0

			for gold in _golds:
				var value = gold.value

				if Utils.get_chance_success(RunData.effects["chance_double_gold"] / 100.0):
					RunData.tracked_item_effects["item_metal_detector"] += value
					value *= 2

				bonus_gold_value += value

				gold.visible = false

			RunData.add_bonus_gold(bonus_gold_value)
		else :
			for gold in _golds:
				gold.set_collision_layer(256)
				gold.attracted_by = attracted_by

	if _consumables.size() > 0:
		for consumable in _consumables:
			consumable.attracted_by = _player

	DebugService.log_data("clean_up other objects...")
	_entity_spawner.clean_up_room()
	_wave_manager.clean_up_room()

	if is_instance_valid(_player):
		_player.clean_up()

	DebugService.log_data("start wave_cleared_label...")
	_wave_cleared_label.start(is_last_wave, is_run_lost, is_run_won)
	DebugService.log_data("wave_cleared_label started...")


func get_gold_bag_pos()->Vector2:
	return get_viewport().get_canvas_transform().affine_inverse().xform(_ui_bonus_gold_pos.global_position)


func _on_EndWaveTimer_timeout()->void :
	DebugService.log_data("_on_EndWaveTimer_timeout")
	_end_wave_timer_timedout = true
	_ui_dim_screen.dim()
	_ui_consumables_to_process.modulate = Color.white
	_ui_upgrades_to_process.modulate = Color.white
	_wave_cleared_label.hide()
	_wave_timer_label.hide()

	if _landmine_timer:
		_landmine_timer.stop()

	if _is_run_lost or is_last_wave() or _is_run_won:
		DebugService.log_data("end run...")
		RunData.run_won = not _is_run_lost

		if RunData.is_testing:
			var _error = get_tree().change_scene(MenuData.editor_scene)
		else :
			var _error = get_tree().change_scene("res://ui/menus/run/end_run.tscn")
	else :
		DebugService.log_data("process consumables and upgrades...")
		MusicManager.tween( - 8)
		if _consumables_to_process.size() > 0:
			for consumable in _consumables_to_process:
				var fixed_tier = - 1

				if consumable.my_id == "consumable_legendary_item_box":
					fixed_tier = Tier.LEGENDARY

				var item_data = ItemService.process_item_box(RunData.current_wave, consumable, fixed_tier)
				_item_box_ui.set_item_data(item_data)
				yield (_item_box_ui, "item_box_processed")
				_ui_consumables_to_process.remove_element(consumable)

		if _upgrades_to_process.size() > 0:
			for upgrade_to_process in _upgrades_to_process:
				_upgrades_ui.show_upgrade_options(upgrade_to_process)
				yield (_upgrades_ui, "upgrade_selected")
				_ui_upgrades_to_process.remove_element(upgrade_to_process)

		DebugService.log_data("display challenge ui...")
		if _is_chal_ui_displayed:
			yield (_challenge_completed_ui, "finished")

		var _error = get_tree().change_scene("res://ui/menus/shop/shop.tscn")


func on_focus_lost()->void :
	if _end_wave_timer_timedout:
		if _item_box_ui.visible:
			_item_box_ui.focus()
		elif _upgrades_ui.visible:
			_upgrades_ui.focus()


func on_upgrade_selected(upgrade_data:UpgradeData)->void :
	RunData.apply_item_effects(upgrade_data)


func on_item_box_take_button_pressed(item_data:ItemParentData)->void :
	RunData.add_item(item_data)


func on_item_box_discard_button_pressed(item_data:ItemParentData)->void :
	RunData.add_gold(ItemService.get_recycling_value(RunData.current_wave, item_data.value))
	RunData.update_recycling_tracking_value(item_data)


func _on_PauseMenu_paused()->void :
	reload_stats()


func _on_PauseMenu_unpaused()->void :
	on_focus_lost()


func _on_WaveTimer_timeout()->void :
	
	# ANCHOR : end wave won
	
	print_debug('end wave')
	
	RunData.reset()
	TempStats.reset()
	
	_player.die()
	
	_ready()

#	DebugService.log_run_info(_upgrades_to_process, _consumables_to_process)
#
#	var is_last_wave = is_last_wave()
#
#	if not _is_run_lost and is_last_wave:
#		_is_run_won = true
#
#	ChallengeService.check_counted_challenges()
#
#	if _player != null and is_instance_valid(_player) and _player.current_stats.health == ChallengeService.get_chal("chal_reckless").value:
#		ChallengeService.complete_challenge("chal_reckless")
#
#	if _entity_spawner.neutrals.size() >= ChallengeService.get_chal("chal_forest").value:
#		ChallengeService.complete_challenge("chal_forest")
#
#	if RunData.effects["stats_end_of_wave"].size() > 0:
#		for stat_end_of_wave in RunData.effects["stats_end_of_wave"]:
#			RunData.add_stat(stat_end_of_wave[0], stat_end_of_wave[1])
#
#			if stat_end_of_wave[0] == "stat_percent_damage":
#				RunData.tracked_item_effects["item_vigilante_ring"] += stat_end_of_wave[1]
#			elif stat_end_of_wave[0] == "stat_max_hp":
#
#				var leaf_value = 0
#
#				for item in RunData.items:
#					if item.my_id == "item_grinds_magical_leaf":
#						leaf_value = item.effects[0].value + 2
#
#				RunData.tracked_item_effects["item_grinds_magical_leaf"] += leaf_value
#		RunData.emit_stats_updated()
#
#	if RunData.effects["convert_stats_end_of_wave"].size() > 0:
#		Utils.convert_stats(RunData.effects["convert_stats_end_of_wave"])
#
#	manage_harvesting()
#
#
#	DebugService.log_data("start clean_up_room...")
#	clean_up_room(is_last_wave, false, _is_run_won)
#
#	if _is_run_won:
#		apply_run_won()
#
#	_end_wave_timer.start()
#	TempStats.reset()
#	InputService.hide_mouse = true


func apply_run_won()->void :
	_wave_timer.stop()
	_wave_timer.tick_timer.stop()
	_end_wave_timer.wait_time = 3
	_ui_dim_screen.dim()
	SoundManager.play(Utils.get_rand_element(run_won_sounds), - 5, 0, true)

	var character_chal_name = "chal_" + RunData.current_character.name.to_lower().replace("character_", "")
	ChallengeService.complete_challenge(character_chal_name)

	var character_difficulty = ProgressData.get_character_difficulty_info(RunData.current_character.my_id, RunData.current_zone)

	if character_difficulty.max_selectable_difficulty < RunData.get_current_difficulty() + 1 and RunData.get_current_difficulty() + 1 <= ProgressData.MAX_DIFFICULTY:
		RunData.difficulty_unlocked = RunData.get_current_difficulty() + 1

	ChallengeService.complete_challenge("chal_difficulty_" + str(RunData.get_current_difficulty()))

	for char_diff in ProgressData.difficulties_unlocked:
		for zone_difficulty_info in char_diff.zones_difficulty_info:
			zone_difficulty_info.max_selectable_difficulty = clamp(RunData.get_current_difficulty() + 1, zone_difficulty_info.max_selectable_difficulty, ProgressData.MAX_DIFFICULTY)

	character_difficulty.max_difficulty_beaten.set_info(
		RunData.get_current_difficulty(), 
		RunData.current_wave, 
		RunData.current_run_accessibility_settings.health, 
		RunData.current_run_accessibility_settings.damage, 
		RunData.current_run_accessibility_settings.speed, 
		false
	)

	ProgressData.reset_run_state()


func is_last_wave()->bool:
	var is_last_wave = RunData.current_wave == ZoneService.get_zone_data(RunData.current_zone).waves_data.size()
	if RunData.is_endless_run:is_last_wave = false
	return is_last_wave


func manage_harvesting()->void :

	var elite_end_wave_bonus = 0

	if Utils.get_stat("stat_harvesting") != 0 or RunData.effects["pacifist"] != 0 or elite_end_wave_bonus != 0 or _elite_killed_bonus != 0 or (RunData.effects["cryptid"] != 0 and RunData.current_living_trees != 0):
		var pacifist_bonus = round((_entity_spawner.get_all_enemies().size() + _entity_spawner.enemies_removed_for_perf) * (RunData.effects["pacifist"] / 100.0))
		var cryptid_bonus = RunData.current_living_trees * RunData.effects["cryptid"]

		if _is_horde_wave:
			pacifist_bonus = (pacifist_bonus / 2) as int

		var val = Utils.get_stat("stat_harvesting") + pacifist_bonus + cryptid_bonus + _elite_killed_bonus + elite_end_wave_bonus

		RunData.add_gold(val)
		RunData.add_xp(val)

		_floating_text_manager.on_harvested(val)

		if Utils.get_stat("stat_harvesting") > 0:
			_harvesting_timer.start()

		RunData.add_xp(0)


func _on_FiveSecondsTimer_timeout()->void :
	if _cleaning_up:
		return 
	if RunData.effects["temp_stats_stacking"].size() > 0:
		for temp_stat_stacked in RunData.effects["temp_stats_stacking"]:
			TempStats.add_stat(temp_stat_stacked[0], temp_stat_stacked[1])
		TempStats.emit_updated()


func _on_UIBonusGold_mouse_entered()->void :
	if _cleaning_up:
		_info_popup.display(_ui_bonus_gold, Text.text("INFO_BONUS_GOLD", [str(RunData.bonus_gold)]))


func _on_UIBonusGold_mouse_exited()->void :
	_info_popup.hide()


func _on_EntitySpawner_player_spawned(player:Player)->void :
	_player = player
	TempStats.player = player
	_floating_text_manager.player = player

	player.get_remote_transform().remote_path = _camera.get_path()
	player.get_life_bar_remote_transform().remote_path = _player_life_bar_container.get_path()
	player.current_stats.health = max(1, player.max_stats.health * (RunData.effects["hp_start_wave"] / 100.0)) as int

	if RunData.effects["hp_start_next_wave"] != 100:
		player.current_stats.health = max(1, player.max_stats.health * (RunData.effects["hp_start_next_wave"] / 100.0)) as int
		on_player_health_updated(player.current_stats.health, player.max_stats.health)
		RunData.effects["hp_start_next_wave"] = 100

	player.check_hp_regen()
	_damage_vignette.update_from_hp(player.current_stats.health, player.max_stats.health)
	_life_bar.update_value(player.current_stats.health, player.max_stats.health)

	if ProgressData.settings.hp_bar_on_character:
		_player_life_bar.update_value(player.current_stats.health, player.max_stats.health)

	var _error_player_hp = player.connect("health_updated", self, "on_player_health_updated")
	set_life_label(player.current_stats.health, player.max_stats.health)
	_xp_bar.update_value(RunData.current_xp, RunData.get_next_level_xp_needed())
	var _error_hp_vignette = player.connect("health_updated", _damage_vignette, "update_from_hp")
	var _error_hp_lifebar = player.connect("health_updated", _life_bar, "update_value")
	var _error_hp_text = player.connect("healed", _floating_text_manager, "_on_player_healed")
	var _error_hp = player.connect("health_updated", self, "set_life_label")
	var _error_died = player.connect("died", self, "_on_player_died")
	var _error_took_damage = player.connect("took_damage", _screenshaker, "_on_player_took_damage")
	var _error_healing_effect = RunData.connect("healing_effect", player, "on_healing_effect")
	var _error_on_healed = player.connect("healed", self, "on_player_healed")
	var _error_lifesteal_effect = RunData.connect("lifesteal_effect", player, "on_lifesteal_effect")
	connect_visual_effects(player)

	for stat_next_wave in RunData.effects["stats_next_wave"]:
		TempStats.add_stat(stat_next_wave[0], stat_next_wave[1])
	TempStats.emit_updated()

	RunData.effects["stats_next_wave"] = []

	check_half_health_stats(player.current_stats.health, player.max_stats.health)


func _on_EntitySpawner_enemy_spawned(enemy:Enemy)->void :
	var _error_died = enemy.connect("died", self, "_on_enemy_died")
	var _error_took_damage = enemy.connect("took_damage", _screenshaker, "_on_unit_took_damage")
	var _error_stats_boost = enemy.connect("stats_boosted", _effects_manager, "on_enemy_stats_boost")
	var _error_heal = enemy.connect("healed", _effects_manager, "on_enemy_healed")
	var _error_speed_removed = enemy.connect("speed_removed", _effects_manager, "on_enemy_speed_removed")
	var _error_state_changed = enemy.connect("state_changed", _floating_text_manager, "on_enemy_state_changed")
	connect_visual_effects(enemy)
	RunData.current_living_enemies += 1

	if _update_stats_on_enemies_changed and _update_stats_on_enemies_changed_timer.is_stopped():
		reload_stats()
		_update_stats_on_enemies_changed_timer.start()


func _on_EntitySpawner_neutral_spawned(neutral:Neutral)->void :
	RunData.current_living_trees += 1
	var _error_died = neutral.connect("died", self, "_on_neutral_died")
	var _error_took_damage = neutral.connect("took_damage", _screenshaker, "_on_unit_took_damage")
	connect_visual_effects(neutral)

	if _update_stats_on_neutrals_changed:
		reload_stats()


func _on_EntitySpawner_structure_spawned(structure:Structure)->void :
	var _error_fruit = structure.connect("wanted_to_spawn_fruit", self, "on_structure_wanted_to_spawn_fruit")


func on_structure_wanted_to_spawn_fruit(pos:Vector2)->void :
	var consumable_to_spawn = ItemService.get_consumable_to_drop(0)
	var dist = rand_range(100, 150)
	var consumable = consumable_scene.instance()
	consumable.consumable_data = consumable_to_spawn
	consumable.global_position = pos
	_consumables_container.call_deferred("add_child", consumable)
	consumable.call_deferred("set_texture", consumable_to_spawn.icon)
	var _error = consumable.connect("picked_up", self, "on_consumable_picked_up")
	consumable.push_back_destination = Vector2(rand_range(pos.x - dist, pos.x + dist), rand_range(pos.y - dist, pos.y + dist))
	_consumables.push_back(consumable)


func _on_HarvestingTimer_timeout()->void :
	if RunData.current_wave > RunData.nb_of_waves:
		var val = ceil(Utils.get_stat("stat_harvesting") * (RunData.ENDLESS_HARVESTING_DECREASE / 100.0))
		RunData.remove_stat("stat_harvesting", val)
	else :
		var val = ceil(Utils.get_stat("stat_harvesting") * (RunData.effects["harvesting_growth"] / 100.0))

		var has_crown = false
		var crown_value = 0

		for item in RunData.items:
			if item.my_id == "item_crown":
				has_crown = true
				crown_value = item.effects[0].value
				break

		if has_crown:
			RunData.tracked_item_effects["item_crown"] += (Utils.get_stat("stat_harvesting") * (crown_value / 100.0)) as int

		if val > 0:
			RunData.add_stat("stat_harvesting", val)
	RunData.emit_stats_updated()


func on_player_healed(_unit:Unit, _value:int)->void :
	var dmg_taken = handle_stat_damages(RunData.effects["dmg_when_heal"])

	
	RunData.tracked_item_effects["character_lich"] += dmg_taken[1]


func handle_stat_damages(stat_damages:Array)->Array:
	var total_dmg_to_deal = 0
	var dmg_taken = [0, 0]

	if stat_damages.size() <= 0 or _entity_spawner.get_all_enemies().size() <= 0:
		return dmg_taken

	for stat_dmg in stat_damages:

		if randf() >= stat_dmg[2] / 100.0:
			continue

		var dmg_from_stat = max(1, (stat_dmg[1] / 100.0) * Utils.get_stat(stat_dmg[0]))
		var dmg = RunData.get_dmg(dmg_from_stat) as int
		total_dmg_to_deal += dmg

	var other_enemy = Utils.get_rand_element(_entity_spawner.get_all_enemies())

	if total_dmg_to_deal <= 0 or other_enemy == null or not is_instance_valid(other_enemy):
		return dmg_taken

	dmg_taken = other_enemy.take_damage(total_dmg_to_deal)

	return dmg_taken


func check_half_health_stats(current_val:int, max_val:int)->void :
	if current_val < (max_val / 2.0) and not _player_is_under_half_health:
		_player_is_under_half_health = true
		for stat in RunData.effects["stats_below_half_health"]:
			TempStats.add_stat(stat[0], stat[1])
			RunData.emit_signal("stat_added", stat[0], stat[1], 0.0)
	elif current_val >= max_val / 2.0 and _player_is_under_half_health:
		_player_is_under_half_health = false
		for stat in RunData.effects["stats_below_half_health"]:
			TempStats.remove_stat(stat[0], stat[1])
			RunData.emit_signal("stat_removed", stat[0], stat[1], 0.0)
	TempStats.emit_updated()


func on_player_health_updated(current_val:int, max_val:int)->void :

	check_half_health_stats(current_val, max_val)

	if ProgressData.settings.hp_bar_on_character:
		if not _player_life_bar.visible:
			_player_life_bar.show()

		if current_val == max_val:
			_player_life_bar.hide()

		_player_life_bar.update_value(current_val, max_val)
	elif _player_life_bar.visible:
		_player_life_bar.hide()


func on_gold_changed(gold:int)->void :
	if _update_stats_on_gold_changed:
		if (gold / 30.0) as int != _last_gold_amount_used_to_reload_stats:
			reload_stats()
			_last_gold_amount_used_to_reload_stats = (gold / 30.0) as int


func on_chal_popup()->void :
	_is_chal_ui_displayed = true


func on_chal_popout()->void :
	_is_chal_ui_displayed = false


func _on_TestButton_pressed()->void :
	var _error = get_tree().change_scene(MenuData.editor_scene)
