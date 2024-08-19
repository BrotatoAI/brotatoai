extends TempStats

signal linked_stats_updated

var update_on_gold_chance: = false


func reset()->void :
	.reset()

	update_on_gold_chance = false

	for linked_stat in RunData.effects["stat_links"]:
		var stat_to_tweak = linked_stat[0]
		var stat_scaled = 0

		if linked_stat[2] == "materials":
			stat_scaled = RunData.gold
			update_on_gold_chance = true
		elif linked_stat[2] == "structure":
			stat_scaled = RunData.effects["structures"].size()
		elif linked_stat[2] == "living_enemy":
			stat_scaled = RunData.current_living_enemies
		elif linked_stat[2] == "living_tree":
			stat_scaled = RunData.current_living_trees
		elif linked_stat[2] == "common_item":
			stat_scaled = RunData.get_nb_different_items_of_tier(Tier.COMMON)
		elif linked_stat[2] == "legendary_item":
			stat_scaled = RunData.get_nb_different_items_of_tier(Tier.LEGENDARY)
		elif linked_stat[2].begins_with("item_"):
			stat_scaled = RunData.get_nb_item(linked_stat[2], false)
		else :
			if RunData.effects.has(linked_stat[2]):
				if linked_stat[4] == true:
					stat_scaled = RunData.get_stat(linked_stat[2])
				else :
					stat_scaled = RunData.get_stat(linked_stat[2]) + TempStats.get_stat(linked_stat[2])
			else :
				continue

		var amount_to_add = linked_stat[1] * (stat_scaled / linked_stat[3])

		add_stat(stat_to_tweak, amount_to_add)

	emit_updated()

func get_signal_name()->String:
	return "linked_stats_updated"
