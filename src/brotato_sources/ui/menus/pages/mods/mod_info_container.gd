class_name ModInfoContainer
extends PanelContainer

onready var _mod_name = $"%ModName" as Label
onready var _mod_version = $"%ModVersion" as Label
onready var _mod_description = $"%ModDescription" as RichTextLabel


func _ready()->void :
	set_empty()


func set_data(mod:ModData)->void :
	_mod_name.text = mod.manifest.name
	_mod_version.text = mod.manifest.version_number
	_mod_description.bbcode_text = mod.manifest.description


func set_empty()->void :
	_mod_name.text = ""
	_mod_version.text = ""
	_mod_description.bbcode_text = ""
