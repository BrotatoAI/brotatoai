class_name MenuCredits
extends Control

signal back_button_pressed


func init()->void :
	$VBoxContainer / Buttons / BackButton.grab_focus()


func _on_BackButton_pressed()->void :
	emit_signal("back_button_pressed")
