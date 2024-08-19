extends Enemy

export (Resource) var heal_sound
export (float) var heal = 100.0
export (float) var heal_increase_each_wave = 10.0

onready var _boost_zone = $BoostZone


func _on_BoostZone_body_entered(body:Node)->void :
	if not dead and body.current_stats.health < body.max_stats.health:
		SoundManager2D.play(heal_sound, global_position, - 10, 0.2)
		body.current_stats.health = min(body.current_stats.health + (heal + (RunData.current_wave - 1) * heal_increase_each_wave), body.max_stats.health)
		body.emit_signal("healed", body)
		emit_signal("healed", self)


func die(knockback_vector:Vector2 = Vector2.ZERO, p_cleaning_up:bool = false)->void :
	.die(knockback_vector, p_cleaning_up)
	_boost_zone.queue_free()
