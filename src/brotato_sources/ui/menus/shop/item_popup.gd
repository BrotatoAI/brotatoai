class_name ItemPopup
extends Control

signal item_discard_button_pressed(item_data)
signal item_cancel_button_pressed(item_data)
signal item_combine_button_pressed(item_data)

const BASE_ELEMENT_SIZE = 96
const DIST = 10

var buttons_active = true
var _new_element = null
var _item_displayed:ItemParentData

onready var _panel = $HBoxContainer / ItemPanelUI
onready var _combine_button = $HBoxContainer / ItemPanelUI / MarginContainer / VBoxContainer / CombineButton
onready var _discard_button = $HBoxContainer / ItemPanelUI / MarginContainer / VBoxContainer / DiscardButton
onready var _cancel_button = $HBoxContainer / ItemPanelUI / MarginContainer / VBoxContainer / CancelButton
onready var _synergy_container = $HBoxContainer / SynergyContainer
onready var _last_wave_info_container = $"%LastWaveInfoContainer"


func set_buttons_active(value:bool)->void :
	if not value:
		_discard_button.hide()
		_cancel_button.hide()
		buttons_active = false


func display_element(element:InventoryElement)->void :
	_last_wave_info_container.hide()
	_item_displayed = element.item
	_panel.set_data(element.item)
	set_synergies_text(element.item)
	_new_element = element

	_discard_button.text = tr("MENU_RECYCLE") + " (+" + str(ItemService.get_recycling_value(RunData.current_wave, element.item.value, element.item is WeaponData)) + ")"

	if element.item is WeaponData and element.item.dmg_dealt_last_wave != 0:
		_last_wave_info_container.display(Text.text("DAMAGE_DEALT_LAST_WAVE", [str(element.item.dmg_dealt_last_wave)], [Sign.POSITIVE]))

	if element.item is WeaponData and buttons_active:
		_combine_button.show()
		if not RunData.can_combine(element.item):
			_combine_button.hide()
		_discard_button.show()
		_cancel_button.show()
	else :
		_combine_button.hide()
		_discard_button.hide()
		_cancel_button.hide()

	var stylebox_color = _panel.get_stylebox("panel").duplicate()
	ItemService.change_panel_stylebox_from_tier(stylebox_color, element.item.tier)
	_panel.add_stylebox_override("panel", stylebox_color)

	show()


func set_synergies_text(item_data:ItemParentData)->void :
	_synergy_container.set_synergies_text(item_data)


func _input(event:InputEvent)->void :
	if event.is_action_pressed("ui_cancel"):
		emit_signal("item_cancel_button_pressed", _item_displayed)


func _process(_delta:float)->void :
	if _new_element != null:
		rect_global_position = get_pos_from(_new_element)
		_new_element = null


func focus()->void :
	_combine_button.focus_mode = FOCUS_ALL
	_discard_button.focus_mode = FOCUS_ALL
	_cancel_button.focus_mode = FOCUS_ALL
	_cancel_button.grab_focus()


func hide_element()->void :
	hide()
	_discard_button.focus_mode = FOCUS_NONE
	_cancel_button.focus_mode = FOCUS_NONE
	_combine_button.focus_mode = FOCUS_NONE


func get_pos_from(new_element:InventoryElement)->Vector2:
	if new_element == null:return Vector2(0, 0)
	var element_pos:Vector2 = new_element.rect_global_position
	var pos: = element_pos

	if element_pos.x > Utils.project_width / 2:
		pos.x = pos.x - _panel.rect_size.x + BASE_ELEMENT_SIZE
	else :
		pos.x = pos.x

	if element_pos.y > Utils.project_height / 2:
		pos.y = min(pos.y, Utils.project_height) - _panel.rect_size.y - DIST
	else :
		pos.y = pos.y + BASE_ELEMENT_SIZE + DIST

	return pos


func _on_DiscardButton_pressed()->void :
	emit_signal("item_discard_button_pressed", _item_displayed)


func _on_CancelButton_pressed()->void :
	emit_signal("item_cancel_button_pressed", _item_displayed)


func _on_CombineButton_pressed()->void :
	emit_signal("item_combine_button_pressed", _item_displayed)
