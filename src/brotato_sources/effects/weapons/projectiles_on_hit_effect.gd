class_name ProjectilesOnHitEffect
extends NullEffect

export (Resource) var weapon_stats
export (bool) var auto_target_enemy = false


static func get_id()->String:
	return "weapon_projectiles_on_hit"


func get_args()->Array:
	var current_stats = WeaponService.init_ranged_stats(weapon_stats)
	var scaling_text = WeaponService.get_scaling_stats_icons(weapon_stats.scaling_stats)
	return [str(value), str(current_stats.damage), str(current_stats.bounce + 1), scaling_text]


func serialize()->Dictionary:
	var serialized = .serialize()

	if weapon_stats != null:
		serialized.weapon_stats = weapon_stats.serialize()

	serialized.auto_target_enemy = auto_target_enemy

	return serialized


func deserialize_and_merge(serialized:Dictionary)->void :
	.deserialize_and_merge(serialized)

	if serialized.has("weapon_stats"):
		var data = RangedWeaponStats.new()
		data.deserialize_and_merge(serialized.weapon_stats)
		weapon_stats = data

	auto_target_enemy = serialized.auto_target_enemy
