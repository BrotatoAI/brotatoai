class_name InfoContainer
extends VBoxContainer

onready var _description = $PanelContainer / MarginContainer / Description


func display(text:String)->void :
	_description.bbcode_text = text
	show()
