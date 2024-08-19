class_name ZoneUILocked
extends PanelContainer

onready var _description = $MarginContainer / VBoxContainer / Description


func focus()->void :
	pass


func set_zone_data(zone_data:ZoneData)->void :
	var challenge = ChallengeService.find_challenge_from_reward(RewardType.ZONE, zone_data)

	if challenge == null:
		_description.text = "NOT_SET"
		return 

	_description.text = challenge.description
