extends Boss


func on_state_changed(new_state:int)->void :
	.on_state_changed(new_state)
	if new_state == 0 and $Pivot != null and is_instance_valid($Pivot):
		$Pivot.rotation_speed *= 1.25


func die(knockback_vector:Vector2 = Vector2.ZERO, p_cleaning_up:bool = false)->void :
	.die(knockback_vector, p_cleaning_up)
	$Pivot.queue_free()
