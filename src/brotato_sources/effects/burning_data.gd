class_name BurningData
extends Resource

enum BurningType{ELEMENTAL, ENGINEERING}

export (float) var chance: = 0.0
export (int) var damage: = 0
export (int) var duration: = 0
export (int) var spread: = 0
export (BurningType) var type: = BurningType.ELEMENTAL

var from:Node = null


func _init(p_chance:float = 0.0, p_damage:int = 0, p_duration:int = 0, p_spread:int = 0, p_type:int = 0)->void :
	chance = p_chance
	damage = p_damage
	duration = p_duration
	spread = p_spread
	type = p_type


func merge(p_burning_data:BurningData)->void :
	chance += p_burning_data.chance
	damage += p_burning_data.damage
	duration += p_burning_data.duration
	spread += p_burning_data.spread


func remove(p_burning_data:BurningData)->void :
	chance -= p_burning_data.chance
	damage -= p_burning_data.damage
	duration -= p_burning_data.duration
	spread -= p_burning_data.spread


func serialize()->Dictionary:
	return {
		"chance":chance, 
		"damage":damage, 
		"duration":duration, 
		"spread":spread, 
		"type":type
	}


func deserialize_and_merge(serialized:Dictionary)->void :
	chance = serialized.chance
	damage = serialized.damage as int
	duration = serialized.duration as int
	spread = serialized.spread as int
	type = serialized.type as int
