class_name ModContainer
extends PanelContainer

signal mod_focused(mod_data)
signal mod_unfocused(mod_data)

var mod_data:ModData

onready var _mod_name = $"%ModName" as Button


func set_data(p_mod:ModData)->void :
	mod_data = p_mod
	_mod_name.text = mod_data.manifest.name


func _on_ModName_focus_entered()->void :
	emit_signal("mod_focused", mod_data)


func _on_ModName_mouse_entered()->void :
	emit_signal("mod_focused", mod_data)


func _on_ModName_focus_exited()->void :
	emit_signal("mod_unfocused", mod_data)


func _on_ModName_mouse_exited()->void :
	emit_signal("mod_unfocused", mod_data)
