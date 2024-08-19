class_name StructureEffect
extends Effect

export(int) var spawn_cooldown = -1
export(PackedScene) var scene = null
export(Resource) var stats = null
export(Array, Resource) var effects = []
export(int) var spawn_around_player = -1
export(bool) var can_be_grouped = true


static func get_id() -> String:
	return "structure"


func apply() -> void:
	RunData.effects["structures"].push_back(self)


func unapply() -> void:
	RunData.effects["structures"].erase(self)


func get_args() -> Array:
	var spawn_cd = spawn_cooldown

	if RunData.effects["structures_cooldown_reduction"].size() > 0:
		spawn_cd = Utils.apply_cooldown_reduction(spawn_cd, RunData.effects["structures_cooldown_reduction"])

	var scaling_stats_names = WeaponService.get_scaling_stats_icons(stats.scaling_stats)
	var init_stats = WeaponService.init_ranged_stats(stats, "", [], effects, true)

	return [str(value), str(spawn_cd), str(init_stats.damage), scaling_stats_names]


func serialize() -> Dictionary:
	var serialized = .serialize()

	serialized.spawn_cooldown = spawn_cooldown
	serialized.scene = scene.resource_path
	serialized.stats = stats.serialize()

	serialized.effects = []
	for effect in effects:
		serialized.effects.push_back(effect.serialize())

	serialized.spawn_around_player = spawn_around_player
	serialized.can_be_grouped = can_be_grouped

	return serialized


func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)

	spawn_cooldown = serialized.spawn_cooldown as int
	scene = load(serialized.scene)

	var struct_stats = RangedWeaponStats.new()
	struct_stats.deserialize_and_merge(serialized.stats)
	stats = struct_stats

	effects = []
	for serialized_effect in serialized.effects:
		for effect in ItemService.effects:
			if effect.get_id() == serialized_effect.effect_id:
				var instance = effect.new()
				instance.deserialize_and_merge(serialized_effect)
				effects.push_back(instance)
				break

	if serialized.has("spawn_around_player"):
		spawn_around_player = serialized.spawn_around_player

	if serialized.has("can_be_grouped"):
		can_be_grouped = serialized.can_be_grouped
