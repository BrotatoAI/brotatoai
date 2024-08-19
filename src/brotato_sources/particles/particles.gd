class_name MyParticles
extends Particles2D

signal destroyed


func _on_DestroyTimer_timeout()->void :
	queue_free()
	emit_signal("destroyed")
