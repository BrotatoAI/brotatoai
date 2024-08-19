extends Control

enum State{READY, BOOT_SPLASH, HIDE_SCENE, CHANGE_SCENE}
var state = State.READY


func _process(_delta:float):
	match state:
		State.READY:
			
			pass
		State.BOOT_SPLASH:
			state = State.HIDE_SCENE
		State.HIDE_SCENE:
			
			$BlackRect.visible = true
			state = State.CHANGE_SCENE
		State.CHANGE_SCENE:
			ProgressData.apply_settings()
			var _error = get_tree().change_scene("res://ui/menus/title_screen/title_screen.tscn")


func _draw():
	
	if state == State.READY:
		state = State.BOOT_SPLASH
