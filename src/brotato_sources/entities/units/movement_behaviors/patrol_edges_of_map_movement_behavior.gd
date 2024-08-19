class_name PatrolEdgesOfMapMovementBehavior
extends MovementBehavior

signal detected_player

export (int) var edge_distance = 300
export (int) var edge_randomization = 100
export (int) var detection_range = 300
export (int) var max_target_distance = 300

var movement_behavior_on_player_detection:MovementBehavior

var _detected_player:bool = false
var _actual:int
var _current_target:Vector2 = Vector2.ZERO

var player_ref:Node2D = null


func init(parent:Node)->Node:
	var _init = .init(parent)
	player_ref = (_parent as Unit).player_ref
	_actual = edge_distance + rand_range( - edge_randomization, edge_randomization)
	if movement_behavior_on_player_detection:
		movement_behavior_on_player_detection = $MovementBehaviorOnPlayerDetection
		movement_behavior_on_player_detection.init(parent)
	return self


func get_movement()->Vector2:

	if _detected_player and movement_behavior_on_player_detection:
		return movement_behavior_on_player_detection.get_movement()

	if player_ref.global_position.distance_to(_parent.global_position) <= detection_range and movement_behavior_on_player_detection:
		emit_signal("detected_player")
		_detected_player = true
		return movement_behavior_on_player_detection.get_movement()

	if _current_target == Vector2.ZERO or Utils.vectors_approx_equal(_current_target, _parent.global_position, EQUALITY_PRECISION):
		_current_target = get_new_target()

	return _current_target - _parent.global_position


func get_target_position():
	return _current_target


func get_new_target()->Vector2:
	var direction = Utils.get_direction_from_pos(_parent.global_position, _parent._min_pos, _parent._max_pos, _actual)
	var new_target = Utils.get_rand_pos_from_direction_within_distance(direction, _parent._min_pos, _parent._max_pos, _actual)

	var actual_target = _parent.global_position.direction_to(new_target).normalized() * max_target_distance

	actual_target.x = clamp(new_target.x, _parent._min_pos.x, _parent._max_pos.x)
	actual_target.y = clamp(new_target.y, _parent._min_pos.y, _parent._max_pos.y)

	return actual_target


func _on_Hurtbox_area_entered(_area:Area2D)->void :
	if not _detected_player:
		_detected_player = true
		emit_signal("detected_player")
