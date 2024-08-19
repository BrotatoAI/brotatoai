class_name ConvertStatEffect
extends Effect

export(float) var pct_converted = 1.0
export(String) var to_stat = "stat_max_hp"
export(int) var to_value = 1


static func get_id() -> String:
	return "convert_stat"


func apply() -> void:
	RunData.effects[custom_key].push_back(self)


func unapply() -> void:
	RunData.effects[custom_key].erase(self)


func get_args() -> Array:
	return [str(pct_converted), tr(key.to_upper()), tr(to_stat.to_upper()), str(value), str(to_value)]


func serialize() -> Dictionary:
	var serialized = .serialize()

	serialized.pct_converted = pct_converted
	serialized.to_stat = to_stat
	serialized.to_value = to_value

	return serialized


func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)

	pct_converted = serialized.pct_converted
	to_stat = serialized.to_stat
	to_value = serialized.to_value as int
