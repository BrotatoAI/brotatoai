class_name TargetRandPosMovementBehavior
extends MovementBehavior

var _current_target:Vector2 = Vector2.ZERO


func get_movement()->Vector2:
	if _current_target == Vector2.ZERO or Utils.vectors_approx_equal(_current_target, _parent.global_position, EQUALITY_PRECISION):
		_current_target = get_new_target()

	return _current_target - _parent.global_position


func get_target_position():
	return _current_target


func get_new_target()->Vector2:
	var new_target = Vector2(
		rand_range(_parent._min_pos.x, _parent._max_pos.x), 
		rand_range(_parent._min_pos.y, _parent._max_pos.y)
	)

	return new_target
