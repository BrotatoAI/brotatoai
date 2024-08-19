class_name SynergyPanel
extends PanelContainer

const MAX_PANEL_WIDTH = 450

onready var _synergy_effects = $MarginContainer / VBoxContainer / SynergyEffects
onready var _synergy_name = $MarginContainer / VBoxContainer / SynergyName


func set_data(set:SetData)->void :
	var nb = min(set.set_bonuses.size() + 1, RunData.active_sets[set.my_id]) as int if RunData.active_sets.has(set.my_id) else 0

	_synergy_name.text = tr(set.name)

	_synergy_effects.bbcode_text = ""

	var new_text = ""
	var max_width = 0

	for i in set.set_bonuses.size():

		var is_applied = i + 2 == nb
		var col_a = "" if is_applied else "[color=" + Utils.GRAY_COLOR_STR + "]"
		var col_b = "" if is_applied else "[/color]"
		var new_line = ""

		new_line += "(" + str(i + 2) + ") "
		for j in set.set_bonuses[i].size():
			new_line += set.set_bonuses[i][j].get_text(is_applied)
			if j != set.set_bonuses[i].size() - 1:
				new_line += ", "

		new_text += col_a + new_line

		if not is_applied:
			var text_size = _synergy_effects.get_font("normal_font").get_string_size(new_line).x + 50

			if text_size > max_width:
				max_width = text_size

		if i != set.set_bonuses.size() - 1:
			new_text += "\n"

		new_text += col_b

	_synergy_effects.bbcode_text = new_text

	rect_min_size = Vector2(max_width, 0)
