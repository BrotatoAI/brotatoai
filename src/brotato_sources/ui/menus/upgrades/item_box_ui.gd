class_name ItemBoxUI
extends Control

signal item_box_processed
signal item_take_button_pressed(item_data)
signal item_discard_button_pressed(item_data)

var item_data:ItemParentData = null
var taken:bool = false

onready var _panel_container = $MarginContainer / HBoxContainer / VBoxContainer / PanelContainer
onready var _item_description = $MarginContainer / HBoxContainer / VBoxContainer / PanelContainer / MarginContainer / ItemDescription
onready var _take_button = $MarginContainer / HBoxContainer / VBoxContainer / HBoxContainer / TakeButton
onready var _discard_button = $MarginContainer / HBoxContainer / VBoxContainer / HBoxContainer / DiscardButton
onready var _stats_container = $MarginContainer / HBoxContainer / StatsContainer
onready var _focus_manager = $FocusManager
onready var _stat_popup = $StatPopup


func _ready()->void :
	_focus_manager.init(null, _stat_popup, null, null, _stats_container, null, false)


func focus()->void :
	_take_button.grab_focus()


func set_item_data(p_item_data:ItemParentData)->void :
	taken = false
	_stats_container.update_stats()
	item_data = p_item_data
	_item_description.set_item(p_item_data)
	_discard_button.text = tr("MENU_RECYCLE") + " (+" + str(ItemService.get_recycling_value(RunData.current_wave, p_item_data.value, p_item_data is WeaponData)) + ")"
	show()
	_take_button.grab_focus()

	var stylebox_color = _panel_container.get_stylebox("panel").duplicate()
	ItemService.change_panel_stylebox_from_tier(stylebox_color, p_item_data.tier)
	_panel_container.add_stylebox_override("panel", stylebox_color)


func _on_TakeButton_pressed()->void :

	if taken:return 

	taken = true
	emit_signal("item_take_button_pressed", item_data)

	LinkedStats.reset()
	_stats_container.update_stats()
	hide()
	emit_signal("item_box_processed")


func _on_DiscardButton_pressed()->void :
	emit_signal("item_discard_button_pressed", item_data)
	hide()
	emit_signal("item_box_processed")
