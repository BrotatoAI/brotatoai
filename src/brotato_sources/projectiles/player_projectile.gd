class_name PlayerProjectile
extends Projectile

const PROJECTILE_ADDITIONAL_DISTANCE = 100

export (bool) var enable_physics_process = false
export (int) var rotation_speed = 0

var weapon_stats:Resource
var spawn_position:Vector2


func _ready()->void :
	_sprite.modulate.a = ProgressData.settings.projectile_opacity
	set_physics_process(enable_physics_process)


func _physics_process(_delta:float)->void :

	var add_dist = PROJECTILE_ADDITIONAL_DISTANCE

	if ProgressData.is_manual_aim():
		add_dist = PROJECTILE_ADDITIONAL_DISTANCE / 2.0

	if (global_position - spawn_position).length() > weapon_stats.max_range + add_dist:
		set_to_be_destroyed()

	if rotation_speed != 0:
		rotation_degrees += 25


func set_effects(effects:Array)->void :
	_hitbox.effects = effects

	for effect in effects:
		if effect is ProjectilesOnHitEffect:
			var proj_weapon_stats = WeaponService.init_ranged_stats(effect.weapon_stats)
			_hitbox.projectiles_on_hit = [effect.value, proj_weapon_stats, effect.auto_target_enemy]


func _on_Hitbox_hit_something(thing_hit:Node, damage_dealt:int)->void :
	_hitbox.ignored_objects = [thing_hit]

	if weapon_stats.bounce > 0:
		bounce(thing_hit)
	elif weapon_stats.piercing <= 0:
		set_to_be_destroyed()
	else :
		weapon_stats.piercing -= 1
		if _hitbox.damage > 0:
			_hitbox.damage = max(1, _hitbox.damage - (_hitbox.damage * weapon_stats.piercing_dmg_reduction))

	RunData.manage_life_steal(weapon_stats)

	emit_signal("hit_something", thing_hit, damage_dealt)


func bounce(thing_hit:Node)->void :
	weapon_stats.bounce -= 1
	var target = thing_hit._entity_spawner_ref.get_rand_enemy()
	var direction = (target.global_position - global_position).angle() if target != null else rand_range( - PI, PI)
	velocity = Vector2.RIGHT.rotated(direction) * velocity.length()
	rotation = velocity.angle()
	weapon_stats.max_range = 99999
	set_knockback_vector(Vector2.ZERO, 0.0)
	if _hitbox.damage > 0:
		_hitbox.damage = max(1, _hitbox.damage - (_hitbox.damage * weapon_stats.bounce_dmg_reduction))


func _on_Hitbox_critically_hit_something(_thing_hit:Node, _damage_dealt:int)->void :
	var remove_effects = []

	for effect in _hitbox.effects:
		if effect.key == "effect_bounce_on_crit":

			weapon_stats.bounce += 1
			effect.value -= 1

			if effect.value <= 0:
				remove_effects.push_back(effect)
		elif effect.key == "effect_pierce_on_crit":

			weapon_stats.piercing += 1
			effect.value -= 1

			if effect.value <= 0:
				remove_effects.push_back(effect)

	for effect in remove_effects:
		_hitbox.effects.erase(effect)
