class_name ZoneSelection
extends Control

export (PackedScene) var zone_ui_scene = preload("res://ui/menus/run/zone_ui.tscn")
export (PackedScene) var zone_ui_locked_scene = preload("res://ui/menus/run/zone_ui_locked.tscn")

onready var _zone_container = $MarginContainer / VBoxContainer / ZoneContainer


func _ready()->void :

	for zone in ZoneService.zones:
		if ProgressData.zones_unlocked.has(zone.my_id):
			var zone_ui = zone_ui_scene.instance()
			_zone_container.add_child(zone_ui)
			zone_ui.set_zone_data(zone)
			var _error_1 = zone_ui.connect("choose_button_pressed", self, "on_choose_button_pressed")
		else :
			var zone_ui = zone_ui_locked_scene.instance()
			_zone_container.add_child(zone_ui)
			zone_ui.set_zone_data(zone)

	var zones = _zone_container.get_children()
	zones[0].focus()


func _input(event:InputEvent)->void :
	if event.is_action_pressed("ui_cancel"):
		RunData.reload_music = false
		var _error = get_tree().change_scene(MenuData.title_screen_scene)


func on_choose_button_pressed(zone:ZoneUI)->void :
	ProgressData.save()
	RunData.current_zone = zone.my_id
	var _error = get_tree().change_scene(MenuData.character_selection_scene)
