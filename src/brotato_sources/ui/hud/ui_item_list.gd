class_name UIItemList
extends HBoxContainer

signal ui_element_mouse_entered(ui_element, text)
signal ui_element_mouse_exited(ui_element)

export (PackedScene) var element_scene = null

var _elements: = []


func add_element(item_data:ItemParentData)->void :

	var new_element = element_scene.instance()
	new_element.set_item_data(item_data)
	add_child(new_element)
	_elements.push_back(item_data)

	var _error_mouse_entered = new_element.connect("ui_element_mouse_entered", self, "on_ui_element_mouse_entered")
	var _error_mouse_exited = new_element.connect("ui_element_mouse_exited", self, "on_ui_element_mouse_exited")


func remove_element(item_data:ItemParentData)->void :
	_elements.erase(item_data)

	var elements_nodes = get_children()

	for element in elements_nodes:
		if element.item_data == item_data:
			element.queue_free()
			element.disconnect("ui_element_mouse_entered", self, "on_ui_element_mouse_entered")
			element.disconnect("ui_element_mouse_exited", self, "on_ui_element_mouse_exited")
			break


func on_ui_element_mouse_entered(ui_element:Node)->void :
	emit_signal("ui_element_mouse_entered", ui_element, "INFO_ITEM_BOX")


func on_ui_element_mouse_exited(ui_element:Node)->void :
	emit_signal("ui_element_mouse_exited", ui_element)
