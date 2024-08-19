tool 
extends EditorScript

var temp = {}

func _run()->void :
	var dir = Directory.new()
	var dir_path = "res://items/"




	dir.open(dir_path)
	dir.list_dir_begin(true)

	update(dir, dir_path)


func update(dir:Directory, dir_path:String)->void :
	var file_name = dir.get_next()
	while file_name != "":

		if dir.current_is_dir():

			var new_dir = Directory.new()
			new_dir.open(dir_path + file_name)
			new_dir.list_dir_begin(true)
			update(new_dir, dir_path + file_name + "/")

		if file_name.ends_with(".tres"):

			var cur_file = load(dir_path + file_name)

			if cur_file is ItemParentData:

				var txt = ""

				for effect in cur_file.effects:
					if effect.text_key.to_upper() == "EFFECT_GAIN_STAT_FOR_EVERY_STAT" or effect.text_key.to_upper() == "EFFECT_GAIN_STAT_FOR_EVERY_PERM_STAT":
						print(cur_file.my_id)

		file_name = dir.get_next()
