class_name UIItemElement
extends TextureRect

signal ui_element_mouse_entered(ui_element)
signal ui_element_mouse_exited(ui_element)

var item_data:Resource = null


func set_item_data(p_item_data:Resource)->void :
	item_data = p_item_data
	texture = p_item_data.icon


func _on_UIItemElement_mouse_entered()->void :
	emit_signal("ui_element_mouse_entered", self)


func _on_UIItemElement_mouse_exited()->void :
	emit_signal("ui_element_mouse_exited", self)
