class_name MyMenuButtonParent
extends Button

export (Resource) var focus_entered_sound = preload("res://ui/sounds/button_focus.wav")
export (Resource) var pressed_sound = preload("res://ui/sounds/button_press.wav")
export (float) var pitch_variation = 0.2
export (bool) var grab_focus_with_mouse = true

var _delay_timer:Timer
var _is_delay_active: = false

var active: = true


func _ready()->void :
	_delay_timer = Timer.new()
	_delay_timer.wait_time = 0.05
	_delay_timer.one_shot = true
	var _delay = _delay_timer.connect("timeout", self, "_on_DelayTimer_timeout")
	add_child(_delay_timer)


func on_focus_entered()->void :
	if active:
		SoundManager.play(focus_entered_sound, 0, pitch_variation)


func on_pressed()->void :
	if active and is_inside_tree():
		_delay_timer.start()
		disabled = true
		_is_delay_active = true
		SoundManager.play(pressed_sound, 0, pitch_variation)


func on_mouse_entered()->void :
	if active:
		if grab_focus_with_mouse:
			if focus_mode == FOCUS_NONE:
				focus_mode = FOCUS_ALL
			grab_focus()
		SoundManager.play(focus_entered_sound, 0, pitch_variation)


func disable()->void :
	disabled = true
	focus_mode = FOCUS_NONE
	active = false
	_is_delay_active = false


func activate()->void :
	disabled = false
	focus_mode = FOCUS_ALL
	active = true


func _on_DelayTimer_timeout()->void :
	if _is_delay_active:
		disabled = false
		_is_delay_active = false
