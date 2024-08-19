class_name Entity
extends RigidBody2D

signal died(entity)

var dead: = false
var cleaning_up: = false

var _min_pos: = Vector2( - 9999, - 9999)
var _max_pos: = Vector2(9999, 9999)

onready var sprite: = $Animation / Sprite as Sprite
onready var _animation_player: = $AnimationPlayer as AnimationPlayer
onready var _animation: = $Animation as Node2D
onready var _collision: = $Collision as CollisionShape2D


func init(zone_min_pos:Vector2, zone_max_pos:Vector2, _p_player_ref:Node2D = null, _entity_spawner_ref = null)->void :

	_min_pos = Vector2(
		zone_min_pos.x + sprite.texture.get_width() / 2.0, 
		zone_min_pos.y + sprite.texture.get_height() / 2.0
	)

	_max_pos = Vector2(
		zone_max_pos.x - sprite.texture.get_width() / 2.0, 
		zone_max_pos.y - sprite.texture.get_height() / 2.0
	)


func die(_knockback_vector:Vector2 = Vector2.ZERO, p_cleaning_up:bool = false)->void :
	cleaning_up = p_cleaning_up
	_animation_player.playback_speed = 1
	dead = true
	_animation_player.play("death")
	emit_signal("died", self)


func death_animation_finished()->void :
	queue_free()


func deactivate_burning_spread()->void :
	pass
