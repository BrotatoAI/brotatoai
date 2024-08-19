class_name Landmine
extends Structure

export (Resource) var pressed_sprite = null
export (Array, Resource) var pressed_sounds = []

onready var _sprite = $Animation / Sprite


func _on_Area2D_body_entered(_body:Node)->void :

	if dead or _sprite.texture == pressed_sprite:return 

	SoundManager2D.play(Utils.get_rand_element(pressed_sounds), global_position, 5, 0.2)
	_sprite.texture = pressed_sprite


func _on_Area2D_body_exited(_body:Node)->void :

	if dead or effects.size() <= 0:return 

	var explosion_effect = effects[0]

	var _inst = WeaponService.explode(explosion_effect, global_position, stats.damage, stats.accuracy, stats.crit_chance, stats.crit_damage, stats.burning_data, false, [], explosion_effect.tracking_text)
	die()
