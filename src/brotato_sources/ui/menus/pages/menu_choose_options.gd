class_name MenuChooseOptions
extends VBoxContainer

signal general_button_pressed
signal gameplay_button_pressed
signal back_button_pressed


func init()->void :
	$Buttons / GeneralButton.grab_focus()


func _on_GeneralButton_pressed()->void :
	emit_signal("general_button_pressed")


func _on_GameplayButton_pressed()->void :
	emit_signal("gameplay_button_pressed")


func _on_BackButton_pressed()->void :
	emit_signal("back_button_pressed")
