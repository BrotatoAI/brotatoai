extends Boss


func on_state_changed(new_state:int)->void :
	.on_state_changed(new_state)

	if new_state == 0:
		reset_stats(0.0, - 0.25)
	elif new_state == 1:
		reset_stats(0.0, - 0.4)
