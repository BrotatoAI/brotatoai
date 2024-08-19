class_name ZoneUI
extends PanelContainer

signal choose_button_pressed(zone)
signal decrease_difficulty_pressed(zone)
signal increase_difficulty_pressed(zone)

export (Resource) var icon_difficulty
export (Resource) var icon_difficulty_unselected

var my_id:int = 0

onready var _choose_button = $MarginContainer / VBoxContainer / ChooseButton
onready var _title = $MarginContainer / VBoxContainer / Title
onready var _icon = $MarginContainer / VBoxContainer / Icon
onready var _difficulty_container = $MarginContainer / VBoxContainer / DifficultyContainer
onready var _difficulty_icons_container = $MarginContainer / VBoxContainer / DifficultyContainer / DifficultyIconsContainer


func set_zone_data(zone_data:ZoneData)->void :
	my_id = zone_data.my_id
	_title.text = zone_data.name
	_icon.texture = zone_data.icon

	init_difficulty()


func init_difficulty()->void :
	if ProgressData.settings.zones[my_id].max_difficulty > 0:
		_difficulty_container.show()
	else :
		_difficulty_container.hide()

	update_difficulty_icons()


func update_difficulty_icons()->void :
	var max_diff = ProgressData.settings.zones[my_id].max_difficulty
	var selected_diff = ProgressData.settings.zones[my_id].selected_difficulty
	var icons = _difficulty_icons_container.get_children()

	for i in icons.size():
		if i < selected_diff:
			icons[i].texture = icon_difficulty
		elif i < max_diff:
			icons[i].texture = icon_difficulty_unselected
		else :
			icons[i].hide()


func focus()->void :
	_choose_button.grab_focus()


func _on_ChooseButton_pressed()->void :
	emit_signal("choose_button_pressed", self)


func _on_DecreaseDifficultyButton_pressed()->void :
	if ProgressData.settings.zones[my_id].selected_difficulty > 0:
		ProgressData.settings.zones[my_id].selected_difficulty -= 1
	update_difficulty_icons()
	emit_signal("decrease_difficulty_pressed", self)


func _on_IncreaseDifficultyButton_pressed()->void :
	if ProgressData.settings.zones[my_id].selected_difficulty < ProgressData.settings.zones[my_id].max_difficulty:
		ProgressData.settings.zones[my_id].selected_difficulty += 1
	update_difficulty_icons()
	emit_signal("increase_difficulty_pressed", self)
