class_name Enemy
extends Unit

signal healed(enemy)
signal stats_boosted(enemy)
signal wanted_to_spawn_an_enemy(enemy_scene, at_position)
signal state_changed(enemy)

export (Resource) var outline_mat
export (bool) var can_be_boosted: = true

var is_boosted: = false
var _idle_playback_speed = rand_range(1, 3)
var _current_attack_cd:float
var _current_attack_behavior:AttackBehavior

onready var _attack_behavior = $AttackBehavior
onready var _hitbox = $Hitbox


func _ready()->void :
	_current_attack_behavior = _attack_behavior
	_animation_player.playback_speed = _idle_playback_speed
	_hitbox.from = self


func init(zone_min_pos:Vector2, zone_max_pos:Vector2, player_ref:Node2D = null, entity_spawner_ref = null)->void :
	.init(zone_min_pos, zone_max_pos, player_ref, entity_spawner_ref)

	init_current_stats()

	if DebugService.nullify_enemy_speed:
		stats.speed = - 1000
		current_stats.speed = - 1000

	_hitbox.connect("hit_something", self, "_on_hit_something")
	_hitbox.damage = current_stats.damage

	_attack_behavior.init(self)


func _physics_process(delta:float)->void :
	if dead:
		return 

	_current_attack_cd = max(_current_attack_cd - Utils.physics_one(delta), 0)
	var is_being_knocked_back = get_knockback_value().length() > get_move_input().length()

	if not _hitbox.is_disabled() and is_being_knocked_back:
		_hitbox.disable()
	elif _hitbox.is_disabled() and not is_being_knocked_back:
		_hitbox.enable()

	_current_attack_behavior.physics_process(delta)


func update_stats(hp_coef:float, damage_coef:float, speed_coef:float)->void :
	.update_stats(hp_coef, damage_coef, speed_coef)
	_hitbox.damage = current_stats.damage


func start_shoot()->void :
	_current_attack_behavior.start_shoot()


func shoot()->void :
	_current_attack_behavior.shoot()


func die(knockback_vector:Vector2 = Vector2.ZERO, p_cleaning_up:bool = false)->void :
	.die(knockback_vector, p_cleaning_up)
	_hitbox.disable()


func set_boosted()->void :
	can_be_boosted = false
	is_boosted = true
	_sprite.material = outline_mat


func on_hurt()->void :

	var remove_speed_data = RunData.get_remove_speed_data()

	if remove_speed_data.value > 0 and current_stats.speed > max_stats.speed * (1 - (remove_speed_data.max_value / 100.0)):
		current_stats.speed -= (max_stats.speed * (remove_speed_data.value / 100.0))

	if DebugService.one_shot_enemies:
		var _damage_taken = take_damage(99999999)


func get_dmg_value(dmg_value:int, armor_applied:bool = true, is_crit:bool = false)->int:

	var actual_dmg_value = dmg_value

	if is_crit and RunData.effects["giant_crit_damage"] > 0:
		var giant_bonus = int((current_stats.health * get_giant_factor()) / max(1.0, RunData.get_endless_factor() * 0.2))
		actual_dmg_value += giant_bonus

		var dmg_dealt = clamp(giant_bonus, 0, max(0, current_stats.health - dmg_value))

		RunData.tracked_item_effects["item_giant_belt"] += dmg_dealt

	return .get_dmg_value(actual_dmg_value, armor_applied, is_crit)


func get_giant_factor()->float:
	return (RunData.effects["giant_crit_damage"] / 100.0)


func _on_hit_something(_thing_hit:Node, _damage_dealt:int)->void :
	add_decaying_speed( - 200)


func _on_AnimationPlayer_animation_finished(anim_name:String)->void :
	if anim_name != "idle" and anim_name != "death":
		_animation_player.play("idle")
		_animation_player.playback_speed = _idle_playback_speed

	_current_attack_behavior.animation_finished(anim_name)


func _on_AttackBehavior_wanted_to_spawn_an_enemy(enemy_scene:PackedScene, at_position:Vector2)->void :
	emit_signal("wanted_to_spawn_an_enemy", enemy_scene, at_position)
