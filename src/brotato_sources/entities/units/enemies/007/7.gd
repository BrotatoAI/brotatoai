extends Enemy

export (Resource) var boost_sound
export (float) var hp_boost = 1.5
export (float) var damage_boost = 0.25
export (float) var speed_boost = 0.5

var enemies_in_zone: = []

onready var _boost_zone = $BoostZone
onready var _boost_timer = $BoostTimer


func _on_BoostZone_body_entered(body:Node)->void :
	if not dead and body.can_be_boosted:
		enemies_in_zone.push_back(body)


func die(knockback_vector:Vector2 = Vector2.ZERO, p_cleaning_up:bool = false)->void :
	.die(knockback_vector, p_cleaning_up)
	_boost_zone.queue_free()


func _on_BoostTimer_timeout()->void :
	var sound_played = false

	if enemies_in_zone.size() >= 1:
		var enemy = Utils.get_rand_element(enemies_in_zone)
		if is_instance_valid(enemy) and enemy.can_be_boosted:
			enemy.update_stats(hp_boost, damage_boost, speed_boost)

			enemy.emit_signal("stats_boosted", enemy)
			emit_signal("stats_boosted", self)

			if not sound_played:
				SoundManager2D.play(boost_sound, global_position, 0.0, 0.2)
				sound_played = true

			enemy.set_boosted()

	_boost_timer.wait_time = 4


func _on_BoostZone_body_exited(body:Node)->void :
	enemies_in_zone.erase(body)
