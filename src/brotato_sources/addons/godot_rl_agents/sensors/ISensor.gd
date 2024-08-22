extends Node2D
class_name ISensor

var _obs : Array
var _active := false

func get_observation():
	pass
	
func activate():
	_active = true
	
func deactivate():
	_active = false

func _update_observation():
	pass
	
func reset():
	pass
