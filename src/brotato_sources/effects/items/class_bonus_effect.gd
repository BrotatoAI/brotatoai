class_name ClassBonusEffect
extends Effect

export(String) var set_id = ""
export(String) var stat_displayed_name = "stat_damage"
export(String) var stat_name = "damage"


static func get_id() -> String:
	return "class_bonus"


func apply() -> void:
	RunData.effects["weapon_class_bonus"].push_back([set_id, stat_name, value])


func unapply() -> void:
	RunData.effects["weapon_class_bonus"].erase([set_id, stat_name, value])


func get_args() -> Array:
	var set = ItemService.get_set(set_id)
	return [str(value), tr(stat_displayed_name.to_upper()), tr(set.name)]
