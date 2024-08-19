class_name LevelContainer
extends HBoxContainer

signal focused(button)
signal unfocused()
signal hovered(button)
signal unhovered()

onready var _icon = $Icon
onready var _label = $Label
onready var _value = $Value


func _ready()->void :
	var _levelled_up_error = RunData.connect("levelled_up", self, "update_info")
	update_info()


func disable_focus_except_mouse()->void :
	_label.focus_mode = FOCUS_CLICK


func set_neighbour_right(node:Node)->void :
	_label.focus_neighbour_right = node.get_path()


func enable_focus()->void :
	_label.focus_mode = FOCUS_ALL


func disable_focus()->void :
	_label.focus_mode = FOCUS_NONE


func update_info()->void :
	_value.text = str(RunData.current_level)


func _on_Label_focus_entered()->void :
	emit_signal("focused", self)


func _on_Label_focus_exited()->void :
	emit_signal("unfocused")


func _on_Label_mouse_entered()->void :
	emit_signal("hovered", self)


func _on_Label_mouse_exited()->void :
	emit_signal("unhovered")
