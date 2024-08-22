extends AIController2D

var _entity_spawner: EntitySpawner
var _wave_timer: WaveTimer

var move_action : Vector2 = Vector2.ZERO

func _ready():
	_entity_spawner = $"/root/Main/EntitySpawner"
	_wave_timer = $"/root/Main/WaveTimer"

func get_obs() -> Dictionary:
	_player = $"/root/Main"._player
		
	var _min_zone = ZoneService.current_zone_min_position
	var _max_zone = ZoneService.current_zone_max_position
	
	var obs = [];
	var max_enemies = 50
	
	var enemy_spwaner_size = _entity_spawner.enemies.size()
	var alive_enemy_count = 0
	
	for i in range(enemy_spwaner_size):
		
		var enemy = _entity_spawner.enemies[i]
		if (is_instance_valid(enemy) and !enemy.dead):
			alive_enemy_count += 1
			obs.push_front(enemy.position.x)
			obs.push_front(enemy.position.y)
		else:
			obs.push_back(-1)
			obs.push_back(-1)
			
	for i in range(max_enemies - alive_enemy_count):
		obs.push_back(-1)
		obs.push_back(-1)
	
	obs.push_front(_player.position.x)
	obs.push_front(_player.position.y)
	obs.push_front(_min_zone.x)
	obs.push_front(_min_zone.y)
	obs.push_front(_max_zone.x)
	obs.push_front(_max_zone.y)
	obs.push_front(_player.current_stats.health)

	# print_debug('obs', obs, obs.size())

	return {"obs":obs}

func get_reward() -> float:
	# print_debug('reward', _entity_spawner, _wave_timer, _player)
	return 120 - _wave_timer.wait_time
	
func get_action_space() -> Dictionary:
	return {
		"move_action" : {
			"size": 2,
			"action_type": "continuous"
		},
	}

func set_action(action) -> void:
	# print_debug('action', action)
	var move_x = clamp(action["move_action"][0], -1.0, 1.0)
	var move_y = clamp(action["move_action"][1], -1.0, 1.0)
	move_action = Vector2(move_x, move_y)
