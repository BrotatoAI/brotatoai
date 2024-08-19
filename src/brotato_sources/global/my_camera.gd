extends Camera2D

var center_horizontal = false
var center_vertical = false
var center_horizontal_pos:int
var center_vertical_pos:int


func _process(_delta:float)->void :
	if center_horizontal:
		global_position.x = center_horizontal_pos
	if center_vertical:
		global_position.y = center_vertical_pos
