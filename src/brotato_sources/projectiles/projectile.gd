class_name Projectile
extends Node2D

signal hit_something(thing_hit, damage_dealt)
signal available

export (bool) var destroy_on_leaving_screen = true
var velocity = Vector2.ZERO
var to_be_destroyed: = false
var to_be_recycled: = false
var recycled: = false;

onready var _sprite: = $Sprite as Sprite
onready var _hitbox: = $Hitbox as Area2D
onready var _destroy_timer: = $DestroyTimer as Timer


func _physics_process(delta)->void :
	position += velocity * delta


func get_damage()->int:
	return _hitbox.damage


func set_damage(value:int, accuracy:float = 1.0, crit_chance:float = 0.0, crit_damage:float = 0.0, burning_data:BurningData = BurningData.new(), is_healing:bool = false)->void :
	if not _hitbox:return 
	if is_instance_valid(_hitbox) == false:return 
	_hitbox.set_damage(value, accuracy, crit_chance, crit_damage, burning_data, is_healing)


func set_damage_tracking_key(damage_tracking_key:String)->void :
	if not _hitbox:return 
	if is_instance_valid(_hitbox) == false:return 
	_hitbox.damage_tracking_key = damage_tracking_key


func set_knockback_vector(knockback_direction:Vector2, knockback_amount:float)->void :
	if not _hitbox:return 
	if is_instance_valid(_hitbox) == false:return 
	_hitbox.set_knockback(knockback_direction, knockback_amount)


func set_effect_scale(effect_scale:float)->void :
	if not _hitbox:return 
	if is_instance_valid(_hitbox) == false:return 
	_hitbox.effect_scale = effect_scale


func _on_VisibilityNotifier2D_screen_exited()->void :
	if not to_be_destroyed and _destroy_timer.is_inside_tree() and destroy_on_leaving_screen:
		_destroy_timer.start()


func _on_DestroyTimer_timeout()->void :
	if to_be_recycled:
		if recycled == false:
			recycled = true
			to_be_destroyed = true
			emit_signal("available", self)
	else :
		queue_free()



func set_to_be_destroyed()->void :
	if to_be_recycled:
		if recycled == false:
			emit_signal("available", self)
			recycled = true
			to_be_destroyed = true
	else :
		to_be_destroyed = true
		_hitbox.active = false
		_hitbox.disable()
		queue_free()


func set_ignored_objects(objects:Array)->void :
	_hitbox.ignored_objects = objects


func set_from(from:Node)->void :
	if _hitbox != null and is_instance_valid(_hitbox):
		_hitbox.from = from


func disable_hitbox()->void :
	_hitbox.disable()


func enable_hitbox()->void :
	_hitbox.enable()



func on_entity_died(_entity:Entity)->void :
	set_to_be_destroyed()
