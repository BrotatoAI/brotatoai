class_name UIGold
extends HBoxContainer

const BOUNCE_COLOR: = Color(0.4, 1, 0.4, 1)
const BOUNCE_SCALE: = 1.1

onready var _gold_label = $GoldLabel
onready var _icon = $Icon
onready var _bounce_timer = $Timer


func _ready()->void :
	_gold_label.text = str(RunData.gold)


func on_gold_changed(value:int)->void :
	_gold_label.text = str(value)



func bounce()->void :
	show_bounce_animation(Color.white, BOUNCE_SCALE)
	_bounce_timer.start()


func show_bounce_animation(color:Color, scale:float)->void :
	_icon.modulate = color
	rect_scale = Vector2(scale, scale)


func _on_Timer_timeout()->void :
	show_bounce_animation(Utils.GOLD_COLOR, 1)
