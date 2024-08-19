class_name ZonePanel
extends PanelContainer

onready var _label = $MarginContainer / VBoxContainer / Label
onready var _icon = $MarginContainer / VBoxContainer / Icon


func set_data(data:ZoneData)->void :
	_label = data.name
	_icon = data.icon
