class_name EffectsManager
extends Node2D

export (PackedScene) var heal_particles
export (PackedScene) var stats_boost_particles
export (PackedScene) var speed_removed_particles
export (PackedScene) var hit_particles
export (PackedScene) var directional_hit_particles
export (PackedScene) var hit_effect
export (PackedScene) var gold_pickup_particles

const MAX_GRAPHICAL_EFFECTS = 100
var current_graphical_effects:int = 0

var _cleaning_up:bool = false


func on_enemy_healed(unit:Unit)->void :
	play_boost_particles(unit.global_position, heal_particles)


func on_enemy_stats_boost(unit:Unit)->void :
	play_boost_particles(unit.global_position, stats_boost_particles)


func on_enemy_speed_removed(unit:Unit)->void :
	play_boost_particles(unit.global_position, speed_removed_particles)


func on_gold_picked_up(gold:Gold)->void :
	if not _cleaning_up:
		play_gold_pickup_effect(gold.global_position)


func _on_unit_took_damage(unit:Unit, value:int, knockback_direction:Vector2, _knockback_amount:float, _is_crit:bool, is_miss:bool, _is_dodge:bool, _is_protected:bool, effect_scale:float, _hit_type:int)->void :

	if value <= 0 or not ProgressData.settings.visual_effects:
		return 

	var effect_distance:float = Utils.get_effect_distance(unit)
	play_hit_particles(unit.global_position + (knockback_direction * effect_distance), knockback_direction, effect_scale / 2.0 if is_miss else effect_scale)
	play_hit_effect(unit.global_position + (knockback_direction * effect_distance), knockback_direction, effect_scale / 2.0 if is_miss else effect_scale)


func play_boost_particles(pos:Vector2, boost_particles:PackedScene)->void :
	if boost_particles != null:
		play(boost_particles, pos, Vector2.ZERO)


func play_hit_particles(effect_pos:Vector2, direction:Vector2, effect_scale:float)->void :
	if hit_particles != null:
		play(hit_particles, effect_pos, direction, true, effect_scale)


func play_directional_hit_particles(effect_pos:Vector2, direction:Vector2, effect_scale:float)->void :
	if directional_hit_particles != null:
		play(directional_hit_particles, effect_pos, direction, true, effect_scale)


func play_gold_pickup_effect(effect_pos:Vector2)->void :
	if gold_pickup_particles != null:
		play(gold_pickup_particles, effect_pos, Vector2.ZERO)


func play_hit_effect(effect_pos:Vector2, _direction:Vector2, effect_scale:float)->void :
	if hit_effect != null and randf() < effect_scale:
		play(hit_effect, effect_pos, Vector2(rand_range( - 1, 1), rand_range( - 1, 1)), false, effect_scale)


func play(scene:PackedScene, effect_pos:Vector2, direction:Vector2, is_particle:bool = true, effect_scale:float = 1.0, is_graphical_only:bool = true)->void :

	if effect_scale <= 0 or (is_graphical_only and current_graphical_effects > MAX_GRAPHICAL_EFFECTS):
		return 

	var instance = Utils.instance_scene_on_main(scene, effect_pos)

	if is_graphical_only:
		current_graphical_effects += 1
		instance.connect("destroyed", self, "on_graphical_effect_destroyed")

	if is_particle:
		instance.amount = max(1, instance.amount * effect_scale)
		instance.emitting = true

	instance.global_position = effect_pos
	instance.rotation = direction.angle() - PI


func on_graphical_effect_destroyed()->void :
	current_graphical_effects -= 1


func clean_up_room()->void :
	_cleaning_up = true
