class_name CharacterSelection
extends Control

export (Texture) var random_icon
export (bool) var add_random_element = true

var available_elements: = []
var character_added = false

onready var _inventory:Inventory = $"%Inventory"
onready var _panel:PanelContainer = $MarginContainer / VBoxContainer / DescriptionContainer / Panel
onready var _locked_panel:PanelContainer = $MarginContainer / VBoxContainer / DescriptionContainer / LockedPanel
onready var _info_panel:PanelContainer = $MarginContainer / VBoxContainer / DescriptionContainer / InfoPanel


func _ready()->void :

	var possible_elements = get_all_possible_elements()

	if possible_elements.size() > 1 and add_random_element:
		_inventory.add_special_element(random_icon, true)

	var elts_unlocked = get_elements_unlocked()

	var elements = []

	if DebugService.unlock_all_chars and is_char_screen():
		elements = possible_elements
		available_elements = elements
	else :
		for element in possible_elements:

			var new_element = element.duplicate()

			new_element.is_locked = not elts_unlocked.has(new_element.my_id)

			if not is_locked_elements_displayed() and new_element.is_locked:
				continue

			if is_char_screen():
				var diff_info = ProgressData.get_character_difficulty_info(new_element.my_id, RunData.current_zone)

				if diff_info.max_difficulty_beaten.difficulty_value == 0:
					new_element.tier = Tier.DANGER_0
				elif diff_info.max_difficulty_beaten.difficulty_value > 0:
					new_element.tier = diff_info.max_difficulty_beaten.difficulty_value

			elements.push_back(new_element)

			if not new_element.is_locked:
				available_elements.push_back(new_element)

	_inventory.set_elements(elements, false, false)

	var _error_pressed = _inventory.connect("element_pressed", self, "on_element_pressed")
	var _error_focused = _inventory.connect("element_focused", self, "on_element_focused")
	var _error_hovered = _inventory.connect("element_hovered", self, "on_element_hovered")

	_inventory.get_child(0).grab_focus()

	if Utils.last_elt_selected != null:
		for child in _inventory.get_children():

			if child.is_special:continue

			if child.item.my_id == Utils.last_elt_selected.my_id:
				child.grab_focus()
		Utils.last_elt_selected = null


func _input(event:InputEvent)->void :
	manage_back(event)


func manage_back(event:InputEvent)->void :
	if event.is_action_pressed("ui_cancel"):
		RunData.current_zone = 0
		RunData.reload_music = false
		var _error = get_tree().change_scene(MenuData.title_screen_scene)


func get_elements_unlocked()->Array:
	return ProgressData.characters_unlocked


func get_all_possible_elements()->Array:
	return ItemService.characters


func get_reward_type()->int:
	return RewardType.CHARACTER


func on_element_pressed(element:InventoryElement)->void :

	if character_added:
		return 

	if element.is_random:
		character_added = true
		RunData.add_character(Utils.get_rand_element(available_elements))
	elif element.is_special:
		return 
	else :
		character_added = true
		RunData.add_character(element.item)

	if RunData.effects["weapon_slot"] == 0:
		var _error = get_tree().change_scene(MenuData.difficulty_selection_scene)
	else :
		var _error = get_tree().change_scene(MenuData.weapon_selection_scene)


func on_element_hovered(element:InventoryElement)->void :
	on_element_focused(element)


func on_element_focused(element:InventoryElement)->void :

	if element.is_random:
		_panel.hide()
		_locked_panel.hide()
		_info_panel.hide()
		return 
	else :
		if element.is_special:
			_panel.hide()
			_locked_panel.show()
			_locked_panel.set_element(element.item, get_reward_type())
			_info_panel.hide()
		else :
			_locked_panel.hide()
			_panel.show()
			_panel.set_data(element.item)
			update_info_panel(element.item)


func update_info_panel(item_info:ItemParentData)->void :
	_info_panel.show()
	_info_panel.set_element(item_info.my_id)

	var stylebox_color = _info_panel.get_stylebox("panel").duplicate()
	ItemService.change_panel_stylebox_from_tier(stylebox_color, item_info.tier)
	_info_panel.add_stylebox_override("panel", stylebox_color)


func is_char_screen()->bool:
	return true


func is_locked_elements_displayed()->bool:
	return true
