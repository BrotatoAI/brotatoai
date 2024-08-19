class_name EndlessButton
extends CheckButton

var focus_set: = false


func _ready()->void :
	pressed = ProgressData.settings.endless_mode_toggled


func _on_Inventory_instance_added(instance)->void :
	if focus_set:return 

	focus_set = true
	focus_neighbour_bottom = instance.get_path()
