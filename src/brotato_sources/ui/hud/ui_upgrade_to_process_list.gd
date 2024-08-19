class_name UIUpgradeToProcessList
extends HBoxContainer

signal ui_element_mouse_entered(ui_element, text)
signal ui_element_mouse_exited(ui_element)

export (PackedScene) var element_scene = null

var _elements: = []


func add_element(icon:Resource, level:int)->void :
	var new_element = element_scene.instance()
	new_element.set_data(icon, level)
	add_child(new_element)
	_elements.push_back(level)

	var _error_mouse_entered = new_element.connect("ui_element_mouse_entered", self, "on_ui_element_mouse_entered")
	var _error_mouse_exited = new_element.connect("ui_element_mouse_exited", self, "on_ui_element_mouse_exited")


func remove_element(level:int)->void :
	_elements.erase(level)

	var elements_nodes = get_children()

	for element in elements_nodes:
		if element.level == level:
			element.queue_free()
			element.disconnect("ui_element_mouse_entered", self, "on_ui_element_mouse_entered")
			element.disconnect("ui_element_mouse_exited", self, "on_ui_element_mouse_exited")
			break


func on_ui_element_mouse_entered(ui_element:Node)->void :
	emit_signal("ui_element_mouse_entered", ui_element, "INFO_LEVEL_UP")


func on_ui_element_mouse_exited(ui_element:Node)->void :
	emit_signal("ui_element_mouse_exited", ui_element)
