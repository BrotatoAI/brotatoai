class_name MenuRestart
extends VBoxContainer

signal cancel_button_pressed

var confirm_button_pressed = false


func init()->void :
	$Buttons / ConfirmButton.grab_focus()


func _on_CancelButton_pressed()->void :
	emit_signal("cancel_button_pressed")


func _on_ConfirmButton_pressed()->void :
	if confirm_button_pressed:
		return 

	confirm_button_pressed = true
	ProgressData.reset_run_state()
	RunData.reset(true)
	get_tree().paused = false
	MusicManager.play(0)
	var _error = get_tree().change_scene(MenuData.game_scene)
