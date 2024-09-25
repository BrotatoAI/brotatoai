extends Node

signal challenge_completed(challenge)

export (Array, Resource) var challenges: = []

var stat_challenges: = []


func _ready()->void :
	for chal in challenges:
		if chal.stat != "" and chal.my_id != "chal_advanced_technology":
			stat_challenges.push_back(chal)


func complete_challenge(chal_id:String)->void :

	if RunData.is_testing:return 

	# var steam_achievement = Steam.getAchievement(chal_id)

	# if not steam_achievement.achieved:
	#	var _achievement = Steam.setAchievement(chal_id)
	#	var _stored = Steam.storeStats()

	if ProgressData.challenges_completed.has(chal_id):return 

	var chal_data = null

	for chal in challenges:
		if chal.my_id == chal_id:
			chal_data = chal
			break

	if chal_data == null:
		print("challenge data not found for my_id " + str(chal_id))
		return 

	ProgressData.challenges_completed.push_back(chal_id)

	unlock_reward(chal_data)

	ProgressData.save()

	emit_signal("challenge_completed", chal_data)


func unlock_reward(chal_data:ChallengeData)->void :

	if not chal_data.reward:
		return 

	var list_to_unlock_from: = []
	var list_of_unlocked: = []

	var id_property = "my_id"

	match chal_data.reward_type:
		RewardType.CHARACTER:
			list_to_unlock_from = ItemService.characters
			list_of_unlocked = ProgressData.characters_unlocked
		RewardType.ITEM:
			list_to_unlock_from = ItemService.items
			list_of_unlocked = ProgressData.items_unlocked
		RewardType.WEAPON:
			list_to_unlock_from = ItemService.weapons
			list_of_unlocked = ProgressData.weapons_unlocked
			id_property = "weapon_id"
		RewardType.ZONE:
			list_to_unlock_from = ZoneService.zones
			list_of_unlocked = ProgressData.zones_unlocked
		RewardType.STARTING_WEAPON:
			list_to_unlock_from = ItemService.weapons
			list_of_unlocked = ProgressData.weapons_unlocked
			id_property = "weapon_id"
		RewardType.CONSUMABLE:
			list_to_unlock_from = ItemService.consumables
			list_of_unlocked = ProgressData.consumables_unlocked
		RewardType.UPGRADE:
			list_to_unlock_from = ItemService.upgrades
			list_of_unlocked = ProgressData.upgrades_unlocked
			id_property = "upgrade_id"

	for element in list_to_unlock_from:
		if element[id_property] == chal_data.reward[id_property]:
			if not list_of_unlocked.has(chal_data.reward[id_property]):
				list_of_unlocked.push_back(chal_data.reward[id_property])
				RunData.challenges_completed_this_run.push_back(chal_data)
				break


func find_challenge_from_reward(reward_type:int, reward_data:Resource)->ChallengeData:
	var challenge_result = null

	for challenge in challenges:
		if challenge.reward_type != reward_type:
			continue

		if challenge.reward.my_id == reward_data.my_id:
			challenge_result = challenge
			break

	return challenge_result


func get_chal(my_id:String)->ChallengeData:
	for chal in challenges:
		if chal.my_id == my_id:
			return chal

	return null


func check_counted_challenges()->void :

	if RunData.is_testing:return 

	var nb_killed = ProgressData.data.enemies_killed
	var nb_collected = ProgressData.data.materials_collected
	var nb_trees = ProgressData.data.trees_killed

	for chal in challenges:
		if ((chal.name == "CHAL_SURVIVOR" and nb_killed >= chal.value)
			 or (chal.name == "CHAL_GATHERER" and nb_collected >= chal.value)
			 or (chal.name == "CHAL_LUMBERJACK" and nb_trees >= chal.value)):
			complete_challenge(chal.my_id)


func check_stat_challenges()->void :

	if RunData.is_testing:return 

	for chal in stat_challenges:

		var reached_goal = (
			(chal.value < 0 and Utils.get_stat(chal.stat) <= chal.value)
			 or (chal.value > 0 and Utils.get_stat(chal.stat) >= chal.value)
			 or (chal.value == 0 and Utils.get_stat(chal.stat) == chal.value)
		)

		if reached_goal:
			complete_challenge(chal.my_id)

	var chal_advanced_technology = get_chal("chal_advanced_technology")

	if Utils.get_stat("stat_ranged_damage") >= chal_advanced_technology.value and RunData.effects["structures"].size() >= chal_advanced_technology.additional_args[0]:
		complete_challenge("chal_advanced_technology")


func complete_all_challenges()->void :
	for chal in challenges:
		complete_challenge(chal.my_id)
