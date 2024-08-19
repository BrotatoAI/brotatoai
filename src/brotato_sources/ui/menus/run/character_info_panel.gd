class_name CharacterInfoPanel
extends PanelContainer

onready var _max_diff_title = $MarginContainer / VBoxContainer / VBoxContainer / VBoxContainer / MaxDifficutlyBeatenTitle
onready var _max_diff_value = $MarginContainer / VBoxContainer / VBoxContainer / VBoxContainer / MaxDifficultyBeatenValue
onready var _max_endless_title = $MarginContainer / VBoxContainer / VBoxContainer / VBoxContainer2 / MaxEndlessWaveTitle
onready var _max_endless_value = $MarginContainer / VBoxContainer / VBoxContainer / VBoxContainer2 / MaxEndlessWaveValue


func set_element(character_id:String)->void :

	reset_all()

	var character_diff_data = ProgressData.get_character_difficulty_info(character_id, RunData.current_zone)

	var max_difficulty_data = ItemService.get_element(ItemService.difficulties, "", character_diff_data.max_difficulty_beaten.difficulty_value)
	var max_endless_diff_data = ItemService.get_element(ItemService.difficulties, "", character_diff_data.max_endless_wave_beaten.difficulty_value)

	if character_diff_data == null:
		_max_diff_title.text = "NOT_SET"
		return 

	if character_diff_data.max_difficulty_beaten.difficulty_value != - 1:
		var scaling_text = Utils.get_enemy_scaling_text(
			character_diff_data.max_difficulty_beaten.enemy_health, 
			character_diff_data.max_difficulty_beaten.enemy_damage, 
			character_diff_data.max_difficulty_beaten.enemy_speed
		)

		_max_diff_title.text = "MAX_DIFFICULTY_BEATEN"
		_max_diff_value.text = "%s%s" % [Text.text(max_difficulty_data.name, [str(max_difficulty_data.value)]), scaling_text]

	if character_diff_data.max_endless_wave_beaten.wave_number >= 0:
		var scaling_text = Utils.get_enemy_scaling_text(
			character_diff_data.max_endless_wave_beaten.enemy_health, 
			character_diff_data.max_endless_wave_beaten.enemy_damage, 
			character_diff_data.max_endless_wave_beaten.enemy_speed
		)
		_max_endless_title.text = "MAX_ENDLESS_WAVE_BEATEN"
		_max_endless_value.text = "%s - %s%s" % [Text.text("WAVE", [str(character_diff_data.max_endless_wave_beaten.wave_number)]), Text.text(max_endless_diff_data.name, [str(character_diff_data.max_endless_wave_beaten.difficulty_value)]), scaling_text]
	else :
		_max_endless_title.text = ""


func reset_all()->void :
	_max_diff_title.text = "MAX_DIFFICULTY_BEATEN"
	_max_diff_value.text = "NO_RECORDS_YET"
	_max_endless_title.text = ""
	_max_endless_value.text = ""
