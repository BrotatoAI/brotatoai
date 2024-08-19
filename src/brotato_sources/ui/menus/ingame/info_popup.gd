class_name InfoPopup
extends BasePopup

onready var _description = $PanelContainer / MarginContainer / Description


func display(from:Node, key:String)->void :
	_description.text = key
	element_from = from
	show()
