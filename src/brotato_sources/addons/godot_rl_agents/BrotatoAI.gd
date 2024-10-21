extends AIController2D

var _consumables: Node2D
var _entity_spawner: EntitySpawner
var _wave_timer: WaveTimer
var _wave_duration: int

var _dead_enemy_count = 0

var _max_visible_consumables = 10

var move_action : Vector2 = Vector2.ZERO
var aim_action : Vector2 = Vector2.ZERO


func _ready():
	_consumables = $"/root/Main/Consumables"
	_entity_spawner = $"/root/Main/EntitySpawner"
	_wave_timer = $"/root/Main/WaveTimer"
	_wave_duration = ZoneService.get_wave_data(RunData.current_zone, RunData.current_wave).wave_duration
	
func get_obs() -> Dictionary:
	_player = $"/root/Main"._player

	var obs = []
	
	_get_enemy_positions(obs)
	
	_get_loot_positions(obs)
	
	# Player position
	obs.push_front(_player.position.x)
	obs.push_front(_player.position.y)
	
	# Map limit
	var _min_zone = ZoneService.current_zone_min_position
	var _max_zone = ZoneService.current_zone_max_position
	obs.push_front(_min_zone.x)
	obs.push_front(_min_zone.y)
	obs.push_front(_max_zone.x)
	obs.push_front(_max_zone.y)
	
	# Player health
	obs.push_front(_player.current_stats.health)

#	print('obs: ', obs, 'size: ', obs.size())

	return {"obs":obs}
	
func _get_enemy_positions(obs: Array) -> void:
	_dead_enemy_count = 0
	var alive_enemy_count = 0
	
	var starting_size = obs.size()
	
	var enemy_spwaner_size = _entity_spawner.enemies.size()
	var max_enemies = _entity_spawner._current_wave_data.max_enemies
	
	for enemy in _entity_spawner.enemies:
		if (is_instance_valid(enemy) and !enemy.dead):
			alive_enemy_count += 1
			obs.push_back(enemy.position.x)
			obs.push_back(enemy.position.y)
		else:
			_dead_enemy_count += 1

	_fill_with_negative_vector(obs, starting_size + max_enemies * 2)
			
func _get_loot_positions(obs: Array) -> void:
	
	var nb_consumable_found = 0
	
	var starting_size = obs.size()
	
	var positions = Dictionary()
	var consumables = []

	for child in _consumables.get_children():
		print('child ', child)
		var consumable := child as Consumable
		if is_instance_valid(consumable) and consumable.consumable_data.name  == 'CONSUMABLE_FRUIT':
			positions[consumable.position.distance_to(_player.position)] = consumable

	var keys = positions.keys()
	if keys.size() > 0:
		var sorted_keys = keys.sort()
	
		for key in keys:
			print('key ', key)

#		for key in sorted_keys:
#			if consumables.size() < _max_visible_consumables:
#				var consumable = consumables[key]
#				obs.push_back(consumable.position.x)
#				obs.push_back(consumable.position.y)
			
	_fill_with_negative_vector(obs, (starting_size / 2) + _max_visible_consumables)
	
func _fill_with_negative_vector(obs: Array, expected_size: int) -> void:
	if obs.size() < expected_size: 
		for i in range(expected_size - obs.size()):
			obs.push_back(-1.0)

func get_reward() -> float:
	var main = $"/root/Main"
	_player = main._player
	var won = main._is_run_won
#	print('reward', _entity_spawner, _wave_timer, _player)

	var health = _player.current_stats.health * 10
	var elapsed_time = (_wave_duration - _wave_timer.time_left) * 5
	var reward = health + _dead_enemy_count + round(elapsed_time)
	
	if _player.dead:
		return reward - 1000.0
		
	if won:
		return reward + 1000.0
	
#	print('reward: ', reward)
	
	return reward
	
func get_action_space() -> Dictionary:
	var action_space = {
		"move_action" : {
			"size": 2,
			"action_type": "continuous"
		}
	}
	if ProgressData.settings.manual_aim:
		action_space["aim_action"] = {
				"size": 2,
				"action_type": "continuous"
			}
		
	return action_space

func set_action(action) -> void:
	_player = $"/root/Main"._player
	
	var move_x = clamp(action["move_action"][0], -1.0, 1.0)
	var move_y = clamp(action["move_action"][1], -1.0, 1.0)
	move_action = Vector2(move_x, move_y)

	if ProgressData.settings.manual_aim:
		var aim_x = clamp(action["aim_action"][0], -1.0, 1.0)
		var aim_y = clamp(action["aim_action"][1], -1.0, 1.0)
		aim_action = Vector2(aim_x + _player.position.x, move_y + _player.position.y)
	
func reset():
	print('reset agent')

	n_steps = 0
	needs_reset = false
	
	RunData.reset(true)
	TempStats.reset()
	ProgressData.reset_run_state()
	
	MusicManager.play(0)
	
	var _error = get_tree().change_scene(MenuData.game_scene)
	
	if _error != OK:
		print(_error)
	
	queue_free()
