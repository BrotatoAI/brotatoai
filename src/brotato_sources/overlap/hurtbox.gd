class_name Hurtbox
extends Area2D

onready var _collision = $Collision as CollisionShape2D


func is_disabled()->bool:
	return _collision.disabled


func enable()->void :
	_collision.set_deferred("disabled", false)


func disable()->void :
	_collision.set_deferred("disabled", true)
