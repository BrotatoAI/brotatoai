class_name TitleScreenMenus
extends Menus

onready var _menu_credits = $MenuCredits
onready var _menu_mods = $MenuMods
onready var _menu_progression = $ProgressionUI


func _input(event:InputEvent)->void :
	if event.is_action_pressed("ui_cancel"):
		back()


func _on_MainMenu_credits_button_pressed()->void :
	switch(_main_menu, _menu_credits)


func _on_MenuCredits_back_button_pressed()->void :
	switch(_menu_credits, _main_menu)


func _on_ProgressionUI_back_button_pressed()->void :
	switch(_menu_progression, _main_menu)


func _on_MainMenu_progress_button_pressed()->void :
	switch(_main_menu, _menu_progression)


func _on_MainMenu_mods_button_pressed()->void :
	switch(_main_menu, _menu_mods)


func _on_MenuMods_back_button_pressed()->void :
	switch(_menu_mods, _main_menu)
