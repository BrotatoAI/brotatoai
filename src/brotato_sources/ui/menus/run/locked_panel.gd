class_name LockedPanel
extends PanelContainer

onready var _description = $MarginContainer / VBoxContainer / Description


func set_element(element:ItemParentData, type:int)->void :
	var challenge = ChallengeService.find_challenge_from_reward(type, element)

	if challenge == null:
		_description.text = "NOT_SET"
		return 

	_description.text = Text.text(challenge.description, challenge.get_desc_args())
