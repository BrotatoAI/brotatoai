class_name MyMenuButton
extends MyMenuButtonParent


func _ready()->void :
	var _error_focus = connect("focus_entered", self, "on_focus_entered")
	var _error_press = connect("pressed", self, "on_pressed")
	var _error_mouse = connect("mouse_entered", self, "on_mouse_entered")
