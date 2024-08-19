extends Enemy

var current_projectiles_cooldown = 0.0

onready var _charging_shoot_projectiles_behavior = $ChargingShootProjectilesBehavior


func _ready()->void :
	_charging_shoot_projectiles_behavior.init(self)


func _physics_process(delta:float)->void :
	current_projectiles_cooldown = max(0.0, current_projectiles_cooldown - Utils.physics_one(delta))

	if _move_locked and current_projectiles_cooldown <= 0.0 and not dead:
		current_projectiles_cooldown = _charging_shoot_projectiles_behavior.cooldown
		_charging_shoot_projectiles_behavior.shoot()
