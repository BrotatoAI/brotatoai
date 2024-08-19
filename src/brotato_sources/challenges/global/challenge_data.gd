class_name ChallengeData
extends ItemParentData

enum RewardType { ITEM, WEAPON, ZONE, STARTING_WEAPON, CONSUMABLE, UPGRADE, CHARACTER, DIFFICULTY }

export(String) var description = ""
export(RewardType) var reward_type = RewardType.ITEM
export(Resource) var reward
export(int) var number = 0
export(String) var stat = ""
export(Array) var additional_args = []


func get_title_args() -> Array:
	return [str(number)]


func get_desc_args() -> Array:
	if name.begins_with("CHARACTER_"):
		return [Text.text(name)]
	else:
		var args = [str(value), tr(stat.to_upper())]

		for arg in additional_args:
			args.push_back(tr(str(arg)))

		return args


func get_category() -> int:
	return Category.CHALLENGE
