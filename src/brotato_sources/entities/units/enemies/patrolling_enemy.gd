class_name PatrollingEnemy
extends Enemy

export  var speed_modification_on_player_detection = 300


func _on_MovementBehavior_detected_player()->void :
	bonus_speed += speed_modification_on_player_detection
