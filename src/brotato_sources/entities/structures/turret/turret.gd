class_name Turret
extends Structure

var _max_cooldown = 0

var _shooting_speed: = 1.0
var _targets_in_range: = []
var _current_target: = []
var _cooldown = 0
var _is_shooting: = false
var _next_proj_rotation = 0

onready var _range_shape = $Range / CollisionShape2D
onready var _muzzle = $Animation / Muzzle


func _ready()->void :
	_range_shape.shape.radius = stats.max_range
	_max_cooldown = stats.cooldown

	if RunData.effects["structures_cooldown_reduction"].size() > 0:
		_max_cooldown = Utils.apply_cooldown_reduction(_max_cooldown, RunData.effects["structures_cooldown_reduction"])


func _physics_process(delta:float)->void :

	if dead:return 

	_cooldown = max(_cooldown - Utils.physics_one(delta), 0)

	_current_target = Utils.get_nearest(_targets_in_range, global_position)

	if should_shoot():
		_is_shooting = true
		_animation_player.playback_speed = _shooting_speed
		_animation_player.play("shoot")
		_next_proj_rotation = (_current_target[0].global_position - global_position).angle()


func set_data(data:Resource)->void :
	.set_data(data)
	_shooting_speed = data.shooting_animation_speed


func should_shoot()->bool:
	return (_cooldown == 0 and 
		 not _is_shooting and 
		(
			_current_target.size() > 0
			 and is_instance_valid(_current_target[0])
			 and Utils.is_between(_current_target[1], stats.min_range, stats.max_range)
		)
	)


func shoot()->void :
	if _current_target.size() == 0 or not is_instance_valid(_current_target[0]):
		_is_shooting = false
		_cooldown = rand_range(max(1, _max_cooldown * 0.7), _max_cooldown * 1.3)
	else :
		_next_proj_rotation = (_current_target[0].global_position - global_position).angle()

	SoundManager2D.play(Utils.get_rand_element(stats.shooting_sounds), global_position, stats.sound_db_mod, 0.2)

	for i in stats.nb_projectiles:
		var proj_rotation = rand_range(_next_proj_rotation - stats.projectile_spread, _next_proj_rotation + stats.projectile_spread)
		var knockback_direction: = - Vector2(cos(proj_rotation), sin(proj_rotation))
		var _projectile = WeaponService.spawn_projectile(proj_rotation, 
			stats, 
			_muzzle.global_position, 
			knockback_direction, 
			false, 
			effects
		)


func _on_Range_body_entered(body:Node)->void :
	_targets_in_range.push_back(body)
	var _error = body.connect("died", self, "on_target_died")


func _on_Range_body_exited(body:Node)->void :
	_targets_in_range.erase(body)
	if _current_target.size() > 0 and body == _current_target[0]:
		_current_target.clear()
	body.disconnect("died", self, "on_target_died")


func on_target_died(target:Node)->void :
	_targets_in_range.erase(target)
	if _current_target.size() > 0 and target == _current_target[0]:
		_current_target.clear()


func _on_AnimationPlayer_animation_finished(anim_name:String)->void :
	if anim_name == "shoot" and not dead:
		_is_shooting = false
		_cooldown = rand_range(max(1, _max_cooldown * 0.7), _max_cooldown * 1.3)
		_animation_player.playback_speed = 1.0
		_animation_player.play("idle")
