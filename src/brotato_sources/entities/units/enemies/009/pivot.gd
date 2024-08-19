class_name Pivot
extends Node2D

export (float) var rotation_speed = PI

var direction = Utils.get_rand_element([ - 1, 1])


func _physics_process(delta:float)->void :
	rotation += direction * rotation_speed * RunData.current_run_accessibility_settings.speed * delta


func _on_Enemy_died(_entity)->void :
	queue_free()
