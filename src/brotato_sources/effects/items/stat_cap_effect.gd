class_name StatCapEffect
extends Effect

export(String) var set_cap_to_current_stat = ""


static func get_id() -> String:
	return "stat_cap"


func apply() -> void:
	if set_cap_to_current_stat != "":
		RunData.effects[key] = Utils.get_stat(set_cap_to_current_stat)
	else:
		RunData.effects[key] = value


func unapply() -> void:
	RunData.effects[key] = 999999


func get_args() -> Array:
	return [str(RunData.effects[key] if RunData.effects[key] < 9999 else Utils.get_stat(set_cap_to_current_stat) as int)]


func serialize() -> Dictionary:
	var serialized = .serialize()

	serialized.set_cap_to_current_stat = set_cap_to_current_stat

	return serialized


func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)

	set_cap_to_current_stat = serialized.set_cap_to_current_stat
