class_name StatPopup
extends BasePopup

onready var _icon = $PanelContainer / MarginContainer / HBoxContainer / Icon
onready var _title = $PanelContainer / MarginContainer / HBoxContainer / VBoxContainer / Title
onready var _description = $PanelContainer / MarginContainer / HBoxContainer / VBoxContainer / Description


func display_stat(button:Node, title:String, value:int)->void :
	_icon.texture = ItemService.get_stat_icon(title.to_lower())
	_title.text = title

	var stat_sign = "POS_" if value >= 0 else "NEG_"
	var key = "INFO_" + stat_sign + title.to_upper()

	if title == "STAT_ARMOR":
		_description.text = Text.text(key, [str(abs(round((1.0 - RunData.get_armor_coef(value)) * 100.0)))])
	elif title == "STAT_HARVESTING":
		if value >= 0:key += "_LIMITED"
		_description.text = Text.text(key, [str(abs(value)), str(RunData.effects["harvesting_growth"]), str(RunData.nb_of_waves), str(RunData.ENDLESS_HARVESTING_DECREASE)])
	elif title == "STAT_LIFESTEAL":
		_description.text = Text.text(key, [str(abs(value)), "10"])
	elif title == "STAT_HP_REGENERATION":
		var val = RunData.get_hp_regeneration_timer(value)
		var amount = 2 if RunData.effects["double_hp_regen"] else 1
		var amount_per_sec = amount / val
		_description.text = Text.text(key, [str(amount), str(stepify(val, 0.01)), str(stepify(amount_per_sec, 0.01))])
	elif title == "STAT_DODGE":
		_description.text = Text.text(key, [str(abs(value)), str(RunData.effects["dodge_cap"]) + "%"])
	else :
		_description.text = Text.text(key, [str(abs(value))])

	element_from = button
	show()


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
		pos.x = pos.x

	if element_pos.y > Utils.project_height / 2:
		pos.y = pos.y - _panel.rect_size.y - DIST
	else :
		pos.y = pos.y + 40

	return pos
