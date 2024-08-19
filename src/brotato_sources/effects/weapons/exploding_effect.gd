class_name ExplodingEffect
extends NullEffect

export (float, 0.0, 1.0, 0.01) var chance: = 1.0
export (PackedScene) var explosion_scene
export (float) var scale: = 1.0
export (int) var base_smoke_amount: = 40
export (int) var sound_db_mod: = - 10


static func get_id()->String:
	return "weapon_exploding"


func get_args()->Array:
	return [str(round(chance * 100.0))]


func serialize()->Dictionary:
	var serialized = .serialize()

	serialized.chance = chance

	if explosion_scene != null:
		serialized.explosion_scene = explosion_scene.resource_path

	serialized.scale = scale
	serialized.base_smoke_amount = base_smoke_amount
	serialized.sound_db_mod = sound_db_mod

	return serialized


func deserialize_and_merge(serialized:Dictionary)->void :
	.deserialize_and_merge(serialized)

	chance = serialized.chance
	if serialized.has("explosion_scene"):
		explosion_scene = load(serialized.explosion_scene)
	scale = serialized.scale
	base_smoke_amount = serialized.base_smoke_amount as int
	sound_db_mod = serialized.sound_db_mod as int
