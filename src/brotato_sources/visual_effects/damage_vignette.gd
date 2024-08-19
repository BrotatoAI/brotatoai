extends ColorRect

var cur_val: = 1.0
var max_val: = 1.0
var reset_timer:float = 0
var reset: = false


func _physics_process(delta:float)->void :
	if not reset:
		reset_timer -= Utils.physics_one(delta)

		if reset_timer <= 0:
			update_from_hp(cur_val as int, max_val as int)
			reset = true


func update_from_hp(hp:int = - 1, max_hp:int = - 1)->void :

	if hp != - 1:
		cur_val = hp as float

	if max_hp != - 1:
		max_val = max_hp as float

	if not ProgressData.settings.darken_screen and material.get_shader_param("multiplier") != 0.8:
		material.set_shader_param("multiplier", 0.8)
	elif ProgressData.settings.darken_screen:
		material.set_shader_param("multiplier", get_val())


func get_val()->float:
	return clamp(cur_val / max_val, 0.3, 0.8)
