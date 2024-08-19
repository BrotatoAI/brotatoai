class_name ChargingAttackBehavior
extends AttackBehavior

enum TargetType{PLAYER, RAND_POINT_AROUND_PLAYER}

export (float) var cooldown = 60.0
export (int) var max_cd_randomization = 10
export (int) var min_range = 0
export (int) var max_range = 300
export (float) var attack_anim_speed = 1.0
export (float) var charge_duration = 1.0
export (float) var charge_speed = 500.0
export (TargetType) var target = TargetType.PLAYER

var _current_cd:float = cooldown
var _charge_direction:Vector2

var _unlock_move_timer:Timer


func _ready()->void :
	_current_cd = get_cd()
	_unlock_move_timer = Timer.new()
	add_child(_unlock_move_timer)
	_unlock_move_timer.wait_time = charge_duration
	_unlock_move_timer.one_shot = true
	_unlock_move_timer.autostart = false
	_unlock_move_timer.connect("timeout", self, "on_unlock_move_timer_timeout")


func physics_process(delta:float)->void :

	_current_cd = max(_current_cd - Utils.physics_one(delta), 0)

	if _current_cd <= 0 and Utils.is_between(_parent.global_position.distance_to(_parent.player_ref.global_position), min_range, max_range):
		_parent._animation_player.playback_speed = attack_anim_speed
		_parent._animation_player.play("shoot")


func start_shoot()->void :
	if target == TargetType.PLAYER:
		_charge_direction = (_parent.player_ref.global_position - _parent.global_position)
	else :
		var target_pos = _parent.player_ref.global_position + Vector2(rand_range( - max_range / 5, max_range / 5), rand_range( - max_range / 5, max_range / 5))
		_charge_direction = (target_pos - _parent.global_position)

	_parent._can_move = false


func shoot()->void :
	_parent._can_move = true
	_parent._move_locked = true
	_parent.bonus_speed = charge_speed * RunData.current_run_accessibility_settings.speed
	_parent._current_movement = _charge_direction
	_unlock_move_timer.start()
	_current_cd = get_cd() + charge_duration * 60


func on_unlock_move_timer_timeout()->void :
	_parent._move_locked = false
	_parent.bonus_speed = 0
	_parent._animation_player.playback_speed = _parent._idle_playback_speed


func animation_finished(anim_name:String)->void :
	if anim_name == "shoot":
		_parent._animation_player.playback_speed *= 2


func get_cd()->float:
	return rand_range(max(1, cooldown - max_cd_randomization), cooldown + max_cd_randomization)
