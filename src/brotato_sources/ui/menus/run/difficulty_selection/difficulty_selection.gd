class_name DifficultySelection
extends CharacterSelection

var difficulty_selected: = false
var cancelled = false

onready var _character_panel:ItemPanelUI = $MarginContainer / VBoxContainer / DescriptionContainer / CharacterPanel
onready var _weapon_panel:ItemPanelUI = $MarginContainer / VBoxContainer / DescriptionContainer / WeaponPanel
onready var _endless_button:Button = $"%EndlessButton"


func _ready()->void :
	_character_panel.set_data(RunData.current_character)

	if RunData.starting_weapon:
		_weapon_panel.show()
		_weapon_panel.set_data(RunData.starting_weapon)
	else :
		_weapon_panel.hide()

	_info_panel.hide()

	var diff_info = ProgressData.get_character_difficulty_info(RunData.current_character.my_id, RunData.current_zone)
	_inventory.focus_element_index(diff_info.difficulty_selected_value)

	var max_diff = diff_info.max_selectable_difficulty
	_endless_button.focus_neighbour_top = _inventory.get_child(max_diff).get_path()


func get_elements_unlocked()->Array:

	var unlocked_difficulties = []

	for diff in ItemService.difficulties:
		var max_diff = ProgressData.get_character_difficulty_info(RunData.current_character.my_id, RunData.current_zone).max_selectable_difficulty
		if diff.value <= max_diff or diff.unlocked_by_default or DebugService.unlock_all_difficulties:
			unlocked_difficulties.push_back(diff.my_id)

	return unlocked_difficulties


func manage_back(event:InputEvent)->void :
	if event.is_action_pressed("ui_cancel") and not cancelled:
		cancelled = true
		RunData.weapons = []
		RunData.items = []
		RunData.effects = RunData.init_effects()
		RunData.is_endless_run = false
		RunData.init_appearances_displayed()

		Utils.last_elt_selected = RunData.starting_weapon
		RunData.starting_weapon = null

		RunData.active_set_effects = []
		RunData.unique_effects = []
		RunData.additional_weapon_effects = []
		RunData.tier_iv_weapon_effects = []
		RunData.tier_i_weapon_effects = []

		RunData.add_character(RunData.current_character)

		if RunData.effects["weapon_slot"] == 0:
			RunData.apply_weapon_selection_back()
			var _error = get_tree().change_scene(MenuData.character_selection_scene)
		else :
			var _error = get_tree().change_scene(MenuData.weapon_selection_scene)


func get_all_possible_elements()->Array:
	return ItemService.difficulties


func get_reward_type()->int:
	return RewardType.DIFFICULTY


func on_element_pressed(element:InventoryElement)->void :
	if difficulty_selected:
		return 

	if element.is_special:
		return 
	else :
		difficulty_selected = true

		var character_difficulty = ProgressData.get_character_difficulty_info(RunData.current_character.my_id, RunData.current_zone)
		character_difficulty.difficulty_selected_value = element.item.value
		RunData.current_difficulty = element.item.value

		RunData.init_elites_spawn()

		ProgressData.save()

		for effect in element.item.effects:
			effect.apply()

	MusicManager.tween(0)
	RunData.current_run_accessibility_settings = ProgressData.settings.enemy_scaling.duplicate()
	ProgressData.save_status = SaveStatus.SAVE_OK
	var _error = get_tree().change_scene(MenuData.game_scene)


func update_info_panel(_item_info:ItemParentData)->void :
	pass


func _on_EndlessButton_toggled(button_pressed:bool)->void :
	RunData.is_endless_run = button_pressed
	ProgressData.settings.endless_mode_toggled = button_pressed


func is_char_screen()->bool:
	return false
