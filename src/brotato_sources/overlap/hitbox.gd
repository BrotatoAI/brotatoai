class_name Hitbox
extends Area2D

signal critically_hit_something(thing_hit, damage_dealt)
signal hit_something(thing_hit, damage_dealt)
signal killed_something(thing_killed)
signal added_gold_on_crit(gold_added)


var damage: = 1
var knockback_direction: = Vector2.ZERO
var knockback_amount: = 0.0
var crit_chance: = 0.0
var crit_damage: = 1.0
var effect_scale: = 1.0
var burn_chance: = 0.0
var burning_data:BurningData = null
var active = true
var deals_damage = true
var accuracy = 1.0
var is_healing: = false
var projectiles_on_hit:Array = []
var ignored_objects:Array = []
var effects:Array = []
var from = null
var damage_tracking_key = ""

onready var _collision: = $Collision as CollisionShape2D


func set_damage(p_value:int, p_accuracy:float = 1.0, p_crit_chance:float = 0.0, p_crit_damage:float = 0.0, p_burning_data:BurningData = BurningData.new(), p_is_healing:bool = false)->void :
	damage = p_value
	accuracy = p_accuracy
	crit_chance = p_crit_chance
	crit_damage = p_crit_damage
	burning_data = p_burning_data
	is_healing = p_is_healing


func hit_something(thing_hit:Node, damage_dealt:int)->void :
	emit_signal("hit_something", thing_hit, damage_dealt)

	if damage_tracking_key != "":
		RunData.tracked_item_effects[damage_tracking_key] += damage_dealt


func killed_something(thing_killed:Node)->void :
	emit_signal("killed_something", thing_killed)


func critically_hit_something(thing_hit:Node, damage_dealt:int)->void :
	emit_signal("critically_hit_something", thing_hit, damage_dealt)


func added_gold_on_crit(gold_added:int)->void :
	emit_signal("added_gold_on_crit", gold_added)


func set_knockback(direction:Vector2, amount:float)->void :
	knockback_direction = direction
	knockback_amount = amount


func is_disabled()->bool:
	return _collision.disabled


func enable()->void :
	_collision.set_deferred("disabled", false)


func disable()->void :
	_collision.set_deferred("disabled", true)
