class_name EntityBirth
extends Area2D

signal birth_timeout(birth, type, unit, pos, data)

const FLICKER_TRANSPARENCY = 0.25

export (float) var time_before_spawn: = 60.0
export (Resource) var birth_begin_sound
export (Resource) var birth_end_sound

var data:Resource = null
var entity_to_spawn:PackedScene = null
var flicker_cd:float = 0
var time_invisible:float = 0.0
var type:int
var color:Color = Color(1.0, 0.22, 0.22, 1.0)
var colliding_with_player: = false

onready var _collision_shape = $CollisionShape2D


func _ready()->void :
	rotation_degrees = rand_range(0, 360)
	flicker_cd = get_flicker_cd()
	$Sprite.modulate = color
	SoundManager2D.play(birth_begin_sound, global_position, 0, 0.2)


func get_flicker_cd()->float:
	return time_before_spawn / 3.25


func set_entity(p_type:int, scene:PackedScene, p_data:Resource = null)->void :
	entity_to_spawn = scene
	type = p_type
	data = p_data


func _physics_process(delta:float)->void :
	time_before_spawn -= Utils.physics_one(delta)

	if $Sprite.self_modulate.a <= FLICKER_TRANSPARENCY:
		time_invisible -= Utils.physics_one(delta)

		if time_invisible <= 0:
			$Sprite.self_modulate.a = 1.0
			flicker_cd = get_flicker_cd()
	else :
		flicker_cd -= Utils.physics_one(delta)

		if flicker_cd <= 0:
			$Sprite.self_modulate.a = FLICKER_TRANSPARENCY
			time_invisible = 6

	if time_before_spawn <= 0:

		if colliding_with_player and type == EntityType.ENEMY:
			global_position = ZoneService.get_rand_pos()
			time_before_spawn = 60.0
		else :
			SoundManager2D.play(birth_end_sound, global_position, - 15, 0.2)
			queue_free()
			emit_signal("birth_timeout", self, type, entity_to_spawn, global_position, data)


func _on_EntityBirth_body_entered(_body:Node)->void :
	colliding_with_player = true


func _on_EntityBirth_body_exited(_body:Node)->void :
	colliding_with_player = false

