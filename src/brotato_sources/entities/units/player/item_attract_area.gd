extends Area2D

const BASE_RADIUS = 150


func _ready()->void :
	$CollisionShape2D.shape.radius = max(30, BASE_RADIUS * (1.0 + (RunData.effects["pickup_range"] / 100.0)))
