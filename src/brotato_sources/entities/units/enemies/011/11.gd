extends Boss


func on_state_changed(new_state:int)->void :
	.on_state_changed(new_state)

	if new_state == 1:
		reset_stats(0.0, 1.5)
