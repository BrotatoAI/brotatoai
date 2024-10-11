class_name PauseMenu
extends PanelContainer

signal paused
signal unpaused

onready var menu_general_options = $Menus / MenuGeneralOptions
onready var menu_gameplay_options = $Menus / MenuGameplayOptions
onready var _main_menu = $Menus / MainMenu
onready var _menus = $Menus


func _ready()->void :
	var _error = _main_menu.connect("resume_button_pressed", self, "on_resume_button_pressed")


func init()->void :
	_main_menu.init()


func _input(event:InputEvent)->void :

	if (event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_pause")) and get_tree().paused:
		manage_back()
	elif event.is_action_pressed("ui_pause"):
		pause()


func manage_back()->void :
	if _main_menu.visible:
		unpause()
	else :
		_menus.back()


func unpause()->void :
	hide()
	get_tree().paused = false
	_menus.reset()
	emit_signal("unpaused")


func pause()->void :
	emit_signal("paused")
	show()
	get_tree().paused = true
	_main_menu.init()


func on_resume_button_pressed()->void :
	hide()
	emit_signal("unpaused")


func on_game_lost_focus()->void :
	# ANCHOR : Game lost focus
	pass
	#if not get_tree().paused and ProgressData.settings.pause_on_focus_lost:
	#	pause()
