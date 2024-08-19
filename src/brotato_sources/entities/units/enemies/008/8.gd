extends Enemy

export (float) var proj_chance = 0.25


func _on_Hurtbox_area_entered(hitbox:Area2D)->void :
	._on_Hurtbox_area_entered(hitbox)

	if hitbox.from != null and is_instance_valid(hitbox.from):

		if hitbox.from is RangedWeapon and Utils.get_chance_success(proj_chance):
			_attack_behavior.shoot()
