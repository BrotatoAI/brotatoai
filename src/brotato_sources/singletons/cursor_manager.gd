extends Node

const normal_image = preload("res://ui/custom_cursor.png")
const manual_image = preload("res://ui/manual_cursor.png")
var current_image = null


func _ready()->void :
	pause_mode = PAUSE_MODE_PROCESS


func _process(_delta):
	var new_image = get_cursor_image()
	if new_image == current_image:
		return 
	var hotspot = get_cursor_hotspot(new_image)
	Input.set_custom_mouse_cursor(new_image, Input.CURSOR_ARROW, hotspot)
	current_image = new_image


func get_cursor_image()->Resource:
	var tree = get_tree()
	var current_scene = tree.current_scene
	var show_manual_cursor = (
		current_scene.has_method("show_manual_cursor")
		 and current_scene.show_manual_cursor()
		 and not tree.paused
	)
	return manual_image if show_manual_cursor else normal_image


func get_cursor_hotspot(cursor_image:Resource)->Vector2:
	match cursor_image:
		normal_image:return Vector2(3, 3)
		manual_image:return Vector2(35, 35)
		_:return Vector2(0, 0)
