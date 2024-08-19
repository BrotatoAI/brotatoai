class_name ShopItem
extends Control

signal buy_button_pressed(shop_item)
signal shop_item_deactivated(shop_item)
signal shop_item_activated(shop_item)
signal shop_item_focused(shop_item)
signal shop_item_unfocused(shop_item)
signal mouse_hovered_category(shop_item)
signal mouse_exited_category(shop_item)

var item_data:ItemParentData
var active: = true
var value: = 1
var locked = false

var wave_value: = 1

onready var _panel = $PanelContainer
onready var _button = $PanelContainer / MarginContainer / VBoxContainer / BuyButton
onready var _item_description = $PanelContainer / MarginContainer / VBoxContainer / ItemDescription
onready var _lock_button = $HBoxContainer / LockButton
onready var _lock_icon = $HBoxContainer / LockIcon


func disable_focus()->void :
	_button.focus_mode = FOCUS_NONE


func enable_focus()->void :
	if active:
		_button.focus_mode = FOCUS_ALL


func disable_lock_focus()->void :
	_lock_button.focus_mode = FOCUS_NONE


func enable_lock_focus()->void :
	if active:
		_lock_button.focus_mode = FOCUS_ALL


func focus()->void :
	_button.grab_focus()


func deactivate()->void :
	modulate = Color(1, 1, 1, 0)
	_button.disable()
	_lock_button.disable()
	_lock_button.pressed = false
	_lock_icon.hide()
	locked = false
	active = false
	emit_signal("shop_item_deactivated", self)


func activate()->void :
	modulate = Color(1, 1, 1, 1)
	_button.reinitialize_colors()
	_button.activate()
	_lock_button.activate()
	active = true
	emit_signal("shop_item_activated", self)


func set_shop_item(p_item_data:ItemParentData, p_wave_value:int = RunData.current_wave)->void :
	activate()
	item_data = p_item_data
	_item_description.set_item(p_item_data)
	wave_value = p_wave_value
	value = ItemService.get_value(wave_value, p_item_data.value, true, p_item_data is WeaponData, p_item_data.my_id)

	var icon = ItemService.material_icon.get_data()
	var texture = ImageTexture.new()
	var color = Utils.GOLD_COLOR

	if RunData.effects["hp_shop"]:
		value = ceil(value / 20.0) as int
		icon = ItemService.get_stat_icon("stat_max_hp").get_data()
		icon.resize(64, 64)
		color = Color.white

	if RunData.current_character != null and RunData.current_character.my_id == "character_renegade" and item_data is ItemData and item_data.tier == Tier.COMMON:

		var already_has_item = false

		for item in RunData.items:
			if item.my_id == item_data.my_id:
				already_has_item = true
				break

		if not already_has_item:
			icon = RunData.current_character.icon.get_data()
			icon.resize(52, 52)
			texture = ImageTexture.new()
			texture.create_from_image(icon)
			color = Color.white

	texture.create_from_image(icon)
	_button.set_icon(texture, color)
	_button.set_value(value)

	if not locked:
		var stylebox_color = _panel.get_stylebox("panel").duplicate()
		ItemService.change_panel_stylebox_from_tier(stylebox_color, p_item_data.tier)
		_panel.add_stylebox_override("panel", stylebox_color)


func update_color()->void :
	_button.set_color_from_currency()


func lock_visually()->void :

	if not item_data:return 

	locked = true
	_lock_button.set_pressed_no_signal(true)
	_lock_icon.show()
	var stylebox_color = _panel.get_stylebox("panel").duplicate()
	stylebox_color.border_color = Color.white
	_panel.add_stylebox_override("panel", stylebox_color)


func unlock_visually()->void :

	if not item_data:return 
	locked = false
	_lock_button.set_pressed_no_signal(false)
	_lock_icon.hide()
	var stylebox_color = _panel.get_stylebox("panel").duplicate()
	ItemService.change_panel_stylebox_from_tier(stylebox_color, item_data.tier)
	_panel.add_stylebox_override("panel", stylebox_color)


func _on_LockButton_toggled(button_pressed:bool)->void :
	change_lock_status(button_pressed)


func change_lock_status(button_pressed:bool)->void :
	if button_pressed:
		lock_visually()
		RunData.locked_shop_items.push_back([item_data, wave_value])
	else :
		unlock_visually()
		for locked_item in RunData.locked_shop_items:
			if locked_item[0].my_id == item_data.my_id:
				RunData.locked_shop_items.erase(locked_item)


func get_category_text_pos()->Vector2:
	return _item_description._category.rect_global_position


func _on_BuyButton_focus_entered()->void :
	emit_signal("shop_item_focused", self)


func _on_BuyButton_focus_exited()->void :
	emit_signal("shop_item_unfocused", self)


func _on_BuyButton_pressed()->void :
	emit_signal("buy_button_pressed", self)


func _on_ItemDescription_mouse_hovered_category()->void :
	if active:
		emit_signal("mouse_hovered_category", self)


func _on_ItemDescription_mouse_exited_category()->void :
	emit_signal("mouse_exited_category", self)


func _on_BuyButton_mouse_exited()->void :
	emit_signal("shop_item_unfocused", self)


func _on_BuyButton_mouse_entered()->void :
	emit_signal("shop_item_focused", self)
