class_name GoldLabel
extends Label


func init()->void :
	text = str(RunData.gold)


func update_gold(new_value:int)->void :
	text = str(new_value)
