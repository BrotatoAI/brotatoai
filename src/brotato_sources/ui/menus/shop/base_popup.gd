class_name BasePopup
extends Control

const BASE_ELEMENT_SIZE = 300
const DIST = 10

onready var _panel = $PanelContainer

var element_from = null


func _process(_delta:float)->void :
	if element_from != null:
		rect_global_position = get_pos_from(element_from)
		element_from = null


func hide_element()->void :
	hide()


func get_pos_from(new_element:Node)->Vector2:
	var element_pos:Vector2 = new_element.rect_global_position
	var pos: = element_pos

	if element_pos.x > Utils.project_width / 2:
		pos.x = pos.x - _panel.rect_size.x
	else :
		pos.x = pos.x + new_element.rect_size.x

	if element_pos.y > Utils.project_height / 2:
		pos.y = pos.y - _panel.rect_size.y - DIST
	else :
		pos.y = pos.y

	return pos
