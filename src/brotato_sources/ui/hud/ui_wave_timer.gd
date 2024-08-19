extends Label

var wave_timer:Timer
var is_run_lost = false

var change_color_on_half_wave: = false
var color_changed: = false


func _ready()->void :
	if RunData.effects["convert_stats_half_wave"].size() > 0:
		change_color_on_half_wave = true


func _process(_delta:float)->void :
	if wave_timer != null and is_instance_valid(wave_timer) and not is_run_lost:
		text = str(ceil(wave_timer.time_left))

		if change_color_on_half_wave and not color_changed and wave_timer.time_left <= wave_timer.wait_time / 2.0:
			modulate = Color.deepskyblue
			color_changed = true
