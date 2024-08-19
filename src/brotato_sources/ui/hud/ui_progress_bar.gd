extends TextureProgress

export (Color) var progress_color: = Color.white
export (Dictionary) var effect_colors: = {}

var _initialized = false

onready var _non_flash_color: = progress_color
onready var _flash_timer = $Timer


func _ready()->void :
	tint_progress = _non_flash_color


func update_value(current_val:int, max_val:int)->void :
	var new_value = clamp((float(current_val) / float(max_val)) * 100, 0.0, float(max_val) * 100)

	var is_healing = new_value >= value
	set_value(new_value)

	if _initialized and not is_healing:
		tint_progress = Color.white
		_flash_timer.start()
	else :
		_initialized = true


func update_color_from_effects(effects:Dictionary)->void :
	_non_flash_color = progress_color
	for effect_key in effect_colors:
		if effects[effect_key] > 0:
			_non_flash_color = effect_colors[effect_key]
			break
	if _flash_timer.time_left == 0:
		tint_progress = _non_flash_color


func _on_Timer_timeout()->void :
	tint_progress = _non_flash_color
