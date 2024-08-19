class_name Garden
extends Turret


func shoot()->void :
	SoundManager2D.play(Utils.get_rand_element(stats.shooting_sounds), global_position, stats.sound_db_mod, 0.2)
	emit_signal("wanted_to_spawn_fruit", global_position)
