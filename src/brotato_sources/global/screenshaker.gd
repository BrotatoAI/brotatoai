class_name Screenshaker
extends Node

var _camera_shake_intensity: = 0.0
var _camera_shake_duration: = 0.0

var _camera:Camera2D


func _ready()->void :
	_camera = get_parent()


func _on_player_took_damage(_unit:Unit, value:int, _knockback_direction:Vector2, _knockback_amount:float, _is_crit:bool, _is_miss:bool, _is_dodge:bool, _is_protected:bool, _effect_scale:float, _hit_type:int)->void :
	if value == 0:
		return 

	shake(5, 0.1)


func _on_unit_took_damage(_unit:Unit, value:int, _knockback_direction:Vector2, _knockback_amount:float, _is_crit:bool, _is_miss:bool, _is_dodge:bool, _is_protected:bool, _effect_scale:float, _hit_type:int)->void :
	shake(min(value / 3.0, 3), 0.1)


func shake(intensity:float, duration:float)->void :
	if not ProgressData.settings.screenshake:
		return 

	if intensity > _camera_shake_intensity and duration > _camera_shake_duration:
		_camera_shake_intensity = intensity
		_camera_shake_duration = duration


func _process(delta:float)->void :
	if _camera_shake_duration <= 0:
		_camera.offset = Vector2.ZERO
		_camera_shake_intensity = 0.0
		_camera_shake_duration = 0.0
		return 

	_camera_shake_duration -= delta
	_camera.offset = Vector2(randf(), randf()) * _camera_shake_intensity
