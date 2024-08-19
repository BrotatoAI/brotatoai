class_name StatGainsModificationEffect
extends Effect

export(String) var stat_displayed = ""
export(Array, String) var stats_modified = []


static func get_id() -> String:
	return "stat_gains_modifications"


func apply() -> void:
	for stat in stats_modified:
		RunData.effects["gain_" + stat] += value


func unapply() -> void:
	for stat in stats_modified:
		RunData.effects["gain_" + stat] -= value


func get_args() -> Array:
	return [tr(stat_displayed.to_upper()), str(abs(value))]


func serialize() -> Dictionary:
	var serialized = .serialize()

	serialized.stat_displayed = stat_displayed
	serialized.stats_modified = stats_modified

	return serialized


func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)

	stat_displayed = serialized.stat_displayed
	stats_modified = serialized.stats_modified
