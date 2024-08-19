class_name FocusManager
extends Node

signal focus_lost
signal element_focused(element)
signal element_pressed(element)

var initialized = false

var _element_hovered:InventoryElement = null
var _element_focused:InventoryElement = null
var _element_pressed:InventoryElement = null

var _item_popup:ItemPopup
var _stat_popup:StatPopup
var _weapons_container:InventoryContainer
var _items_container:InventoryContainer
var _stats_container:StatsContainer
var _progress_container:InventoryContainer


func init(
	item_popup:ItemPopup, 
	stat_popup:StatPopup, 
	weapons_container:InventoryContainer = null, 
	items_container:InventoryContainer = null, 
	stats_container:StatsContainer = null, 
	progress_container:InventoryContainer = null, 
	display_item_popup_buttons:bool = true
	)->void :

	initialized = true

	if item_popup:
		_item_popup = item_popup
		_item_popup.set_buttons_active(display_item_popup_buttons)

	_stat_popup = stat_popup
	_weapons_container = weapons_container
	_items_container = items_container
	_stats_container = stats_container
	_progress_container = progress_container

	if weapons_container:
		connect_inventory_signals(weapons_container._elements)

	if items_container:
		connect_inventory_signals(items_container._elements)

	if progress_container:
		connect_inventory_signals(progress_container._elements)

	if stats_container:
		var _err1 = stats_container.connect("stat_focused", stat_popup, "display_stat")
		var _err2 = stats_container.connect("stat_unfocused", stat_popup, "hide_element")
		var _err3 = stats_container.connect("stat_hovered", stat_popup, "display_stat")
		var _err4 = stats_container.connect("stat_unhovered", stat_popup, "hide_element")


func connect_inventory_signals(inventory:Inventory)->void :
	var _error_focus_lost = inventory.connect("focus_lost", self, "on_focus_lost")
	var _error_hover = inventory.connect("element_hovered", self, "on_element_hovered")
	var _error_unhover = inventory.connect("element_unhovered", self, "on_element_unhovered")
	var _error_focus = inventory.connect("element_focused", self, "on_element_focused")
	var _error_unfocus = inventory.connect("element_unfocused", self, "on_element_unfocused")
	var _error_pressed = inventory.connect("element_pressed", self, "on_element_pressed")


func reset_focus()->void :
	_element_hovered = null
	_element_pressed = null
	_element_focused = null

	if _item_popup:
		_item_popup.hide_element()


func on_focus_lost()->void :
	emit_signal("focus_lost")


func on_element_hovered(element:InventoryElement)->void :
	if _element_pressed != null:
		return 
	element.grab_focus()
	_element_hovered = element
	_element_focused = element
	if _item_popup:
		_item_popup.display_element(element)


func on_element_unhovered(element:InventoryElement)->void :
	if _element_pressed != null:
		return 

	if _element_hovered == element:
		_element_hovered = null
		on_element_unfocused(element)


func on_element_focused(element:InventoryElement)->void :
	emit_signal("element_focused", element)
	if _element_pressed != null:
		return 

	_element_focused = element
	if _item_popup:
		_item_popup.display_element(element)


func on_element_unfocused(element:InventoryElement)->void :
	if _element_pressed != null:
		return 

	if _element_focused == element:
		_element_focused = null
		if _item_popup:
			_item_popup.hide_element()


func on_element_pressed(element:InventoryElement)->void :
	emit_signal("element_pressed", element)
	if element.item is WeaponData and _item_popup and _item_popup.buttons_active:
		_element_hovered = element
		_element_focused = element
		_element_pressed = element
		_item_popup.display_element(element)
		_item_popup.focus()
