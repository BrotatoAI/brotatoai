extends Enemy

export (Resource) var speed_boost_sound
export (int) var max_speed_boosts = 10
export (int) var speed_on_boost = 45

var nb_times_boosted = 0


func _on_BoostTimer_timeout()->void :
	if nb_times_boosted < max_speed_boosts and not dead:
		bonus_speed += speed_on_boost * RunData.current_run_accessibility_settings.speed
		nb_times_boosted += 1
		emit_signal("stats_boosted", self)
		SoundManager2D.play(speed_boost_sound, global_position, - 10.0, 0.2)


func _on_hit_something(thing_hit:Node, damage_dealt:int)->void :
	._on_hit_something(thing_hit, damage_dealt)
	nb_times_boosted = 0
	bonus_speed = 0
