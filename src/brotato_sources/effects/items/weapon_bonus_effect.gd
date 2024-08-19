class_name WeaponBonusEffect
extends Effect

export(String) var weapon_name
export(String) var weapon_id
export(String) var stat_displayed_name = "stat_damage"
export(String) var stat_name = "damage"


static func get_id() -> String:
	return "weapon_bonus"


func apply() -> void:
	RunData.effects["weapon_bonus"].push_back([weapon_id, stat_name, value])


func unapply() -> void:
	RunData.effects["weapon_bonus"].erase([weapon_id, stat_name, value])


func get_args() -> Array:
	return [str(value), tr(stat_displayed_name.to_upper()), tr(weapon_name.to_upper())]


func serialize() -> Dictionary:
	var serialized = .serialize()

	serialized.weapon_name = weapon_name
	serialized.weapon_id = weapon_id
	serialized.stat_displayed_name = stat_displayed_name
	serialized.stat_name = stat_name

	return serialized


func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)

	weapon_name = serialized.weapon_name
	weapon_id = serialized.weapon_id
	stat_displayed_name = serialized.stat_displayed_name
	stat_name = serialized.stat_name
