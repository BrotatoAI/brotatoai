class_name WeaponSelection
extends CharacterSelection

var weapon_added: = false

onready var _character_panel:ItemPanelUI = $MarginContainer / VBoxContainer / DescriptionContainer / CharacterPanel


func _ready()->void :
	_character_panel.set_data(RunData.current_character)
	_info_panel.hide()


func get_elements_unlocked()->Array:

	var elements_unlocked = []

	for weapon in RunData.current_character.starting_weapons:
		if ProgressData.weapons_unlocked.has(weapon.weapon_id):
			elements_unlocked.push_back(weapon.my_id)

	return elements_unlocked


func manage_back(event:InputEvent)->void :
	if event.is_action_pressed("ui_cancel"):
		RunData.apply_weapon_selection_back()


func get_all_possible_elements()->Array:

	var possible_weapons = []

	for weapon in RunData.current_character.starting_weapons:
		possible_weapons.push_back(weapon)

	return possible_weapons


func get_reward_type()->int:
	return RewardType.STARTING_WEAPON


func on_element_pressed(element:InventoryElement)->void :
	if weapon_added:
		return 

	if element.is_random:
		weapon_added = true
		var _weapon = RunData.add_weapon(Utils.get_rand_element(available_elements), true)
	elif element.is_special:
		return 
	else :
		weapon_added = true
		var _weapon = RunData.add_weapon(element.item, true)

	RunData.add_starting_items_and_weapons()

	var _error = get_tree().change_scene(MenuData.difficulty_selection_scene)


func update_info_panel(_item_info:ItemParentData)->void :
	pass


func is_char_screen()->bool:
	return false


func is_locked_elements_displayed()->bool:
	return false
