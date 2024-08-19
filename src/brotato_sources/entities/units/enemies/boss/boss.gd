class_name Boss
extends Enemy

var change_state_sound = load("res://entities/units/enemies/boss/zombie_voice_general_emote_05.wav")

var _states: = []
var _current_state: = - 1
var elapsed_time = 0

onready var _states_container = $States
onready var life_bar:TextureProgress = $LifeBar


func init(zone_min_pos:Vector2, zone_max_pos:Vector2, player_ref:Node2D = null, entity_spawner_ref = null)->void :
	.init(zone_min_pos, zone_max_pos, player_ref, entity_spawner_ref)

	if RunData.effects["double_boss"] and RunData.current_wave == RunData.nb_of_waves:
		max_stats.health = round(max_stats.health * 0.75) as int
		current_stats.health = max_stats.health
	elif RunData.current_wave <= 12:
		max_stats.health = round(max_stats.health * 0.75) as int
		current_stats.health = max_stats.health

	for state in _states_container.get_children():
		state.movement_behavior.init(self)
		state.attack_behavior.init(self)
		_states.push_back([state.hp_start, state.timer_start, state.movement_behavior, state.attack_behavior])

	if not ProgressData.settings.hp_bar_on_bosses:
		life_bar.hide()

	var _error_hp_lifebar = connect("health_updated", self, "on_health_updated")


func take_damage(value:int, hitbox:Hitbox = null, dodgeable:bool = true, armor_applied:bool = true, custom_sound:Resource = null, base_effect_scale:float = 1.0)->Array:

	var dmg_value = value

	if RunData.effects["damage_against_bosses"] > 0:
		dmg_value = int(value * (1.0 + (Utils.get_stat("damage_against_bosses") / 100.0)))

	return .take_damage(dmg_value, hitbox, dodgeable, armor_applied, custom_sound, base_effect_scale)


func get_giant_factor()->float:
	return (RunData.effects["giant_crit_damage"] / 1000.0)


func die(knockback_vector:Vector2 = Vector2.ZERO, p_cleaning_up:bool = false)->void :
	.die(knockback_vector, p_cleaning_up)
	life_bar.hide()

	if not p_cleaning_up and elapsed_time <= ChallengeService.get_chal("chal_giant_slayer").value:
		ChallengeService.complete_challenge("chal_giant_slayer")


func _on_CheckStateTimer_timeout()->void :
	elapsed_time += 1
	for i in _states.size():
		if _current_state < i and (current_stats.health <= (max_stats.health * _states[i][0]) or elapsed_time >= _states[i][1]):
			on_state_changed(i)
			SoundManager.play(change_state_sound, 0, 0, true)
			_current_state = i
			_current_movement_behavior = _states[i][2]
			_current_attack_behavior = _states[i][3]


func on_state_changed(_new_state:int)->void :
	_can_move = true
	emit_signal("state_changed", self)


func on_health_updated(current_val:int, max_val:int)->void :
	if ProgressData.settings.hp_bar_on_bosses:
		if not life_bar.visible:
			life_bar.show()

		life_bar.update_value(current_val, max_val)
	elif life_bar.visible:
		life_bar.hide()
