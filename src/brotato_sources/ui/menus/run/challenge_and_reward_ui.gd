class_name ChallengeAndRewardUI
extends VBoxContainer

onready var _chal_ui = $ProgressChallengeUI
onready var _item_panel_ui = $VBoxContainer / ItemPanelUI
onready var _zone_panel_ui = $VBoxContainer / ZonePanel
onready var _reward_label = $VBoxContainer / Label


func _ready()->void :
	modulate.a = 0
	_reward_label.hide()
	_zone_panel_ui.hide()
	_item_panel_ui.hide()


func set_challenge(challenge:ChallengeData, locked_icon:Texture = null)->void :
	modulate.a = 1
	var locked = true

	if ProgressData.challenges_completed.has(challenge.my_id):
		locked = false
		_reward_label.show()
		if challenge.reward_type == RewardType.ZONE:
			_zone_panel_ui.show()
			_zone_panel_ui.set_data(challenge.reward)
			_item_panel_ui.hide()
		else :
			_zone_panel_ui.hide()
			if challenge.reward:
				_item_panel_ui.show()
				_item_panel_ui.set_data(challenge.reward)
	else :
		_reward_label.hide()
		_zone_panel_ui.hide()
		_item_panel_ui.hide()

	_chal_ui.set_data(challenge, locked, locked_icon)
