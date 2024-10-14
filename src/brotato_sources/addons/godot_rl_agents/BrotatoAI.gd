extends AIController2D

var _consumables: Node2D
var _entity_spawner: EntitySpawner
var _wave_timer: WaveTimer
var _wave_duration: int

var _dead_enemy_count = 0

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
	
	get_enemy_positions(obs)
	
	get_loot_positions(obs)
	
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
	
func get_enemy_positions(obs) -> void:
	var alive_enemy_count = 0
	
	
	var enemy_spwaner_size = _entity_spawner.enemies.size()
	var max_enemies = _entity_spawner._current_wave_data.max_enemies
	
	for i in range(enemy_spwaner_size):

		var enemy = _entity_spawner.enemies[i]
		if (is_instance_valid(enemy) and !enemy.dead):
			alive_enemy_count += 1
			obs.push_front(enemy.position.x)
			obs.push_front(enemy.position.y)
		else:
			_dead_enemy_count += 1
			obs.push_back(-1)
			obs.push_back(-1)
		
		if alive_enemy_count == max_enemies:
			break

	if alive_enemy_count < max_enemies:
		for i in range(max_enemies - alive_enemy_count):
			obs.push_back(-1)
			obs.push_back(-1)
			
func get_loot_positions(obs) -> void:
	_consumables.get_children()

func get_reward() -> float:
	_player = $"/root/Main"._player
#	print('reward', _entity_spawner, _wave_timer, _player)

	var elapsed_time = _wave_duration - _wave_timer.time_left
	var reward = RunData.gold + _dead_enemy_count + elapsed_time
	
	if (_player.dead):
		return -1000.0
	
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
	
	if _error > 0:
		print(_error)
	
	queue_free()
