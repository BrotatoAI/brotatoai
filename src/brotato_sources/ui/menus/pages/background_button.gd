class_name BackgroundButton
extends OptionButton


func _ready()->void :
	add_item("RANDOM")
	for bg in RunData.backgrounds:
		add_item(bg.name)


func _on_BackgroundButton_item_selected(index:int)->void :
	if index != 0:
		icon = RunData.backgrounds[index - 1].icon
