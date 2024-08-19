class_name ChallengeUI
extends PanelContainer

var chal_data:ChallengeData

onready var _icon = $MarginContainer / VBoxContainer / HBoxContainer / Icon
onready var _name = $"%Name" as Label
onready var _description = $"%Description"


func set_data(p_chal_data:ChallengeData, locked:bool = false, locked_icon:Texture = null)->void :

	_name.self_modulate = Utils.SECONDARY_FONT_COLOR
	chal_data = p_chal_data

	if locked:
		_icon.texture = locked_icon
		_name.text = "???"
	else :
		_icon.texture = p_chal_data.icon
		_name.text = Text.text(p_chal_data.name, p_chal_data.get_title_args())

	_description.text = Text.text(p_chal_data.description, p_chal_data.get_desc_args())
