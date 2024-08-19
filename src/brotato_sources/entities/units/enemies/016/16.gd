extends Enemy

export (PackedScene) var enemy_to_spawn


func die(knockback_vector:Vector2 = Vector2.ZERO, p_cleaning_up:bool = false)->void :
	.die(knockback_vector, p_cleaning_up)

	if p_cleaning_up:
		return 

	for i in 3:
		emit_signal("wanted_to_spawn_an_enemy", enemy_to_spawn, ZoneService.get_rand_pos_in_area(Vector2(global_position.x, global_position.y), 200))

