class_name EndRun
extends Control

var retry_button_pressed = false
var exit_button_pressed = false
var new_run_button_pressed = false

onready var _title = $MarginContainer / VBoxContainer / HBoxContainer / Title
onready var _run_info = $MarginContainer / VBoxContainer / HBoxContainer / RunInfo
onready var _exit_button = $MarginContainer / VBoxContainer / HBoxContainer3 / ExitButton
onready var _retry_button = $MarginContainer / VBoxContainer / HBoxContainer3 / RetryButton
onready var _new_run_button = $MarginContainer / VBoxContainer / HBoxContainer3 / NewRunButton
onready var _focus_manager = $FocusManager
onready var _weapons_container = $MarginContainer / VBoxContainer / HBoxContainer2 / VBoxContainer / PanelContainer / HBoxContainer / MarginContainer2 / VBoxContainer / HBoxContainer / WeaponsContainer
onready var _items_container = $MarginContainer / VBoxContainer / HBoxContainer2 / VBoxContainer / PanelContainer / HBoxContainer / MarginContainer2 / VBoxContainer / ItemsContainer
onready var _progress_container = $MarginContainer / VBoxContainer / HBoxContainer2 / VBoxContainer / PanelContainer / HBoxContainer / MarginContainer2 / VBoxContainer / HBoxContainer / ProgressContainer
onready var _stats_container = $MarginContainer / VBoxContainer / HBoxContainer2 / VBoxContainer / PanelContainer / HBoxContainer / StatsContainer
onready var _stat_popup = $StatPopup
onready var _item_popup = $ItemPopup


func _ready()->void :
	_stats_container.disable_focus_except_mouse()
	_weapons_container.set_data("WEAPONS", Category.WEAPON, RunData.weapons)
	_items_container.set_data("ITEMS", Category.ITEM, RunData.items, true, true)

	var rewards = []

	if RunData.difficulty_unlocked != - 1:
		var difficulty_data = null

		for difficulty in ItemService.difficulties:
			if difficulty.value == RunData.difficulty_unlocked:
				difficulty_data = difficulty
				break

		rewards.push_back(difficulty_data)

	if RunData.max_endless_wave_record_beaten != - 1:
		var difficulty_data = null

		for difficulty in ItemService.difficulties:
			if difficulty.value == RunData.get_current_difficulty():
				difficulty_data = difficulty.duplicate()
				break

		difficulty_data.effects = []


	for chal in RunData.challenges_completed_this_run:
		rewards.push_back(chal.reward)

	_progress_container.set_data("MENU_PROGRESS", Category.CHALLENGE, rewards)

	_focus_manager.init(
		_item_popup, 
		_stat_popup, 
		_weapons_container, 
		_items_container, 
		_stats_container, 
		_progress_container, 
		false
	)

	if RunData.challenges_completed_this_run.size() > 0:
		_progress_container.focus_element_index(0)
	else :
		_new_run_button.grab_focus()

	var diff_text = Text.text(ItemService.get_element(ItemService.difficulties, "", RunData.get_current_difficulty()).name, [str(RunData.get_current_difficulty())])

	diff_text += " - " + tr("ENDLESS") if RunData.is_endless_run else ""

	diff_text += Utils.get_enemy_scaling_text(
		RunData.current_run_accessibility_settings.health, 
		RunData.current_run_accessibility_settings.damage, 
		RunData.current_run_accessibility_settings.speed
	)

	var wave_and_diff_text = Text.text("WAVE", [str(RunData.current_wave)]) + " - " + diff_text

	if RunData.run_won:
		_title.text = tr("RUN_WON")
		_run_info.text = diff_text if not RunData.is_endless_run else wave_and_diff_text
	else :
		_title.text = tr("RUN_LOST")
		_run_info.text = wave_and_diff_text


func _on_ExitButton_pressed()->void :
	if exit_button_pressed:
		return 

	exit_button_pressed = true
	RunData.reset()
	var _error = get_tree().change_scene(MenuData.title_screen_scene)


func _on_RetryButton_pressed()->void :
	if retry_button_pressed:
		return 

	retry_button_pressed = true
	RunData.reset(true)
	MusicManager.play(0)
	var _error = get_tree().change_scene(MenuData.game_scene)


func _on_NewRunButton_pressed()->void :
	if new_run_button_pressed:
		return 

	Utils.last_elt_selected = RunData.current_character
	new_run_button_pressed = true
	RunData.reset()
	MusicManager.tween( - 5)
	var _error = get_tree().change_scene(MenuData.character_selection_scene)


func _on_FocusManager_element_pressed(_element)->void :
	_new_run_button.grab_focus()
