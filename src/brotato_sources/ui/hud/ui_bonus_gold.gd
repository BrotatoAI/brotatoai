class_name UIBonusold
extends HBoxContainer

const BOUNCE_COLOR: = Color(0.4, 1, 0.4, 1)
const BOUNCE_SCALE: = 1.2

onready var _gold_label = $GoldLabel
onready var _icon = $Icon
onready var _bounce_timer = $Timer


func _ready()->void :
	_gold_label.text = str(RunData.bonus_gold)


func update_value(new_value:int)->void :
	_gold_label.text = str(new_value)



func bounce()->void :
	show_bounce_animation(BOUNCE_SCALE)
	_bounce_timer.start()


func show_bounce_animation(scale:float)->void :
	rect_scale.x = scale
	rect_scale.y = scale


func _on_Timer_timeout()->void :
	show_bounce_animation(1)
