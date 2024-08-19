extends Boss

onready var _spawning_shooting_behavior = $SpawningShootingBehavior


func _ready()->void :
	_spawning_shooting_behavior.init(self)


func shoot()->void :
	.shoot()

	if _current_state == 0:
		_spawning_shooting_behavior.shoot()
