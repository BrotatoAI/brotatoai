extends AIController2D

var _entity_spawner: EntitySpawner
var _wave_timer: WaveTimer

var move_action : Vector2 = Vector2.ZERO

func _ready():
	_entity_spawner = $"/root/Main/EntitySpawner"
	_wave_timer = $"/root/Main/WaveTimer"

func get_obs() -> Dictionary:
	_player = $"/root/Main"._player
	
	var max_enemies = 50
	
	var obs = [];
	
	for i in range(max_enemies):
		if _entity_spawner.enemies.size() > i:
			var enemy = _entity_spawner.enemies[i]
			if (is_instance_valid(enemy) and !enemy.dead):
				obs.push_front(enemy.position.x)
				obs.push_front(enemy.position.y)
			else:
				obs.push_back(-1)
				obs.push_back(-1)
		else:
			obs.push_back(-1)
			obs.push_back(-1)

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
