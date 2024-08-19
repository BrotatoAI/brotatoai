class_name WeaponsContainer
extends Node2D


onready var _one_weapon_attachment_1 = $One / Attach1

onready var _two_weapons_attachment_1 = $Two / Attach1
onready var _two_weapons_attachment_2 = $Two / Attach2

onready var _three_weapons_attachment_1 = $Three / Attach1
onready var _three_weapons_attachment_2 = $Three / Attach2
onready var _three_weapons_attachment_3 = $Three / Attach3

onready var _four_weapons_attachment_1 = $Four / Attach1
onready var _four_weapons_attachment_2 = $Four / Attach2
onready var _four_weapons_attachment_3 = $Four / Attach3
onready var _four_weapons_attachment_4 = $Four / Attach4

onready var _five_weapons_attachment_1 = $Five / Attach1
onready var _five_weapons_attachment_2 = $Five / Attach2
onready var _five_weapons_attachment_3 = $Five / Attach3
onready var _five_weapons_attachment_4 = $Five / Attach4
onready var _five_weapons_attachment_5 = $Five / Attach5

onready var _six_weapons_attachment_1 = $Six / Attach1
onready var _six_weapons_attachment_2 = $Six / Attach2
onready var _six_weapons_attachment_3 = $Six / Attach3
onready var _six_weapons_attachment_4 = $Six / Attach4
onready var _six_weapons_attachment_5 = $Six / Attach5
onready var _six_weapons_attachment_6 = $Six / Attach6


func update_weapons_positions(weapons:Array)->void :
	if weapons.size() == 1:
		weapons[0].attach(_one_weapon_attachment_1.position, 0)
	elif weapons.size() == 2:
		weapons[0].attach(_two_weapons_attachment_1.position, 0)
		weapons[1].attach(_two_weapons_attachment_2.position, 0)
	elif weapons.size() == 3:
		weapons[0].attach(_three_weapons_attachment_1.position, 0)
		weapons[1].attach(_three_weapons_attachment_2.position, 0)
		weapons[2].attach(_three_weapons_attachment_3.position, 0)
	elif weapons.size() == 4:
		weapons[0].attach(_four_weapons_attachment_1.position, 0)
		weapons[1].attach(_four_weapons_attachment_2.position, 0)
		weapons[2].attach(_four_weapons_attachment_3.position, 0)
		weapons[3].attach(_four_weapons_attachment_4.position, 0)
	elif weapons.size() == 5:
		weapons[0].attach(_five_weapons_attachment_1.position, 0)
		weapons[1].attach(_five_weapons_attachment_2.position, 0)
		weapons[2].attach(_five_weapons_attachment_3.position, 0)
		weapons[3].attach(_five_weapons_attachment_4.position, 0)
		weapons[4].attach(_five_weapons_attachment_5.position, 0)
	elif weapons.size() == 6:
		weapons[0].attach(_six_weapons_attachment_1.position, 0)
		weapons[1].attach(_six_weapons_attachment_2.position, 0)
		weapons[2].attach(_six_weapons_attachment_3.position, 0)
		weapons[3].attach(_six_weapons_attachment_4.position, 0)
		weapons[4].attach(_six_weapons_attachment_5.position, 0)
		weapons[5].attach(_six_weapons_attachment_6.position, 0)
	else :
		for i in weapons.size():
			var r = 60 + (weapons.size() - 6) * 5
			var angle = i * ((2 * PI) / weapons.size())

			weapons[i].attach(Vector2(r * cos(angle), r * sin(angle)), 0)
