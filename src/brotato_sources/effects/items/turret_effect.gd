class_name TurretEffect
extends StructureEffect

export (float) var shooting_animation_speed = 1.0
export (bool) var is_burning = false
export (bool) var is_spawning = false


static func get_id()->String:
	return "turret"


func get_args()->Array:
	if is_burning:
		
		var burning_ticks = effects[0].burning_data.duration

		var scaling_stats_value = WeaponService.get_scaling_stats_value(stats.scaling_stats)
		var scaling_stats_names = WeaponService.get_scaling_stats_icons(stats.scaling_stats)

		var burning_dmg = max(1.0, round(effects[0].burning_data.damage + scaling_stats_value))

		return [str(burning_dmg), str(burning_ticks), scaling_stats_names]
	elif is_spawning:

		var spawn_cd = stats.cooldown

		if RunData.effects["structures_cooldown_reduction"].size() > 0:
			spawn_cd = Utils.apply_cooldown_reduction(spawn_cd, RunData.effects["structures_cooldown_reduction"])

		return [str(int(spawn_cd / 60.0))]
	else :
		var scaling_stats_names = WeaponService.get_scaling_stats_icons(stats.scaling_stats)
		var init_stats = WeaponService.init_ranged_stats(stats, "", [], effects, true)

		return [str(init_stats.damage), scaling_stats_names, str(init_stats.nb_projectiles), str(init_stats.bounce)]


func serialize()->Dictionary:
	var serialized = .serialize()

	serialized.shooting_animation_speed = shooting_animation_speed
	serialized.is_burning = is_burning

	return serialized


func deserialize_and_merge(serialized:Dictionary)->void :
	.deserialize_and_merge(serialized)

	is_burning = serialized.is_burning
