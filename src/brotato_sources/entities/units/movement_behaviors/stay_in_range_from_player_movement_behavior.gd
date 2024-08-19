class_name StayInRangeFromPlayerMovementBehavior
extends MovementBehavior

export (int) var target_range = 300
export (int) var target_range_randomization = 100

var _actual_target_range:float


var player_ref:Node2D = null


func _ready()->void :
	_actual_target_range = target_range + rand_range( - target_range_randomization, target_range_randomization)


func init(parent:Node)->Node:
	var _init = .init(parent)
	player_ref = (_parent as Unit).player_ref
	return self


func get_movement()->Vector2:
	var target_position = get_target_position()
	if Utils.vectors_approx_equal(target_position, _parent.global_position, EQUALITY_PRECISION):
		return Vector2.ZERO
	else :
		return target_position - _parent.global_position


func get_target_position():
	var dir = (_parent.global_position - player_ref.global_position).normalized()
	return player_ref.global_position + _actual_target_range * dir
