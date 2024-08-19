class_name IngameMainMenu
extends Control

signal options_button_pressed
signal resume_button_pressed
signal quit_button_pressed
signal restart_button_pressed

onready var _resume_button = $Content / MarginContainer / HBoxContainer / Buttons / ResumeButton
onready var _weapons_container = $Content / MarginContainer / HBoxContainer / VBoxContainer / WeaponsContainer
onready var _items_container = $Content / MarginContainer / HBoxContainer / VBoxContainer / ItemsContainer
onready var _stats_container = $Content / MarginContainer / HBoxContainer / StatsContainer
onready var _focus_manager = $FocusManager
onready var _item_popup = $ItemPopup
onready var _stat_popup = $StatPopup
onready var _difficulty_label = $Content / MarginContainer / HBoxContainer / VBoxContainer / DifficultyLabel


func init()->void :
	_resume_button.grab_focus()

	_weapons_container.set_data(get_weapons_label_text(), Category.WEAPON, RunData.weapons)
	_items_container.set_data("ITEMS", Category.ITEM, RunData.items, true, true)

	if not _focus_manager.initialized:
		_focus_manager.init(_item_popup, _stat_popup, _weapons_container, _items_container, _stats_container, null, false)

	_stats_container.update_stats()

	_difficulty_label.text = "%s%s%s" % [
		Text.text(ItemService.get_element(ItemService.difficulties, "", RunData.get_current_difficulty()).name, [str(RunData.get_current_difficulty())]), 
		" - " + tr("ENDLESS") if RunData.is_endless_run else "", 
		Utils.get_enemy_scaling_text(
			RunData.current_run_accessibility_settings.health, 
			RunData.current_run_accessibility_settings.damage, 
			RunData.current_run_accessibility_settings.speed
		)
	]


func _on_ResumeButton_pressed()->void :
	get_tree().paused = false
	emit_signal("resume_button_pressed")


func _on_OptionsButton_pressed()->void :
	emit_signal("options_button_pressed")


func _on_QuitButton_pressed()->void :
	emit_signal("quit_button_pressed")


func get_weapons_label_text()->String:
	return tr("WEAPONS") + " (" + str(RunData.weapons.size()) + "/" + str(RunData.effects["weapon_slot"]) + ")"


func _on_RestartButton_pressed()->void :
	emit_signal("restart_button_pressed")
