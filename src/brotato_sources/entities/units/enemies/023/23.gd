extends Enemy


func _on_AttackBehavior_wanted_to_spawn_an_enemy(enemy_scene:PackedScene, at_position:Vector2)->void :
	._on_AttackBehavior_wanted_to_spawn_an_enemy(enemy_scene, at_position)
	die()
