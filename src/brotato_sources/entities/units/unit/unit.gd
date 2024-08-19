class_name Unit
extends Entity

signal speed_removed(enemy)
signal health_updated(current_health, max_health)
signal took_damage(unit, value, knockback_direction, knockback_amount, is_crit, is_miss, is_dodge, is_protected, effect_scale, hit_type)

export (Array, Resource) var crit_sounds
export (Array, Resource) var hurt_sounds
export (Array, Resource) var burn_sounds
export (Array, Resource) var dodge_sounds
export (Resource) var stats
export (bool) var mirror_sprite_with_movement = true
export (bool) var always_play_hurt_sound = false
export (Resource) var flash_mat

const MIN_DEATH_KNOCKBACK_AMOUNT: = 15.0

var current_stats:LiveStats = LiveStats.new()
var max_stats:LiveStats = LiveStats.new()

var can_drop_loot: = true
var bonus_speed:int = 0

var _speed_rand_value: = 0
var _knockback_vector: = Vector2.ZERO

var player_ref:Node2D
var _entity_spawner_ref:EntitySpawner
var _can_move:bool = true
var _current_movement:Vector2
var _move_locked: = false
var decaying_bonus_speed: = 0.0
var _hit_protection: = 0
var _non_flash_material:ShaderMaterial = null

var burning_particles = null
var _burning:BurningData

var _current_movement_behavior:MovementBehavior

onready var _flash_timer: = $FlashTimer as Timer
onready var _hurtbox: = $Hurtbox as Area2D
onready var _movement_behavior: = $MovementBehavior
onready var _burning_timer: = $BurningTimer as Timer
onready var _burning_particles: = $BurningParticles
onready var _sprite = $Animation / Sprite


func _ready()->void :
	_current_movement_behavior = _movement_behavior


func init(zone_min_pos:Vector2, zone_max_pos:Vector2, p_player_ref:Node2D = null, entity_spawner_ref = null)->void :

	_burning_timer.wait_time = max(0.1, _burning_timer.wait_time * (1.0 - (RunData.effects["burning_cooldown_reduction"] / 100.0)))

	player_ref = p_player_ref
	_entity_spawner_ref = entity_spawner_ref

	_movement_behavior.init(self)
	_speed_rand_value = rand_range( - stats.speed_randomization, stats.speed_randomization) as int

	.init(zone_min_pos, zone_max_pos)


func init_current_stats()->void :
	max_stats.copy_stats(stats)

	var str_factor = Utils.get_stat("enemy_health") / 100.0

	var new_val = round((stats.health + (stats.health_increase_each_wave * (RunData.current_wave - 1))) * (RunData.current_run_accessibility_settings.health + str_factor))
	max_stats.health = round(new_val * (1.0 + RunData.get_endless_factor() * 2.25)) as int

	current_stats.copy(max_stats)
	reset_stats()


func reset_stats(dmg_coef:float = 0.0, speed_coef:float = 0.0, armor_coef:float = 0.0)->void :
	var str_factor = Utils.get_stat("enemy_damage") / 100.0
	var base_damage = (stats.damage + (stats.damage_increase_each_wave * (RunData.current_wave - 1))) * (1.0 + dmg_coef)
	var base_speed = (stats.speed + (stats.speed * (Utils.get_stat("enemy_speed") / 100.0))) * (1.0 + speed_coef)
	var base_armor = (stats.armor + (stats.armor_increase_each_wave * (RunData.current_wave - 1))) * (1.0 + armor_coef)

	var new_damage = round(base_damage * (RunData.current_run_accessibility_settings.damage + str_factor))
	var new_speed = round(base_speed * RunData.current_run_accessibility_settings.speed)
	current_stats.damage = round(new_damage * (1.0 + RunData.get_endless_factor())) as int
	current_stats.speed = round(new_speed * (1.0 + (min(1.75, RunData.get_endless_factor() / 13.33)))) as int
	current_stats.armor = round(base_armor) as int

	max_stats.copy(current_stats, true)


func update_stats(hp_coef:float, damage_coef:float, speed_coef:float)->void :
	current_stats.health = (max_stats.health * (1.0 + hp_coef)) as int
	reset_stats(damage_coef, speed_coef)


var _integrate_forces_velocity:Vector2
func _physics_process(delta:float)->void :
	_current_movement = get_movement() if _can_move else Vector2.ZERO
	update_animation(_current_movement)

	var velocity = get_next_velocity()
	_integrate_forces_velocity = velocity
	if mode == MODE_KINEMATIC:
		
		var infinite_inertia = true
		var margin = 0.08
		var result = Physics2DTestMotionResult.new()
		var is_colliding = test_motion(velocity * delta, infinite_inertia, margin, result)
		global_position += result.motion
		if is_colliding:
			var slide_velocity = velocity.slide(result.collision_normal)
			var _is_colliding = test_motion(slide_velocity * delta, infinite_inertia, margin, result)
			global_position += result.motion

	if decaying_bonus_speed > 0:
		decaying_bonus_speed -= Utils.physics_one(delta)
	elif decaying_bonus_speed < 0:
		decaying_bonus_speed += Utils.physics_one(delta) * 5


func _integrate_forces(state:Physics2DDirectBodyState)->void :
	if mode == MODE_KINEMATIC:
		
		state.transform.origin = global_position
		return 
	
	
	var target_position = _current_movement_behavior.get_target_position()
	
	if (
		target_position == null
		 or _integrate_forces_velocity == Vector2.ZERO
		 or not _can_move
		 or _move_locked
	):
		state.linear_velocity = _integrate_forces_velocity
		return 
	var origin = state.transform.origin
	var origin_to_next_origin = _integrate_forces_velocity * state.step
	var origin_to_target = target_position - origin
	
	if origin_to_target.length_squared() > origin_to_next_origin.length_squared():
		state.linear_velocity = _integrate_forces_velocity
		return 
	
	
	var projected_target = origin + origin_to_target.project(origin_to_next_origin)
	
	
	
	var next_origin = origin + origin_to_next_origin
	if (next_origin - projected_target).dot(origin - projected_target) <= 0:
		state.linear_velocity = Vector2.ZERO
		state.transform.origin = target_position
		return 
	state.linear_velocity = _integrate_forces_velocity


func get_movement()->Vector2:
	return _current_movement_behavior.get_movement() if not _move_locked else _current_movement


func get_move_input()->Vector2:
	return _current_movement.normalized() * max(0.0, (current_stats.speed + bonus_speed + decaying_bonus_speed + _speed_rand_value))


func get_next_velocity()->Vector2:
	var move_input: = get_move_input()
	var velocity: = move_input - get_next_knockback_value()
	return velocity


func get_next_knockback_value()->Vector2:
	var value = get_knockback_value()
	_knockback_vector = _knockback_vector.linear_interpolate(Vector2.ZERO, 0.1)
	return value


func get_knockback_value()->Vector2:
	return (_knockback_vector * (100 - (stats.knockback_resistance * 100)))


func get_direction()->int:
	return sprite.scale.x as int


func update_animation(movement:Vector2)->void :
	if mirror_sprite_with_movement:
		if movement.x > 0:
			sprite.scale.x = abs(sprite.scale.x)
		elif movement.x < 0:
			sprite.scale.x = - abs(sprite.scale.x)


func _get_movement()->Vector2:
	return Vector2.ZERO


func take_damage(value:int, hitbox:Hitbox = null, dodgeable:bool = true, armor_applied:bool = true, custom_sound:Resource = null, base_effect_scale:float = 1.0)->Array:
	if dead:
		return [0, 0]

	var crit_damage = 0.0
	var crit_chance = 0.0
	var knockback_direction = Vector2.ZERO
	var knockback_amount = 0.0
	var effect_scale = base_effect_scale
	var dmg_dealt = 0

	if hitbox != null:
		crit_damage = hitbox.crit_damage
		crit_chance = hitbox.crit_chance
		knockback_direction = hitbox.knockback_direction
		knockback_amount = hitbox.knockback_amount
		effect_scale = hitbox.effect_scale

	var is_crit = false
	var is_miss = false
	var is_dodge = false
	var is_protected = false

	var full_dmg_value = get_dmg_value(value, armor_applied)




	if dodgeable and randf() < min(current_stats.dodge, RunData.effects["dodge_cap"] / 100.0):
		full_dmg_value = 0
		is_dodge = true
	elif _hit_protection > 0:
		_hit_protection -= 1
		full_dmg_value = 0
		is_protected = true
	else :
		flash()

	var sound = Utils.get_rand_element(hurt_sounds)

	if full_dmg_value == 0:
		sound = Utils.get_rand_element(dodge_sounds)
	elif not is_miss and Utils.get_chance_success(crit_chance):

		full_dmg_value = get_dmg_value(round(value * crit_damage) as int, true, true)

		dmg_dealt = clamp(full_dmg_value, 0, current_stats.health)

		if hitbox:
			hitbox.critically_hit_something(self, dmg_dealt)

		is_crit = true
		sound = Utils.get_rand_element(crit_sounds)

	if custom_sound:
		sound = custom_sound

	SoundManager2D.play(sound, global_position, 0, 0.2, always_play_hurt_sound)

	dmg_dealt = clamp(full_dmg_value, 0, current_stats.health)
	current_stats.health = max(0.0, current_stats.health - full_dmg_value) as int

	_knockback_vector = knockback_direction * knockback_amount

	emit_signal("health_updated", current_stats.health, max_stats.health)

	var hit_type = HitType.NORMAL

	if current_stats.health <= 0:
		if hitbox:
			hitbox.killed_something(self)
		die(knockback_direction * max(knockback_amount, MIN_DEATH_KNOCKBACK_AMOUNT))

		if is_crit:
			var gold_added = 0

			for effect in RunData.effects["gold_on_crit_kill"]:
				if randf() <= effect[1] / 100.0:
					gold_added += 1
					RunData.tracked_item_effects["item_hunting_trophy"] += 1

			if RunData.effects["heal_on_crit_kill"] > 0:
				if randf() <= RunData.effects["heal_on_crit_kill"] / 100.0:
					RunData.emit_signal("healing_effect", 1, "item_tentacle")

			for effect in hitbox.effects:
				if effect.key == "gold_on_crit_kill" and randf() <= effect.value / 100.0:
					gold_added += 1
					hitbox.added_gold_on_crit(gold_added)

			if gold_added > 0:
				RunData.add_gold(gold_added)
				hit_type = HitType.GOLD_ON_CRIT_KILL

	emit_signal(
		"took_damage", 
		self, 
		full_dmg_value, 
		knockback_direction, 
		knockback_amount, 
		is_crit, 
		is_miss, 
		is_dodge, 
		is_protected, 
		effect_scale, 
		hit_type
	)

	return [full_dmg_value, dmg_dealt, is_dodge]


func get_dmg_value(dmg_value:int, armor_applied:bool = true, _is_crit:bool = false)->int:
	return max(1, dmg_value - current_stats.armor) as int if armor_applied else dmg_value


func flash()->void :
	
	
	var is_already_flashing = sprite.material == flash_mat
	if not is_already_flashing:
		_non_flash_material = sprite.material
		sprite.material = flash_mat
	_flash_timer.start()


func die(knockback_vector:Vector2 = Vector2.ZERO, p_cleaning_up:bool = false)->void :
	.die(knockback_vector, p_cleaning_up)
	_burning_particles.emitting = false
	_knockback_vector = knockback_vector
	_can_move = false
	_hurtbox.disable()
	_collision.set_deferred("disabled", true)
	_burning_particles.deactivate_spread()


func _on_Hurtbox_area_entered(hitbox:Area2D)->void :

	if not hitbox.active or hitbox.ignored_objects.has(self):
		return 
	var dmg = hitbox.damage
	var dmg_taken = [0, 0]

	if hitbox.deals_damage:
		var is_exploding = false

		for effect in hitbox.effects:
			if effect is ExplodingEffect:
				if Utils.get_chance_success(effect.chance):
					var explosion = WeaponService.explode(effect, global_position, hitbox.damage, hitbox.accuracy, hitbox.crit_chance, hitbox.crit_damage, hitbox.burning_data, hitbox.is_healing)

					if hitbox.from != null and is_instance_valid(hitbox.from):
						explosion.connect("hit_something", hitbox.from, "on_weapon_hit_something")

					is_exploding = true

		
		if not is_exploding:
			dmg_taken = take_damage(dmg, hitbox)

			if hitbox.burning_data != null and Utils.get_chance_success(hitbox.burning_data.chance) and not hitbox.is_healing:
				apply_burning(hitbox.burning_data)

		if hitbox.projectiles_on_hit.size() > 0:
			for i in hitbox.projectiles_on_hit[0]:
				var projectile = WeaponService.manage_special_spawn_projectile(
					self, 
					hitbox.projectiles_on_hit[1], 
					hitbox.projectiles_on_hit[2], 
					_entity_spawner_ref
				)
				projectile.connect("hit_something", hitbox.from, "on_weapon_hit_something")

				projectile.call_deferred("set_ignored_objects", [self])

		on_hurt()

	hitbox.hit_something(self, dmg_taken[1])


func apply_burning(burning_data:BurningData)->void :
	_burning_particles.burning_data = burning_data.duplicate()
	_burning_particles.burning_data.from = burning_data.from

	if _burning != null:

		if _burning.damage < burning_data.damage:
			_burning.type = burning_data.type
			_burning_particles.update_color()
			_burning.from = burning_data.from

		_burning.chance = max(_burning.chance, burning_data.chance)
		_burning.damage = max(_burning.damage, burning_data.damage) as int
		_burning.duration = max(_burning.duration, burning_data.duration) as int
		_burning.spread = max(_burning.spread, burning_data.spread) as int
	else :
		SoundManager2D.play(Utils.get_rand_element(burn_sounds), global_position, 0, 0.2, always_play_hurt_sound)
		_burning_particles.start_emitting()
		_burning = burning_data.duplicate()
		_burning.from = burning_data.from
		_burning_timer.start()

	if _burning.spread > 0:
		_burning_particles.activate_spread()


func deactivate_burning_spread()->void :
	_burning_particles.emitting = false
	_burning_particles.deactivate_spread()


func on_hurt()->void :
	pass


func _on_FlashTimer_timeout()->void :
	if sprite.material == flash_mat:
		sprite.material = _non_flash_material


func _on_BurningTimer_timeout()->void :
	if _burning != null:
		var dmg_taken = take_damage(_burning.damage, null, false, false, Utils.get_rand_element(burn_sounds), 0.1)

		
		if RunData.effects["burn_chance"].chance > 0.0 and _burning.chance <= RunData.effects["burn_chance"].chance and _burning.damage == RunData.effects["burn_chance"].damage:
			RunData.tracked_item_effects["item_scared_sausage"] += dmg_taken[1]
		elif RunData.effects["burn_chance"].chance > 0.0:
			var nb_sausages = RunData.get_nb_item("item_scared_sausage")
			RunData.tracked_item_effects["item_scared_sausage"] += nb_sausages

		if _burning.from != null and is_instance_valid(_burning.from):
			_burning.from.on_weapon_hit_something(self, dmg_taken[1])

		_burning.duration -= 1
		if _burning.duration <= 0:
			_burning = null
			_burning_timer.stop()
			_burning_particles.emitting = false
			_burning_particles.deactivate_spread()
		elif _burning.spread <= 0:
			_burning_particles.deactivate_spread()


func add_decaying_speed(value:int)->void :
	if decaying_bonus_speed < - (current_stats.speed * 0.8):
		value = 0
	elif decaying_bonus_speed < 0:
		value /= 20

	decaying_bonus_speed += value


func _on_Hitbox_body_entered(_body:Node)->void :
	pass
