class_name Neutral
extends Unit

export (int) var number_of_hits_before_dying = 8

var current_number_of_hits = 0


func init(zone_min_pos:Vector2, zone_max_pos:Vector2, player_ref:Node2D = null, entity_spawner_ref = null)->void :
	.init(zone_min_pos, zone_max_pos, player_ref, entity_spawner_ref)
	init_current_stats()


func on_hurt()->void :
	.on_hurt()

	current_number_of_hits += 1

	if current_number_of_hits >= number_of_hits_before_dying and not dead:
		die()
	elif (RunData.effects["one_shot_trees"] > 0 or DebugService.one_shot_enemies) and not dead:
		die()


func die(_knockback_vector:Vector2 = Vector2.ZERO, _cleaning_up:bool = false)->void :
	.die()
	ProgressData.add_data("trees_killed")
	ChallengeService.check_counted_challenges()
