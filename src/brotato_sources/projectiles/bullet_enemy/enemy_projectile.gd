class_name EnemyProjectile
extends Projectile


func _ready()->void :
	if ProgressData.settings.projectile_highlighting:
		$Sprite.material = Utils.projectile_outline_shadermat


func set_damage(value:int, accuracy:float = 1.0, crit_chance:float = 0.0, crit_damage:float = 0.0, burning_data:BurningData = BurningData.new(), is_healing:bool = false)->void :
	var new_value = int(value * (RunData.current_run_accessibility_settings.damage + (Utils.get_stat("enemy_damage") / 100.0)))

	var val_with_endless_factor = round(new_value * (1.0 + RunData.get_endless_factor()))

	.set_damage(val_with_endless_factor, accuracy, crit_chance, crit_damage, burning_data, is_healing)


func _on_Hitbox_hit_something(_thing_hit:Node, _damage_dealt:int)->void :
	set_to_be_destroyed()
