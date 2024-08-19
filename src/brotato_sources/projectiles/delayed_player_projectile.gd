class_name DelayedPlayerProjectile
extends PlayerProjectile


var delay = rand_range(0.0, 3.0)


func _ready()->void :
	_hitbox.disable()


func _physics_process(delta:float)->void :

	delay -= Utils.physics_one(delta)

	if delay <= 0 and _hitbox.is_disabled():
		_hitbox.enable()
