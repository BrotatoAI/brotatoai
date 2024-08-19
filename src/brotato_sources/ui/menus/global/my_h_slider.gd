class_name MyHSlider
extends HSlider

export (Resource) var focus_entered_sound = preload("res://ui/sounds/button_focus.wav")
export (Resource) var value_change_sound = preload("res://ui/sounds/button_focus.wav")


func _ready()->void :
	var _error_focus = connect("focus_entered", self, "on_focus_entered")


func on_focus_entered()->void :
	SoundManager.play(focus_entered_sound, - 10, 0.2)


func on_pressed()->void :
	SoundManager.play(value_change_sound, - 10, 0.2)


func _on_HSlider_value_changed(_value:float)->void :
	SoundManager.play(value_change_sound, - 10, 0.2)
