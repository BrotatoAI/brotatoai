class_name ZoneDifficultyInfo
extends Reference

var zone_id: = 0
var difficulty_selected_value: = 0
var max_selectable_difficulty: = 0
var max_difficulty_beaten: = DifficultyScore.new()
var max_endless_wave_beaten: = DifficultyScore.new()


func _init(p_zone_id:int = 0)->void :
	zone_id = p_zone_id


func serialize()->Dictionary:
	return {
		"zone_id":zone_id, 
		"difficulty_selected_value":difficulty_selected_value, 
		"max_selectable_difficulty":max_selectable_difficulty, 
		"max_difficulty_beaten":max_difficulty_beaten.serialize(), 
		"max_endless_wave_beaten":max_endless_wave_beaten.serialize()
	}


func deserialize_and_merge(from_json:Dictionary)->void :
	zone_id = from_json.zone_id
	difficulty_selected_value = from_json.difficulty_selected_value
	max_selectable_difficulty = from_json.max_selectable_difficulty
	max_difficulty_beaten.deserialize_and_merge(from_json.max_difficulty_beaten)
	max_endless_wave_beaten.deserialize_and_merge(from_json.max_endless_wave_beaten)

	if max_selectable_difficulty > ProgressData.overall_max_selectable_difficulty:
		ProgressData.overall_max_selectable_difficulty = max_selectable_difficulty
