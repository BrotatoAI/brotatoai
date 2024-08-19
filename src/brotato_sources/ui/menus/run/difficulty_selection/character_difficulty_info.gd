class_name CharacterDifficultyInfo
extends Reference

var character_id: = ""
var zones_difficulty_info: = []


func _init(p_character_id:String = "")->void :
	character_id = p_character_id


func serialize()->Dictionary:

	var zones_difficulty_info_serialized = []

	for zone_difficulty_info in zones_difficulty_info:
		zones_difficulty_info_serialized.push_back(zone_difficulty_info.serialize())

	return {
		"character_id":character_id, 
		"zones_difficulty_info":zones_difficulty_info_serialized
	}


func deserialize_and_merge(from_json:Dictionary)->void :

	character_id = from_json.character_id

	for zone_difficulty_info_json in from_json.zones_difficulty_info:
		for zone_difficulty_info in zones_difficulty_info:
			if zone_difficulty_info_json.zone_id == zone_difficulty_info.zone_id:
				zone_difficulty_info.deserialize_and_merge(zone_difficulty_info_json)
