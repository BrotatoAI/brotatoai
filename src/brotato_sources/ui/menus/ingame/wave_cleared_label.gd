class_name WaveClearedLabel
extends Label

export (Resource) var font_end_run
export (Array, Resource) var character_appearing_sounds


func _ready()->void :
	visible_characters = 0


func start(is_last_wave:bool = false, is_run_lost:bool = false, is_run_won:bool = false)->void :

	if is_last_wave or is_run_won:
		text = "RUN_WON"
		add_font_override("font", font_end_run)

	if is_run_lost:
		text = "RUN_LOST"
		add_font_override("font", font_end_run)

	DebugService.log_data("start timer...")

	$Timer.start()


func _on_Timer_timeout()->void :
	visible_characters += 1
	SoundManager.play(Utils.get_rand_element(character_appearing_sounds), - 10, 0.2)
	if percent_visible < 1.0:
		$Timer.start()
