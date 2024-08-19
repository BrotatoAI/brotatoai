class_name StatContainer
extends HBoxContainer

signal focused(button, title, value)
signal unfocused()
signal hovered(button, title, value)
signal unhovered()

export (String) var key

onready var _icon = $Icon
onready var _label = $Label
onready var _value = $Value


func _ready()->void :
	update_stat()


func disable_focus_except_mouse()->void :
	_label.focus_mode = FOCUS_CLICK


func set_neighbour_right(node:Node)->void :
	_label.focus_neighbour_right = node.get_path()


func enable_focus()->void :
	_label.focus_mode = FOCUS_ALL


func disable_focus()->void :
	_label.focus_mode = FOCUS_NONE


func update_stat()->void :
	var stat_value = Utils.get_stat(key.to_lower())
	var value_text = str(stat_value as int)

	_icon.texture = ItemService.get_stat_small_icon(key.to_lower())
	_label.text = key

	if key.to_lower() == "stat_dodge" and stat_value > RunData.effects["dodge_cap"]:
		value_text += " | " + str(RunData.effects["dodge_cap"] as int)
	elif key.to_lower() == "stat_max_hp" and RunData.effects["hp_cap"] < 9999:
		value_text += " | " + str(RunData.effects["hp_cap"] as int)
	elif key.to_lower() == "stat_speed" and RunData.effects["speed_cap"] < 9999:
		value_text += " | " + str(RunData.effects["speed_cap"] as int)

	_value.text = value_text

	if stat_value > 0:
		_label.modulate = Color.green
		_value.modulate = Color.green
	elif stat_value < 0:
		_label.modulate = Color.red
		_value.modulate = Color.red
	else :
		_label.modulate = Color.white
		_value.modulate = Color.white


func _on_Label_focus_entered()->void :
	emit_signal("focused", self, _label.text, Utils.get_stat(key.to_lower()))


func _on_Label_focus_exited()->void :
	emit_signal("unfocused")


func _on_Label_mouse_entered()->void :
	emit_signal("hovered", self, _label.text, Utils.get_stat(key.to_lower()))


func _on_Label_mouse_exited()->void :
	emit_signal("unhovered")
