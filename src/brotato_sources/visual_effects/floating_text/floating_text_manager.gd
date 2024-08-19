class_name FloatingTextManager
extends Node2D

export (PackedScene) var _floating_text

export (Resource) var gold_on_crit_kill_icon
export (Resource) var harvesting_icon
export (Array, Resource) var stat_pos_sounds:Array
export (Array, Resource) var stat_neg_sounds:Array
export (Array, Resource) var harvest_pos_sounds:Array
export (Array, Resource) var harvest_neg_sounds:Array
export  var direction: = Vector2(0, - 80)
export  var duration: = 0.5
export  var spread = PI / 4

var available_floating_texts:Array

const MAX_TEXTS = 100

var current_nb_of_texts:int = 0
var player:Player
var _cleaning_up: = false


func _ready()->void :
	var _stat_add_error = RunData.connect("stat_added", self, "on_stat_added")
	var _stat_remove_error = RunData.connect("stat_removed", self, "on_stat_removed")

	var main = get_tree().current_scene
	
	for n in 50:
		var instance = _floating_text.instance()
		
		main.call_deferred("add_child", instance)
		instance.connect("available", self, "on_floating_text_available")
		instance.rect_position = Vector2( - 1000, - 1000)
		available_floating_texts.push_back(instance)

func on_enemy_state_changed(unit:Unit)->void :
	display("MUTATION", unit.global_position)


func on_levelled_up()->void :
	display("LEVEL_UP", player.global_position)


func on_harvested(value:int)->void :
	display_icon(value, harvesting_icon, harvest_pos_sounds, harvest_neg_sounds, player.global_position, Vector2(0, 50))


func on_stat_added(stat:String, value:int, db_mod:float = 0.0, pos_sounds:Array = stat_pos_sounds, neg_sounds:Array = stat_neg_sounds)->void :
	display_icon(value, ItemService.get_stat_icon(stat), pos_sounds, neg_sounds, player.global_position - Vector2(0, 50), direction, db_mod)


func on_stat_removed(stat:String, value:int, db_mod:float = 0.0, pos_sounds:Array = stat_pos_sounds, neg_sounds:Array = stat_neg_sounds)->void :
	on_stat_added(stat, - value, db_mod, pos_sounds, neg_sounds)


func display_icon(value:int, icon:Resource, pos_sounds:Array = [], neg_sounds:Array = [], pos:Vector2 = player.global_position - Vector2(0, 50), p_direction:Vector2 = direction, db_mod:float = 0.0)->void :
	if value > 0:
		display("+" + str(value), pos, Utils.GOLD_COLOR, icon, duration * 2, false, p_direction, false)

		if pos_sounds.size() > 0:
			SoundManager.play(Utils.get_rand_element(pos_sounds), - 3 + db_mod, 0.2, true)
	else :
		display(str(value), pos, Color.red, icon, duration * 2, false, p_direction, false)

		if neg_sounds.size() > 0:
			SoundManager.play(Utils.get_rand_element(neg_sounds), - 8 + db_mod, 0.2, true)


func _on_player_healed(unit:Unit, value:int)->void :
	if value > 0:
		display("+" + str(value), unit.global_position, Color.green, null, duration, false, direction, false)


func _on_unit_took_damage(unit:Unit, value:int, _knockback_direction:Vector2, _knockback_amount:float, is_crit:bool, is_miss:bool, is_dodge:bool, is_protected:bool, _effect_scale:float, hit_type:int)->void :

	if not ProgressData.settings.damage_display:
			return 

	var color:Color = Color.white
	var text = str(value)
	var always_display = false
	var need_translate = false

	if unit is Player:
		always_display = true
		if value > 0:
			color = Color.red
			text = "-" + text
		elif is_dodge:
			text = "DODGE"
			need_translate = true
		elif is_protected:
			text = "NULLIFIED"
			need_translate = true
	elif is_crit:
		color = Color.yellow
	elif is_miss:
		color = Color.darkgray
		text = text + ".."

	var icon = null if hit_type == 0 else get_special_hit_icon(hit_type)

	display(text, unit.global_position, color, icon, duration, always_display, direction, need_translate)


func get_special_hit_icon(_special_hit_type:int)->Resource:
	return gold_on_crit_kill_icon


func on_gold_picked_up(gold:Node)->void :
	if not _cleaning_up and gold.boosted > 1:
		display("x" + str(gold.boosted), gold.global_position, Utils.GOLD_COLOR, null, duration, false, direction, false)


func display(value:String, text_pos:Vector2, color:Color = Color.white, icon:Resource = null, p_duration:float = duration, always_display:bool = false, p_direction:Vector2 = direction, need_translate:bool = true)->void :

	if current_nb_of_texts > MAX_TEXTS and not always_display:
		return 

	var floating_text: = get_pooled_floating_text(text_pos)
	current_nb_of_texts += 1

	floating_text.set_message_translation(need_translate)

	floating_text.display(value, p_direction, p_duration, spread, color, true)

	if icon:
		var icon_inst = Sprite.new() as Sprite
		icon_inst.texture = icon
		icon_inst.scale = Vector2(0.5, 0.5)
		icon_inst.centered = false
		icon_inst.position.x = floating_text.get_minimum_size().x + 8
		floating_text.add_child(icon_inst)





func get_pooled_floating_text(text_pos:Vector2)->FloatingText:
	if (available_floating_texts.size() > 0):
		var instance = available_floating_texts.pop_back()
		if (instance and instance.get_parent()):
			instance.rect_position = text_pos
			return instance

	
	var instance = Utils.instance_scene_on_main(_floating_text, text_pos) as FloatingText
	instance.connect("available", self, "on_floating_text_available")
	return instance


func on_floating_text_available(instance:FloatingText)->void :
	current_nb_of_texts -= 1
	available_floating_texts.push_back(instance)


func get_color_from_value(value:int)->Color:
	if value < 50:return Color.white
	elif value < 100:return ItemService.TIER_UNCOMMON_COLOR
	elif value < 200:return ItemService.TIER_RARE_COLOR
	else :return ItemService.TIER_LEGENDARY_COLOR


func clean_up_room()->void :
	_cleaning_up = true
