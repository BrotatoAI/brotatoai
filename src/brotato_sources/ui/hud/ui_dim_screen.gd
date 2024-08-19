class_name UIDimScreen
extends ColorRect

onready var _tween:Tween = $Tween


func dim()->void :
	var _error_interpolate = _tween.interpolate_property(
		self, 
		"color:a", 
		0, 
		0.5, 
		1, 
		Tween.TRANS_LINEAR
	)

	var _error = _tween.start()
