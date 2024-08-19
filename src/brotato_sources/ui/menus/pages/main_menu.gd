class_name MainMenu
extends Control

signal options_button_pressed
signal credits_button_pressed
signal progress_button_pressed
signal mods_button_pressed

onready var continue_button = $"%ContinueButton"
onready var start_button = $"%StartButton"
onready var options_button = $"%OptionsButton"
onready var progress_button = $"%ProgressButton"
onready var mods_button = $"%ModsButton"
onready var quit_button = $"%QuitButton"


onready var more_games_button = $"%MoreGamesButton"
onready var newsletter_button = $"%NewsletterButton"
onready var community_button = $"%CommunityButton"
onready var credits_button = $"%CreditsButton"

onready var save_status_label = $"%SaveStatusLabel"
onready var version_label = $"%VersionLabel"


func init()->void :

	if ProgressData.current_run_state.has_run_state:
		continue_button.grab_focus()
		start_button.focus_neighbour_top = continue_button.get_path()
		quit_button.focus_neighbour_bottom = continue_button.get_path()

		set_neighbours(continue_button, mods_button)
	else :
		start_button.grab_focus()
		start_button.focus_neighbour_top = quit_button.get_path()
		quit_button.focus_neighbour_bottom = start_button.get_path()

		set_neighbours(start_button, mods_button)

	version_label.text = "version " + ProgressData.VERSION

	if ProgressData.save_status != SaveStatus.SAVE_OK:

		var status_text = "(!) "

		if ProgressData.save_status == SaveStatus.CORRUPTED_SAVE:
			status_text += tr("CORRUPTED_SAVE")
		elif ProgressData.save_status == SaveStatus.CORRUPTED_SAVE_LATEST:
			status_text += tr("CORRUPTED_SAVE_LATEST")
		elif ProgressData.save_status == SaveStatus.CORRUPTED_ALL_SAVES_STEAM:
			status_text += tr("CORRUPTED_ALL_SAVES_STEAM")
		elif ProgressData.save_status == SaveStatus.CORRUPTED_ALL_SAVES_NO_STEAM:
			status_text += tr("CORRUPTED_ALL_SAVES_NO_STEAM")

		save_status_label.text = status_text
		save_status_label.show()
	else :
		save_status_label.hide()


func set_neighbours(a:Node, b:Node)->void :
	a.focus_neighbour_right = b.get_path()
	a.focus_neighbour_left = b.get_path()
	b.focus_neighbour_right = a.get_path()
	b.focus_neighbour_left = a.get_path()


func _on_StartButton_pressed()->void :
	MusicManager.tween( - 5)
	var _error = get_tree().change_scene(MenuData.character_selection_scene)


func _on_OptionsButton_pressed()->void :
	emit_signal("options_button_pressed")


func _on_CommunityButton_pressed()->void :
	var _error = OS.shell_open(MenuData.community_url)


func _on_QuitButton_pressed()->void :
	get_tree().quit()


func _on_NewsletterButton_pressed()->void :
	var _error = OS.shell_open(MenuData.newsletter_url)


func _on_MoreGamesButton_pressed()->void :
	var _error = OS.shell_open(MenuData.more_games_url)


func _on_CreditsButton_pressed()->void :
	emit_signal("credits_button_pressed")


func _on_ProgressButton_pressed()->void :
	emit_signal("progress_button_pressed")


func _on_ContinueButton_pressed()->void :
	if not ProgressData.current_run_state.has_run_state:
		return 

	RunData.resume_from_state(ProgressData.current_run_state)
	var _error = get_tree().change_scene(MenuData.shop_scene)


func _on_ModsButton_pressed()->void :
	emit_signal("mods_button_pressed")


func _on_EditorButton_pressed()->void :
	var _error = get_tree().change_scene(MenuData.editor_scene)
