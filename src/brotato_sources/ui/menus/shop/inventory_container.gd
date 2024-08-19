class_name InventoryContainer
extends VBoxContainer

export (int) var nb_columns = 8

onready var _label = $Label
onready var _elements = $ScrollContainer / MarginContainer / Elements


func _ready()->void :
	_elements.columns = nb_columns


func set_label(label:String)->void :
	_label.text = label


func set_data(label:String, category:int, elements:Array, reverse:bool = false, prioritize_gameplay_elements:bool = false)->void :
	_label.text = label
	_elements.category = category
	_elements.set_elements(elements, reverse, true, prioritize_gameplay_elements)


func focus_element_index(index:int)->void :
	_elements.focus_element_index(index)
