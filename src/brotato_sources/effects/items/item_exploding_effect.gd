class_name ItemExplodingEffect
extends ExplodingEffect

export (Resource) var stats
export (String) var tracking_text


static func get_id()->String:
	return "item_exploding"


func apply()->void :
	RunData.effects[key].push_back(self)


func unapply()->void :
	RunData.effects[key].erase(self)


func get_args()->Array:
	var current_stats = WeaponService.init_base_stats(stats, "", [], [ExplodingEffect.new()])
	var scaling_text = WeaponService.get_scaling_stats_icons(stats.scaling_stats)
	return [str(chance * 100.0), str(current_stats.damage), scaling_text]


func serialize()->Dictionary:
	var serialized = .serialize()

	if stats != null:
		serialized.stats = stats.serialize()

	return serialized


func deserialize_and_merge(serialized:Dictionary)->void :
	.deserialize_and_merge(serialized)

	if serialized.has("stats"):
		if serialized.stats.has("type"):
			var exploding_stats = WeaponStats.new()

			if serialized.stats.type == "ranged":
				exploding_stats = RangedWeaponStats.new()
			elif serialized.stats.type == "melee":
				exploding_stats = MeleeWeaponStats.new()

			exploding_stats.deserialize_and_merge(serialized.stats)
			stats = exploding_stats
