class_name ItemPanelUI
extends PanelContainer

signal mouse_hovered_category
signal mouse_exited_category

var item_data:ItemParentData

onready var _item_description = $MarginContainer / VBoxContainer / ItemDescription


func set_data(p_item_data:ItemParentData)->void :
	item_data = p_item_data
	_item_description.set_item(p_item_data)

	var stylebox_color = get_stylebox("panel").duplicate()
	ItemService.change_panel_stylebox_from_tier(stylebox_color, p_item_data.tier)
	add_stylebox_override("panel", stylebox_color)


func _on_ItemDescription_mouse_hovered_category()->void :
	emit_signal("mouse_hovered_category")


func _on_ItemDescription_mouse_exited_category()->void :
	emit_signal("mouse_exited_category")
