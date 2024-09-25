extends Control

enum State{READY, BOOT_SPLASH, HIDE_SCENE, CHANGE_SCENE}
var state = State.READY


func _process(_delta:float):

	#match state:
	#	State.READY:
	#		pass
	#	State.BOOT_SPLASH:
	#		state = State.HIDE_SCENE
	#	State.HIDE_SCENE:
	#		
	#		$BlackRect.visible = true
	#		state = State.CHANGE_SCENE
	#	State.CHANGE_SCENE:
	ProgressData.apply_settings()
	
	# ANCHOR : Start game
	
	_init_character()
	_init_difficulty()
	_init_weapons()
	
	# RunData.invulnerable = true
	RunData.is_endless_run = true
	
	_start()
			
			# var _error = get_tree().change_scene("res://ui/menus/title_screen/title_screen.tscn")
func _init_character():
	var characters = ItemService.characters
	
	var selected_char = _find_by_id(characters, 'character_well_rounded')
	
	RunData.add_character(selected_char)
	
func _init_difficulty():
	var difficulties = ItemService.difficulties
	
	var selected_difficulty = _find_by_id(difficulties, 'difficulty_0')
	
	RunData.current_difficulty = selected_difficulty.value
	
func _init_weapons():
	var weapons = ItemService.weapons
	
	var selected_weapon = _find_by_id(weapons, 'weapon_smg_1')
	
	RunData.add_weapon(selected_weapon, true)
	# RunData.add_weapon(selected_weapon, true)
	
	RunData.add_starting_items_and_weapons()
	
func _start():
	RunData.init_elites_spawn()

	ProgressData.save()

	# for effect in element.item.effects:
	#	effect.apply()

	MusicManager.tween(0)
	RunData.current_run_accessibility_settings = ProgressData.settings.enemy_scaling.duplicate()
	ProgressData.save_status = SaveStatus.SAVE_OK
	var _error = get_tree().change_scene(MenuData.game_scene)	
	
	print_debug(_error)

func _find_by_id(array, id):
	for c in array:
		if c["my_id"] == id:
			return c
	return null

func _draw():
	if state == State.READY:
		state = State.BOOT_SPLASH
