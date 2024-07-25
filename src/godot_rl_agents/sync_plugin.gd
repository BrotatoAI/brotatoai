tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("Sync", "Node", preload("res://addons/godot_rl_agents/sync.gd"), preload("res://addons/godot_rl_agents/icon.png"))

func _exit_tree():
	remove_custom_type("Sync")
