class_name FollowRandPosAroundPlayerMovementBehavior
extends MovementBehavior

export (int) var range_around_player = 200
export (int) var range_randomization = 0
export (bool) var allow_within:bool = true

var _actual:int
var _distance_from_player:Vector2

var player_ref:Node2D = null


func init(parent:Node)->Node:
	var _init = .init(parent)
	player_ref = (_parent as Unit).player_ref
	_actual = range_around_player + rand_range( - range_randomization, range_randomization)
	_distance_from_player = Vector2(rand_range( - _actual, _actual), rand_range( - _actual, _actual))

	if not allow_within:
		_distance_from_player = _distance_from_player.normalized() * _actual

	return self


func get_movement()->Vector2:
	var target = get_target_position()

	if Utils.vectors_approx_equal(target, _parent.global_position, EQUALITY_PRECISION):
		return Vector2.ZERO

	return target - _parent.global_position


func get_target_position():
	return player_ref.global_position + _distance_from_player
