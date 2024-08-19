class_name UIUpgradeToProcessElement
extends TextureRect

signal ui_element_mouse_entered(ui_element)
signal ui_element_mouse_exited(ui_element)

var level:int = 0


func set_data(icon:Resource, p_level:int)->void :
	level = p_level
	texture = icon


func _on_UIUpgradeToProcessElement_mouse_entered()->void :
	emit_signal("ui_element_mouse_entered", self)


func _on_UIUpgradeToProcessElement_mouse_exited()->void :
	emit_signal("ui_element_mouse_exited", self)
