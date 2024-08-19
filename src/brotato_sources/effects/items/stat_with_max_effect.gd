class_name StatWithMaxEffect
extends Effect

export(int) var max_value = 0


static func get_id() -> String:
	return "stat_with_max"


func apply() -> void:
	RunData.effects[custom_key].push_back([key, value, max_value])


func unapply() -> void:
	RunData.effects[custom_key].erase([key, value, max_value])


func get_args() -> Array:
	return [str(value), tr(key.to_upper()), str(max_value)]


func serialize() -> Dictionary:
	var serialized = .serialize()

	serialized.max_value = max_value

	return serialized


func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)

	max_value = serialized.max_value
