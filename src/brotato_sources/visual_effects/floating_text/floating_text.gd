class_name FloatingText
extends Label

signal available

var _tween:SceneTreeTween

func display(content:String, direction:Vector2, duration:float, spread:float, color:Color = Color.white, all_caps:bool = false)->void :
	self_modulate = color
	text = content
	uppercase = all_caps
	var movement: = direction.rotated(rand_range( - spread / 2, spread / 2))
	rect_pivot_offset = rect_size / 2
	rect_scale = Vector2.ONE
	modulate.a = 1.0

	_tween = create_tween()

	_tween.tween_property(
		self, 
		"rect_position", 
		rect_position + movement, 
		duration
	).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	_tween.tween_property(
		self, 
		"rect_scale", 
		Vector2.ZERO, 
		duration
	).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)

	_tween.parallel().tween_property(
		self, 
		"modulate:a", 
		0.0, 
		duration
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	yield (_tween, "finished")

	
	
	for child in get_children():
		child.queue_free()

	emit_signal("available", self)
