extends Node

signal game_lost_focus
signal game_regained_focus

var using_gamepad = false
var hide_mouse: = true
var echo_delay: = 0.2
var _timer:Timer
var _released = false


func _ready()->void :
	pause_mode = Node.PAUSE_MODE_PROCESS
	_timer = Timer.new()
	add_child(_timer)
	_timer.one_shot = true
	_timer.wait_time = echo_delay
	var _error = _timer.connect("timeout", self, "on_timer_timeout")

	var _input_connect = Input.connect("joy_connection_changed", self, "on_joy_connection_changed")


func _input(event:InputEvent)->void :
	var is_gamepad_input = (event is InputEventJoypadButton or event is InputEventJoypadMotion)
	var is_keyboard_input = (event is InputEventKey)

	if hide_mouse and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE and (is_gamepad_input or is_keyboard_input):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	elif event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if (
		event is InputEventJoypadButton
		 or (event is InputEventJoypadMotion and abs(event.axis_value) > 0.25)
	):
		using_gamepad = true
	elif is_keyboard_input:
		using_gamepad = false

	if not _timer.is_stopped() and event is InputEventJoypadButton:
		_released = true


func on_joy_connection_changed(_device:int, connected:bool)->void :
	if not connected:
		emit_signal("game_lost_focus")


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		if ProgressData.settings.mute_on_focus_lost:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(0.0))
		emit_signal("game_lost_focus")
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(ProgressData.settings.volume.master ))
		emit_signal("game_regained_focus")


func _process(_delta:float)->void :
	if not _timer.is_stopped():
		return 

	if is_d_pad_key_pressed():
		_released = false
		_timer.start()


func is_d_pad_key_pressed()->bool:
	for i in range(12, 16):
		if Input.is_joy_button_pressed(0, i):
			return true

	return false


func on_timer_timeout()->void :

	if _released:
		return 

	var action = null

	if Input.is_joy_button_pressed(0, 12):
		action = "ui_up"
	elif Input.is_joy_button_pressed(0, 13):
		action = "ui_down"
	elif Input.is_joy_button_pressed(0, 14):
		action = "ui_left"
	elif Input.is_joy_button_pressed(0, 15):
		action = "ui_right"
	else :
		return 

	var a = InputEventAction.new()
	a.action = action
	a.pressed = true
	Input.parse_input_event(a)
