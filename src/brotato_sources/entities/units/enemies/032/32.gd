extends Boss

var CHARGING_PROJECTILES_COOLDOWN = 15.0
var current_projectiles_cooldown = 0.0

onready var _charging_shoot_projectiles_behavior = $ChargingShootProjectilesBehavior


func _ready()->void :
	_charging_shoot_projectiles_behavior.init(self)


func _physics_process(delta:float)->void :
	current_projectiles_cooldown = max(0.0, current_projectiles_cooldown - Utils.physics_one(delta))

	if _move_locked and current_projectiles_cooldown <= 0.0 and not dead:
		current_projectiles_cooldown = CHARGING_PROJECTILES_COOLDOWN
		_charging_shoot_projectiles_behavior.shoot()
