class_name GainStatForEveryStatEffect
extends Effect

export(int) var nb_stat_scaled = 0
export(String) var stat_scaled = ""


static func get_id() -> String:
	return "gain_stat_for_every_stat"


func apply() -> void:
	var perm_only = text_key.to_upper() == "EFFECT_GAIN_STAT_FOR_EVERY_PERM_STAT"
	RunData.effects["stat_links"].push_back([key, value, stat_scaled, nb_stat_scaled, perm_only])


func unapply() -> void:
	var perm_only = text_key.to_upper() == "EFFECT_GAIN_STAT_FOR_EVERY_PERM_STAT"
	RunData.effects["stat_links"].erase([key, value, stat_scaled, nb_stat_scaled, perm_only])


func get_args() -> Array:
	var actual_nb_scaled = 0
	var key_arg = key
	var perm_only = text_key.to_upper() == "EFFECT_GAIN_STAT_FOR_EVERY_PERM_STAT"

	if stat_scaled == "materials":
		actual_nb_scaled = RunData.gold
	elif stat_scaled == "structure":
		actual_nb_scaled = RunData.effects["structures"].size()
	elif stat_scaled == "living_enemy":
		actual_nb_scaled = RunData.current_living_enemies
	elif stat_scaled == "common_item":
		actual_nb_scaled = RunData.get_nb_different_items_of_tier(Tier.COMMON)
	elif stat_scaled == "legendary_item":
		actual_nb_scaled = RunData.get_nb_different_items_of_tier(Tier.LEGENDARY)
	elif stat_scaled.begins_with("item_"):
		actual_nb_scaled = RunData.get_nb_item(stat_scaled, false)
	elif stat_scaled == "living_tree":
		actual_nb_scaled = RunData.current_living_trees
	elif perm_only:
		actual_nb_scaled = RunData.get_stat(stat_scaled)
	else:
		actual_nb_scaled = RunData.get_stat(stat_scaled) + TempStats.get_stat(stat_scaled)

	var bonus = floor(value * (actual_nb_scaled / nb_stat_scaled))

	if key_arg == "number_of_enemies":
		key_arg = "pct_number_of_enemies"

	return [str(value), tr(key_arg.to_upper()), str(nb_stat_scaled), tr(stat_scaled.to_upper()), str(bonus)]


func serialize() -> Dictionary:
	var serialized = .serialize()

	serialized.nb_stat_scaled = nb_stat_scaled
	serialized.stat_scaled = stat_scaled

	return serialized


func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)

	nb_stat_scaled = serialized.nb_stat_scaled as int
	stat_scaled = serialized.stat_scaled
