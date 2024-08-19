extends AnimatedSprite

signal destroyed


func _ready()->void :
	playing = true


func _on_HitEffect_animation_finished()->void :
	queue_free()
	emit_signal("destroyed")
