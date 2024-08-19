class_name WanderingBot
extends Turret

var distance = rand_range(100, 200)
var rotation_speed = rand_range(2, 2.5)

var _player = null
var _angle = rand_range(0, 2 * PI)

export (Resource) var slow_sound

onready var _slow_hitbox = $SlowHitbox


func init(zone_min_pos:Vector2, zone_max_pos:Vector2, player_ref:Node2D = null, _entity_spawner_ref = null)->void :
	.init(zone_min_pos, zone_max_pos, player_ref, _entity_spawner_ref)
	_player = player_ref


func _physics_process(delta:float)->void :
	_angle += delta * rotation_speed
	global_position = Vector2(_player.global_position.x + cos(_angle) * distance, _player.global_position.y + sin(_angle) * distance)


func _ready()->void :
	_slow_hitbox.deals_damage = false


func _on_SlowHitbox_hit_something(thing_hit:Node, _damage_dealt:int)->void :
	SoundManager2D.play(slow_sound, thing_hit.global_position, - 5, 0.2)
	thing_hit.add_decaying_speed( - 250)
	thing_hit.emit_signal("speed_removed", thing_hit)
