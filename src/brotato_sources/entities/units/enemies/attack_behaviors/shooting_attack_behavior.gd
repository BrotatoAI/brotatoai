class_name ShootingAttackBehavior
extends AttackBehavior


export (PackedScene) var projectile_scene = preload("res://projectiles/bullet_enemy/enemy_projectile.tscn")
export (int) var projectile_speed = 3000
export (float) var cooldown = 60.0
export (int) var damage = 1
export (float) var damage_increase_each_wave = 1.0
export (int) var max_cd_randomization = 10
export (int) var min_range = 0
export (int) var max_range = 500
export (float) var attack_anim_speed = 1.0
export (bool) var random_direction = false
export (int) var number_projectiles = 1
export (float, 0, 3.14, 0.1) var projectile_spread = 0.0
export (bool) var spawn_projectiles_on_target = false
export (int) var projectile_spawn_spread = 0
export (bool) var projectile_spawn_only_on_borders = false
export (bool) var constant_spread = false
export (bool) var atleast_one_projectile_on_target = false
export (int) var initial_cooldown = 0
export (bool) var shoot_in_unit_direction = false
export (bool) var rotate_projectile = true
export (bool) var delete_projectile_on_death = false




var _current_initial_cooldown = 0
var _projectiles_node:Node
var _current_cd:float = cooldown


func _ready()->void :
	_projectiles_node = get_tree().current_scene.get_node("Projectiles")
	_current_cd = get_cd()
	_current_initial_cooldown = initial_cooldown


func physics_process(delta:float)->void :

	if _current_initial_cooldown > 0:
		_current_initial_cooldown = max(_current_initial_cooldown - Utils.physics_one(delta), 0)
		return 

	_current_cd = max(_current_cd - Utils.physics_one(delta), 0)

	if _current_cd <= 0 and Utils.is_between(_parent.global_position.distance_to(_parent.player_ref.global_position), min_range, max_range):
		_parent._animation_player.playback_speed = attack_anim_speed
		_parent._animation_player.play("shoot")


func shoot()->void :
	var target_pos = _parent.player_ref.global_position

	if shoot_in_unit_direction:
		target_pos = _parent.global_position + _parent.get_movement()

	for i in number_projectiles:
		var base_rot = (target_pos - _parent.global_position).angle()
		var rotation = rand_range(base_rot - projectile_spread, base_rot + projectile_spread)

		if random_direction:
			rotation = rand_range( - PI, PI)

		if constant_spread and number_projectiles > 1:
			var chunk = (2 * projectile_spread) / (number_projectiles - 1)
			var start = base_rot - projectile_spread
			rotation = start + (i * chunk)

		var pos = _parent.global_position

		if spawn_projectiles_on_target:
			pos = target_pos

		if projectile_spawn_only_on_borders:
			var rand = rand_range(0, 2 * PI)

			if constant_spread:
				rand = i * ((2 * PI) / number_projectiles)

			pos = Vector2(pos.x + cos(rand) * (projectile_spawn_spread / 2), pos.y + sin(rand) * (projectile_spawn_spread / 2))
		elif not atleast_one_projectile_on_target or i != 0:
			pos = Vector2(
				rand_range(pos.x - projectile_spawn_spread / 2, pos.x + projectile_spawn_spread / 2), 
				rand_range(pos.y - projectile_spawn_spread / 2, pos.y + projectile_spawn_spread / 2)
			)

		var _projectile = spawn_projectile(rotation, pos)


func animation_finished(anim_name:String)->void :
	if anim_name == "shoot":
		_current_cd = get_cd()


func spawn_projectile(rotation:float, pos:Vector2)->Node:
	var projectile = projectile_scene.instance()
	projectile.global_position = pos
	_projectiles_node.call_deferred("add_child", projectile)

	projectile.call_deferred("set_from", _parent)
	projectile.set_deferred("velocity", Vector2.RIGHT.rotated(rotation) * projectile_speed * RunData.current_run_accessibility_settings.speed)

	if rotate_projectile:
		projectile.set_deferred("rotation", rotation)

	if delete_projectile_on_death:
		var _error_died = _parent.connect("died", projectile, "on_entity_died")

	projectile.call_deferred("set_damage", ((damage + ((RunData.current_wave - 1) * damage_increase_each_wave)) as int))

	return projectile


func get_cd()->float:
	return rand_range(max(1, cooldown - max_cd_randomization), cooldown + max_cd_randomization)
