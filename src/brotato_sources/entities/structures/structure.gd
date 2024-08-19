class_name Structure
extends Entity

signal wanted_to_spawn_fruit(pos)

var base_stats:Resource
var stats:Resource
var effects:Array = []


func set_data(data:Resource)->void :
	base_stats = data.stats
	effects = data.effects
	reload_data()


func reload_data()->void :
	stats = WeaponService.init_ranged_stats(base_stats, "", [], effects, true)

	for effect in effects:
		if effect is BurningEffect:
			var base_burning = BurningData.new(
				effect.burning_data.chance, 
				max(1.0, effect.burning_data.damage + WeaponService.get_scaling_stats_value(stats.scaling_stats)) as int, 
				effect.burning_data.duration, 
				effect.burning_data.spread, 
				effect.burning_data.type
			)

			stats.burning_data = WeaponService.init_burning_data(base_burning, false, true)
