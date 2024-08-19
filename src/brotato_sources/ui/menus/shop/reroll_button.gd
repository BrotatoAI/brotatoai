class_name RerollButton
extends ButtonWithIcon


func init(value:int)->void :
	set_value(value, RunData.gold)
	set_text((tr("REROLL") + " - " + str(value)).to_upper())
