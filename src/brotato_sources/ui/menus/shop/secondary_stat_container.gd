class_name SecondaryStatContainer
extends HBoxContainer

signal focused(button, title, value)
signal unfocused()
signal hovered(button, title, value)
signal unhovered()

export (String) var key
export (String) var custom_text_key
export (bool) var reverse = false

onready var _label = $Label
onready var _value = $Value


func _ready()->void :
	update_stat()


func update_stat()->void :
	var stat_value = Utils.get_stat(key.to_lower())
	var value_text = str(stat_value as int)

	_label.text = custom_text_key if custom_text_key != "" else key
	_value.text = value_text

	if (stat_value > 0 and not reverse) or (stat_value < 0 and reverse):
		_label.modulate = Color.green
		_value.modulate = Color.green
	elif (stat_value < 0 and not reverse) or (stat_value > 0 and reverse):
		_label.modulate = Color.red
		_value.modulate = Color.red
	else :
		_label.modulate = Color.white
		_value.modulate = Color.white
