class_name ProgressionUI
extends Node

export (Resource) var locked_icon

signal back_button_pressed

onready var _challenges = $VBoxContainer / HBoxContainer / ScrollContainer / MarginContainer / Inventory
onready var _challenge_and_rewards_ui = $VBoxContainer / HBoxContainer / ChallengeAndRewardUI


func _ready()->void :

	var possible_elements = ChallengeService.challenges
	var elts_unlocked = ProgressData.challenges_completed
	var elements = []

	for element in possible_elements:

		if element.reward_type == RewardType.DIFFICULTY:
			continue

		element.is_locked = not elts_unlocked.has(element.my_id)
		elements.push_back(element)

	_challenges.set_elements(elements)

	var _error_focused = _challenges.connect("element_focused", self, "on_element_focused")
	var _error_hovered = _challenges.connect("element_hovered", self, "on_element_focused")


func init()->void :
	$VBoxContainer / BackButton.grab_focus()


func on_element_focused(element:InventoryElement)->void :
	_challenge_and_rewards_ui.set_challenge(element.item, locked_icon)


func _on_BackButton_pressed()->void :
	emit_signal("back_button_pressed")
