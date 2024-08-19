class_name UpgradeUI
extends PanelContainer

signal choose_button_pressed(upgrade)

var upgrade_data:UpgradeData

onready var _button = $MarginContainer / VBoxContainer / ChooseButton
onready var _upgrade_description = $MarginContainer / VBoxContainer / UpgradeDescription


func focus()->void :
	_button.grab_focus()


func set_upgrade(p_upgrade_data:UpgradeData)->void :
	upgrade_data = p_upgrade_data
	_upgrade_description.set_item(p_upgrade_data)

	var stylebox_color = get_stylebox("panel").duplicate()
	ItemService.change_panel_stylebox_from_tier(stylebox_color, p_upgrade_data.tier)
	add_stylebox_override("panel", stylebox_color)


func _on_ChooseButton_pressed()->void :
	emit_signal("choose_button_pressed", upgrade_data)
