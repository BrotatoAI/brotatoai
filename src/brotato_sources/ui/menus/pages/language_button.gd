class_name LanguageButton
extends OptionButton


func _ready()->void :
	for key in ProgressData.languages:
		add_item(Utils.get_lang_key(ProgressData.languages.get(key)))
