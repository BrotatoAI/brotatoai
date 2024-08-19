class_name SynergyContainer
extends VBoxContainer

const DIST = 5

var synergy_panels:Array = []


func _ready()->void :
	synergy_panels = get_children()


func set_synergies_text(item_data:ItemParentData)->void :

	rect_size = Vector2.ZERO

	for panel in synergy_panels:
		panel.rect_size = Vector2.ZERO
		panel.rect_min_size = Vector2.ZERO
		panel.hide()

	if not item_data is WeaponData:return 

	var i = 0

	for set in item_data.sets:
		synergy_panels[i].set_data(set)
		synergy_panels[i].show()
		i += 1


func set_pos_from(elt:Control)->void :
	rect_global_position.x = elt.rect_global_position.x + elt.rect_size.x + DIST
	rect_global_position.y = elt.rect_global_position.y
