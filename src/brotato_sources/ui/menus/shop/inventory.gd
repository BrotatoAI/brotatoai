class_name Inventory
extends GridContainer

signal instance_added(instance)
signal focus_lost
signal element_pressed(element)
signal element_hovered(element)
signal element_unhovered(element)
signal element_focused(element)
signal element_unfocused(element)

export (PackedScene) var element_scene = null

var locked_icon = load("res://items/global/locked_icon.png")
var category:int

var _elements: = []
var _reversed_order: = false


func on_item_bought(item_data:ItemParentData)->void :
	if item_data.get_category() != category:
		return 

	var check_for_duplicates = item_data.get_category() == Category.ITEM

	add_element(item_data, check_for_duplicates)


func set_elements(elements:Array, reverse_order:bool = false, replace:bool = true, prioritize_gameplay_elements:bool = false)->void :
	if elements == null or elements.size() == 0:return 

	if replace:
		clear_elements()

	_elements = elements.duplicate()

	if reverse_order:
		_reversed_order = true

	var check_for_duplicates = elements[0].get_category() == Category.ITEM

	for element in elements:
		if element.is_locked:
			add_special_element(locked_icon, false, 0.5, element)
		else :
			add_element(element, check_for_duplicates)

	if prioritize_gameplay_elements:
		var element_instances = get_children()

		for element_instance in element_instances:
			if element_instance.item is CharacterData:
				move_child(element_instance, 0)


func clear_elements()->void :
	for n in get_children():
		remove_child(n)
		n.queue_free()
	_elements.clear()


func focus_element_index(index:int)->void :
	var children = get_children()

	children[index].grab_focus()


func focus_element(element:ItemParentData)->void :
	for child in get_children():
		if child.item == element:
			child.grab_focus()
			break


func add_element(element:ItemParentData, check_for_duplicates:bool = false)->void :
	if check_for_duplicates:
		var children = get_children()
		var element_already_exists = false

		for child in children:
			if child.item != null and child.item.my_id == element.my_id:
				child.add_to_number()
				element_already_exists = true

		if not element_already_exists:
			spawn_element(element)
	else :
		spawn_element(element)


func remove_element(element:ItemParentData, nb_to_remove:int = 1)->void :
	var children = get_children()
	var index = 0
	var removed = 0

	for i in children.size():
		if children[i].item.my_id == element.my_id:
			children[i].queue_free()
			index = i
			removed += 1
			if removed == nb_to_remove:
				break

	if get_child_count() > 1:
		if index == 0:
			focus_element_index(1)
		else :
			focus_element_index(0)
	else :
		emit_signal("focus_lost")


func spawn_element(element:Resource)->void :
	var instance = element_scene.instance()
	add_child(instance)
	instance.set_element(element)

	if _reversed_order:
		move_child(instance, 0)

	connect_signals(instance)
	emit_signal("instance_added", instance)


func connect_signals(instance:InventoryElement)->void :
	var _error_hover = instance.connect("element_hovered", self, "on_element_hovered")
	var _error_unhover = instance.connect("element_unhovered", self, "on_element_unhovered")
	var _error_focus = instance.connect("element_focused", self, "on_element_focused")
	var _error_unfocus = instance.connect("element_unfocused", self, "on_element_unfocused")
	var _error_pressed = instance.connect("element_pressed", self, "on_element_pressed")


func add_special_element(p_icon:Texture, p_is_random:bool = false, p_alpha:float = 1, p_item:Resource = null)->void :
	var instance = element_scene.instance()
	add_child(instance)
	instance.is_special = true
	instance.is_random = p_is_random
	instance.modulate.a = p_alpha
	instance.icon = p_icon
	instance.item = p_item
	connect_signals(instance)


func on_element_hovered(element:InventoryElement)->void :
	emit_signal("element_hovered", element)


func on_element_unhovered(element:InventoryElement)->void :
	emit_signal("element_unhovered", element)


func on_element_focused(element:InventoryElement)->void :
	emit_signal("element_focused", element)


func on_element_unfocused(element:InventoryElement)->void :
	emit_signal("element_unfocused", element)


func on_element_pressed(element:InventoryElement)->void :
	emit_signal("element_pressed", element)
