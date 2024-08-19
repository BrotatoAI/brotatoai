extends Node

const SECONDARY_FONT_COLOR = Color(234.0 / 255, 226.0 / 255, 176.0 / 255, 1)
const GOLD_COLOR = Color(118.0 / 255, 1, 118.0 / 255, 1)
const GRAY_COLOR_STR = "#555555"
const POS_COLOR_STR = "#00ff00"
const NEG_COLOR_STR = "red"

const EDGE_MAP_DIST = 64
const TILE_SIZE = 64

var physics_fps = ProjectSettings.get("physics/common/physics_fps")
var project_width = ProjectSettings.get_setting("display/window/size/width")
var project_height = ProjectSettings.get_setting("display/window/size/height")
var _rng: = RandomNumberGenerator.new()

var projectile_outline_shadermat = preload("res://resources/shaders/projectile_outline_shadermat.tres")

var last_elt_selected = null


func _ready()->void :
	_rng.randomize()


func physics_one(delta:float)->float:
	return physics_fps * delta


func instance_scene_on_main(scene:PackedScene, position:Vector2)->Node:
	var main = get_tree().current_scene
	var instance = scene.instance()
	main.add_child(instance)

	if "global_position" in instance:
		instance.global_position = position
	elif "rect_position" in instance:
		instance.rect_position = position

	return instance


func is_facing_right(rotation_degrees:float)->bool:
	return rotation_degrees > - 90 and rotation_degrees < 90


func get_nearest(targets:Array, from:Vector2, min_distance: = 0, max_range: = 9999)->Array:
	var nearest_target: = []

	for target in targets:
		var dist_to_target = target.global_position.distance_to(from)
		if is_between(dist_to_target, min_distance, max_range) and (nearest_target.size() == 0 or dist_to_target < nearest_target[1]):
			nearest_target = [target, dist_to_target]

	return nearest_target


func is_between(number:int, min_value:int, max_value:int, including: = true)->bool:
	if including:
		return number >= min_value and number <= max_value
	else :
		return number > min_value and number < max_value


func get_effect_distance(unit:Unit)->float:
	return unit.sprite.texture.get_width() * 0.25


func get_random_int(from:int, to:int)->int:
	return _rng.randi_range(from, to)


func vectors_approx_equal(a:Vector2, b:Vector2, precision:float)->bool:
	return a.distance_to(b) <= precision


func get_direction_from_pos(pos:Vector2, min_pos:Vector2, max_pos:Vector2, distance:int)->int:
	var direction = Direction.NONE

	if pos.x <= min_pos.x + distance:
		direction = get_direction_from_side(Direction.LEFT, pos, min_pos, max_pos, distance)
	elif pos.x >= max_pos.x - distance:
		direction = get_direction_from_side(Direction.RIGHT, pos, min_pos, max_pos, distance)
	elif pos.y <= min_pos.y + distance:
		direction = Direction.TOP
	elif pos.y >= max_pos.y - distance:
		direction = Direction.BOTTOM

	return direction


func get_direction_from_side(side_checked:int, pos:Vector2, min_pos:Vector2, max_pos:Vector2, distance:int)->int:
	if pos.y <= min_pos.y + distance:
		return Direction.TOP if randf() > 0.5 else side_checked
	elif pos.y >= max_pos.y - distance:
		return Direction.BOTTOM if randf() > 0.5 else side_checked
	else :
		return side_checked


func get_rand_pos_from_direction_at_distance(direction:int, min_pos:Vector2, max_pos:Vector2, distance:int)->Vector2:
	var pos:Vector2 = Vector2.ZERO

	if direction == Direction.TOP:
		pos.x = rand_range(min_pos.x + distance, max_pos.x - distance)
		pos.y = min_pos.y + distance
	elif direction == Direction.BOTTOM:
		pos.x = rand_range(min_pos.x + distance, max_pos.x - distance)
		pos.y = max_pos.y - distance
	elif direction == Direction.RIGHT:
		pos.x = max_pos.x - distance
		pos.y = rand_range(min_pos.y + distance, max_pos.y - distance)
	elif direction == Direction.LEFT:
		pos.x = min_pos.x + distance
		pos.y = rand_range(min_pos.y + distance, max_pos.y - distance)

	return pos


func get_rand_pos_from_direction_within_distance(direction:int, min_pos:Vector2, max_pos:Vector2, distance:int)->Vector2:
	var pos:Vector2 = Vector2.ZERO
	var min_distance = Utils.EDGE_MAP_DIST

	if direction == Direction.TOP:
		pos.x = rand_range(min_pos.x + min_distance, max_pos.x - min_distance)
		pos.y = rand_range(min_pos.y + min_distance, min_pos.y + distance)
	elif direction == Direction.BOTTOM:
		pos.x = rand_range(min_pos.x + min_distance, max_pos.x - min_distance)
		pos.y = rand_range(max_pos.y - min_distance, max_pos.y - distance)
	elif direction == Direction.RIGHT:
		pos.x = rand_range(max_pos.x - distance, max_pos.x - min_distance)
		pos.y = rand_range(min_pos.y + min_distance, max_pos.y - min_distance)
	elif direction == Direction.LEFT:
		pos.x = rand_range(min_pos.x + min_distance, min_pos.x + distance)
		pos.y = rand_range(min_pos.y + min_distance, max_pos.y - min_distance)

	return pos


func get_rand_element(array:Array):
	return array[Utils.get_random_int(0, array.size() - 1)]


func get_chance_success(chance:float)->bool:
	
	
	if chance == 0.0:
		return false
	
	return randf() <= chance


func merge_dictionaries(a:Dictionary, b:Dictionary)->Dictionary:
	var c = a.duplicate(true)

	for key in b:
		if key in c:
			if a[key] is Dictionary and b[key] is Dictionary:
				c[key] = merge_dictionaries(a[key], b[key])
			else :
				c[key] = b[key]
		else :
			c[key] = b[key]

	return c


func get_lang_key(lang:String)->String:
	return "LANGUAGE_" + lang.to_upper()


func get_stat(stat_name:String)->float:
	return RunData.get_stat(stat_name) + TempStats.get_stat(stat_name) + LinkedStats.get_stat(stat_name)


func get_enemy_scaling_text(enemy_health:float, enemy_damage:float, enemy_speed:float, with_hyphen:bool = true)->String:

	var health = (enemy_health * 100) as int
	var damage = (enemy_damage * 100) as int
	var speed = (enemy_speed * 100) as int

	var text = " - " if with_hyphen else ""
	var difficulty_val = round(pow(health * damage * speed, 1 / 3.0))


	text += str(difficulty_val) + "%"

	if health == 100 and damage == 100 and speed == 100:
		text = ""

	return text


func get_scaling_stat_text(stat:String, scaling:float = 1.0)->String:
	var text = ""
	var w = 20 * ProgressData.settings.font_size


	var col = "[color=white]"






	var scaling_text = "" if scaling == 1.0 else col + str(round(scaling * 100.0)) + "%[/color]"


	var small_icon:Texture = ItemService.get_stat_small_icon(stat)

	text += "%s[img=%sx%s]%s[/img]" % [scaling_text, w, w, small_icon.resource_path]

	return text


func convert_stats(stats:Array, permanent:bool = true)->void :
	for stat_to_convert in stats:
		var pct = stat_to_convert.pct_converted / 100.0
		var stat_to_remove = stat_to_convert.key
		var stat_to_add = stat_to_convert.to_stat

		var stat_to_remove_value = RunData.gold if stat_to_remove == "materials" else RunData.get_stat(stat_to_remove) as int
		var nb_chunks_stat_removed = max(0, floor((stat_to_remove_value * pct) / stat_to_convert.value))

		if nb_chunks_stat_removed == 0:
			break

		var stat_removed_gain = RunData.get_stat_gain(stat_to_remove)
		var stat_added_gain = RunData.get_stat_gain(stat_to_add)

		var base_nb_stat_removed = nb_chunks_stat_removed * stat_to_convert.value
		var base_nb_stat_added = stat_to_convert.to_value * nb_chunks_stat_removed
		var actual_nb_stat_removed = base_nb_stat_removed
		var actual_nb_stat_added = base_nb_stat_added

		if stat_removed_gain > 0.0:
			actual_nb_stat_removed = round(base_nb_stat_removed / stat_removed_gain) as int
		if stat_added_gain > 0.0:
			actual_nb_stat_added = round(base_nb_stat_added / stat_added_gain) as int

		if stat_to_remove == "materials":
			RunData.remove_gold(actual_nb_stat_removed)
		else :
			if permanent:
				RunData.remove_stat(stat_to_remove, actual_nb_stat_removed)
			else :
				TempStats.remove_stat(stat_to_remove, actual_nb_stat_removed)

		if stat_to_add == "materials":
			RunData.add_gold(actual_nb_stat_added)
		else :
			if permanent:
				RunData.add_stat(stat_to_add, actual_nb_stat_added)
			else :
				TempStats.add_stat(stat_to_add, actual_nb_stat_added)
				RunData.emit_signal("stat_added", stat_to_add, base_nb_stat_added, 0.0)
	TempStats.emit_updated()
	RunData.emit_stats_updated()


func apply_cooldown_reduction(base_cooldown:float, base_scaling_stats:Array)->float:
	var new_cooldown = base_cooldown
	var scaling_stats = []

	for cd_red in base_scaling_stats:
		scaling_stats.push_back([cd_red[0], cd_red[1] / 100.0])

	var total_cd_red_pct = WeaponService.get_scaling_stats_value(scaling_stats) / 100.0

	if total_cd_red_pct > 0:
		new_cooldown = max(2, base_cooldown * (1 / (1 + total_cd_red_pct))) as int
	else :
		new_cooldown = max(2, base_cooldown * (1 + abs(total_cd_red_pct))) as int

	return new_cooldown
