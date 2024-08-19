tool 
extends EditorScript


func _run()->void :
	var dir = Directory.new()
	var new_file = File.new()
	var trans_file = File.new()
	var dir_path = "res://challenges/"

	new_file.open("res://tools/output/loc_file.vdf", File.WRITE)
	trans_file.open("res://resources/translations/translations.csv", File.READ)

	new_file.store_line("\"lang\" {")

	dir.open(dir_path)
	dir.list_dir_begin(true)

	var chals = get_chals(dir, dir_path)
	var language_keys = {}

	var csv = trans_file.get_csv_line()
	csv = trans_file.get_csv_line()

	for i in range(1, csv.size()):

		language_keys[i] = {}
		language_keys[i]["lang"] = csv[i]

		for chal in chals:
			var translated_values = get_translated_values(chal, i)
			language_keys[i][chal.my_id] = translated_values[0]
			language_keys[i][chal.my_id + "_desc"] = translated_values[1]

	store_language_keys_in_file(language_keys, new_file)

	new_file.store_line("}")

	print("loc_file updated")


func get_chals(dir:Directory, dir_path:String)->Array:
	var chals = []
	var file_name = dir.get_next()
	while file_name != "":

		if dir.current_is_dir():
			file_name = dir.get_next()
			continue

		var cur_file = load(dir_path + file_name)

		if cur_file.my_id != "":
			chals.push_back(cur_file)

		file_name = dir.get_next()
	return chals


func get_translated_values(challenge:ChallengeData, lang:int)->Array:
	var title_loc = challenge.name
	var desc_loc = challenge.description

	var trans_file = File.new()
	trans_file.open("res://resources/translations/translations.csv", File.READ)

	while not trans_file.eof_reached():
		var csv = trans_file.get_csv_line()

		var loc_key = csv[0]

		if challenge.name == loc_key:
			var args = [str(challenge.number)]
			title_loc = get_text(csv[lang], args)
		elif challenge.description == loc_key:
			var args = []
			if challenge.name.begins_with("CHARACTER_"):
				args = [get_translation(challenge.name, lang)]
			else :
				args = [str(challenge.value)]
				if challenge.stat:
					args.push_back(get_translation(challenge.stat.to_upper(), lang))

			for additional_arg in challenge.additional_args:
				args.push_back(get_translation(str(additional_arg), lang))

			desc_loc = get_text(csv[lang], args)

	return [title_loc, desc_loc]


func get_translation(key:String, lang:int)->String:
	var trans_file = File.new()
	trans_file.open("res://resources/translations/translations.csv", File.READ)
	while not trans_file.eof_reached():
		var csv = trans_file.get_csv_line()
		if csv[0] == key:
			return csv[lang]

	return key


func get_text(text:String, args:Array)->String:

	for i in args.size():
		text = text.replace("{" + str(i) + "}", args[i])

	return text


func store_language_keys_in_file(language_keys:Dictionary, new_file:File)->void :
	for lang_key in language_keys.keys():

		new_file.store_line("\"" + language_keys[lang_key]["lang"] + "\" {")
		new_file.store_line("\"Tokens\" {")

		for key in language_keys[lang_key].keys():
			if key == "lang":continue
			new_file.store_line("\"" + key + "\" \"" + language_keys[lang_key][key] + "\"")

		new_file.store_line("}")
		new_file.store_line("}")
