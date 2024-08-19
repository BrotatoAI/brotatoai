extends Node

var keys_needing_operator: = {
	"stat_max_hp":[0], 
	"stat_damage":[0], 
	"stat_armor":[0], 
	"stat_crit_chance":[0], 
	"stat_luck":[0], 
	"stat_attack_speed":[0], 
	"stat_elemental_damage":[0], 
	"stat_hp_regeneration":[0], 
	"stat_lifesteal":[0], 
	"stat_melee_damage":[0], 
	"stat_percent_damage":[0], 
	"stat_dodge":[0], 
	"stat_engineering":[0], 
	"stat_range":[0], 
	"stat_ranged_damage":[0], 
	"stat_speed":[0], 
	"stat_harvesting":[0], 
	"xp_gain":[0], 
	"items_price":[0], 
	"weapons_price":[0], 
	"number_of_enemies":[0], 
	"map_size":[0], 
	"enemy_speed":[0], 
	"enemy_health":[0], 
	"enemy_damage":[0], 
	"effect_stack_stat":[0], 
	"effect_piercing_damage":[0], 
	"effect_weapon_specific_bonus":[0], 
	"effect_weapon_class_bonus":[0], 
	"effect_weapon_bonus":[0], 
	"effect_weapon_stack":[0, 3], 
	"effect_unique_weapon_bonus":[0, 2], 
	"effect_tier_iv_weapon_bonus":[0, 2], 
	"effect_tier_i_weapon_bonus":[0, 2], 
	"effect_consumable_heal":[0], 
	"effect_pickup_range":[0], 
	"effect_on_hit":[0], 
	"effect_chance_double_gold":[0], 
	"effect_heal_when_pickup_gold":[0], 
	"effect_item_box_gold":[0], 
	"effect_stat_while_not_moving":[0], 
	"effect_knockback":[0], 
	"effect_gain_stat_end_of_wave":[0], 
	"effect_gain_stat_for_every_stat":[0, 4], 
	"effect_gain_stat_for_every_perm_stat":[0, 4], 
	"effect_gain_stat_for_every_different_stat":[0, 4], 
	"effect_gain_stat_for_every_enemy":[0, 4], 
	"effect_gain_stat_for_every_tree":[0, 4], 
	"effect_gain_stat_every_killed_enemies":[0], 
	"effect_gold_drops":[0], 
	"effect_neutral_gold_drops":[0], 
	"effect_enemy_gold_drops":[0], 
	"effect_gain_pct_gold_start_wave":[0], 
	"effect_gain_pct_gold_start_wave_limited":[0], 
	"effect_free_shop_reroll":[0], 
	"effect_instant_gold_attracting":[0], 
	"explosion_size":[0], 
	"explosion_damage":[0], 
	"chal_stat_desc":[0], 
	"effect_additional_weapon_bonus":[2], 
	"effect_upgrade_random_weapon":[0], 
	"effect_gold_while_moving":[0], 
	"effect_gold_while_not_moving":[0, 2], 
	"effect_stat_while_moving":[0], 
	"effect_stat_next_wave":[0], 
	"effect_damage_against_bosses":[0], 
	"effect_consumable_stat_while_max":[0], 
	"effect_consumable_stat_while_max_limited":[0, 2], 
	"effect_heal_on_crit_kill":[0], 
	"effect_pct_start_wave_stat":[0], 
	"effect_pct_stack_stat":[0], 
	"effect_piercing_damage_short":[0], 
	"effect_stat_on_level_up":[0], 
	"effect_stat_below_half_health":[0], 
	"effect_temp_stat_on_dodge":[0], 
	"effect_projectiles":[0]
}

var keys_needing_percent: = {
	"effect_increase_stat_gains":[1], 
	"effect_reduce_stat_gains":[1], 
	"weapons_price":[0], 
	"number_of_enemies":[0], 
	"effect_burn_chance":[0], 
	"effect_start_wave_less_hp":[0], 
	"effect_deal_dmg_when_pickup_gold":[0], 
	"effect_deal_dmg_when_death":[0], 
	"effect_deal_dmg_when_heal":[0], 
	"effect_piercing_damage":[0], 
	"effect_piercing_damage_short":[0], 
	"effect_remove_speed":[0, 2], 
	"info_pos_stat_crit_chance":[0], 
	"info_neg_stat_crit_chance":[0], 
	"info_pos_stat_lifesteal":[0], 
	"info_neg_stat_lifesteal":[0], 
	"info_pos_stat_percent_damage":[0], 
	"info_neg_stat_percent_damage":[0], 
	"info_pos_stat_dodge":[0], 
	"info_neg_stat_dodge":[0], 
	"info_pos_stat_speed":[0], 
	"info_neg_stat_speed":[0], 
	"info_pos_stat_attack_speed":[0], 
	"info_neg_stat_attack_speed":[0], 
	"info_pos_stat_luck":[0], 
	"info_neg_stat_luck":[0], 
	"info_pos_stat_armor":[0], 
	"info_neg_stat_armor":[0], 
	"damage_scaling":[0], 
	"effect_pickup_range":[0], 
	"effect_chance_double_gold":[0], 
	"effect_gain_pct_gold_start_wave":[0], 
	"effect_gain_pct_gold_start_wave_limited":[0], 
	"effect_heal_when_pickup_gold":[0], 
	"effect_enemy_speed":[0], 
	"effect_recycling_gains":[0], 
	"map_size":[0], 
	"effect_dodge_cap":[0], 
	"effect_gold_on_crit_kill":[0], 
	"effect_heal_on_crit_kill":[0], 
	"effect_explode_custom":[0], 
	"effect_convert_stat_end_of_wave":[0], 
	"effect_convert_stat_temp_half_wave":[0], 
	"effect_gold_drops":[0], 
	"effect_neutral_gold_drops":[0], 
	"effect_enemy_gold_drops":[0], 
	"effect_harvesting_growth":[0], 
	"effect_instant_gold_attracting":[0], 
	"effect_explode_on_death":[0], 
	"effect_explode_on_consumable":[0], 
	"info_pos_stat_harvesting":[1], 
	"info_pos_stat_harvesting_limited":[1, 3], 
	"effect_burning_cooldown_reduction":[0], 
	"effect_explode_melee":[0], 
	"effect_gold_while_moving":[0], 
	"effect_gold_while_not_moving":[0], 
	"effect_deal_dmg_when_dodge":[0], 
	"effect_heal_when_dodge":[0], 
	"effect_damage_against_bosses":[0], 
	"effect_giant_crit_damage":[0, 1], 
	"effect_structures_cooldown_reduction":[0], 
	"effect_pct_start_wave_stat":[0], 
	"effect_pct_stack_stat":[0], 
	"effect_specific_item_price":[0], 
	"effect_accuracy":[0], 
}


func text(key:String, args:Array = [], arg_signs:Array = [])->String:

	if key == "[EMPTY]":
		return ""

	var text = tr(key)
	var before = ""
	var after = ""
	var sign_for_all_args = Sign.NEUTRAL
	var add_arg_front = false

	if args.size() > arg_signs.size() and arg_signs.size() > 0:
		sign_for_all_args = arg_signs[0]

	var args_needing_op = get_args_needing_operator(key.to_lower())
	var args_needing_percent = get_args_needing_percent(key.to_lower())

	
	if args_needing_op.size() > 0 and tr(key.to_upper()).find("{0}") == - 1:
		add_arg_front = true

	
	if add_arg_front:
		text = "{0} " + text

	for i in args.size():
		var checked_sign = sign_for_all_args

		if arg_signs.size() > 0:
			checked_sign = arg_signs[i]

		if checked_sign == Sign.POSITIVE:
			before = "[color=" + Utils.POS_COLOR_STR + "]"
			after = "[/color]"
		elif checked_sign == Sign.NEGATIVE:
			before = "[color=" + Utils.NEG_COLOR_STR + "]"
			after = "[/color]"
		elif checked_sign == Sign.NEUTRAL:
			before = ""
			after = ""

		text = text.replace("{" + str(i) + "}", before + get_value(args[i], args_needing_op.has(i), args_needing_percent.has(i)) + after)

	return text


func get_value(value:String, add_operators:bool, add_percent:bool)->String:
	if add_operators:
		value = get_operator(value) + value

	if add_percent:
		value = value + "%"

	return value


func get_operator(value:String)->String:
	return "+" if int(value) >= 0 else ""


func get_args_needing_operator(key:String)->Array:
	if keys_needing_operator.has(key):
		return keys_needing_operator[key]
	else :
		return []


func get_args_needing_percent(key:String)->Array:
	if keys_needing_percent.has(key):
		return keys_needing_percent[key]
	else :
		return []
