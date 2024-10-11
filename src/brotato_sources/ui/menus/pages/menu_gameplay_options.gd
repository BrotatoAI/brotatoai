class_name MenuGameplayOptions
extends Control

signal hp_bar_on_character_changed(value)
signal darken_screen_changed(value)
signal back_button_pressed
signal character_highlighting_changed(value)
signal weapon_highlighting_changed(value)


onready var mouse_only_button = $"%MouseOnlyButton" as CheckButton
onready var manual_aim_button = $"%ManualAimButton" as CheckButton
onready var manual_aim_on_mouse_press_button = $"%ManualAimOnMousePressButton" as CheckButton
onready var hp_bar_button = $"%HPbarOnCharacterButton" as CheckButton
onready var boss_hp_bar_button = $"%BossHPBarButton" as CheckButton
onready var keep_lock_button = $"%KeepLockButton" as CheckButton
onready var score_storing_button = $"%ScoreStoringButton" as OptionButton
onready var enemy_health_slider = $"%EnemyHealthSlider"
onready var enemy_damage_slider = $"%EnemyDamageSlider"
onready var enemy_speed_slider = $"%EnemySpeedSlider"
onready var explosion_opacity_slider = $"%ExplosionOpacitySlider"
onready var projectile_opacity_slider = $"%ProjectileOpacitySlider"
onready var font_size_slider = $"%FontSizeSlider"
onready var character_highlighting_button = $"%CharacterHighlightingButton" as CheckButton
onready var weapon_highlighting_button = $"%WeaponHighlightingButton" as CheckButton
onready var projectile_highlighting_button = $"%ProjectileHighlightingButton" as CheckButton
onready var gold_sounds_button = $"%GoldSoundsButton" as CheckButton
onready var darken_screen_button = $"%DarkenScreenButton" as CheckButton


func init()->void :
	$BackButton.grab_focus()

	init_values_from_progress_data()


func init_values_from_progress_data()->void :
	mouse_only_button.pressed = ProgressData.settings.mouse_only
	manual_aim_button.pressed = ProgressData.settings.manual_aim
	manual_aim_on_mouse_press_button.pressed = ProgressData.settings.manual_aim_on_mouse_press
	hp_bar_button.pressed = ProgressData.settings.hp_bar_on_character
	boss_hp_bar_button.pressed = ProgressData.settings.hp_bar_on_bosses
	keep_lock_button.pressed = ProgressData.settings.keep_lock
	score_storing_button.select(ProgressData.settings.endless_score_storing)
	enemy_health_slider.set_value(ProgressData.settings.enemy_scaling.health)
	enemy_damage_slider.set_value(ProgressData.settings.enemy_scaling.damage)
	enemy_speed_slider.set_value(ProgressData.settings.enemy_scaling.speed)
	explosion_opacity_slider.set_value(ProgressData.settings.explosion_opacity)
	projectile_opacity_slider.set_value(ProgressData.settings.projectile_opacity)
	font_size_slider.set_value(ProgressData.settings.font_size)
	character_highlighting_button.pressed = ProgressData.settings.character_highlighting
	weapon_highlighting_button.pressed = ProgressData.settings.weapon_highlighting
	projectile_highlighting_button.pressed = ProgressData.settings.projectile_highlighting
	gold_sounds_button.pressed = ProgressData.settings.alt_gold_sounds
	darken_screen_button.pressed = ProgressData.settings.darken_screen


func _on_BackButton_pressed()->void :
	emit_signal("back_button_pressed")


func _on_MenuOptions_hide()->void :
	ProgressData.save()

# ANCHOR : Game options
func _on_MouseOnlyButton_toggled(button_pressed:bool)->void :
	ProgressData.settings.mouse_only = button_pressed


func _on_ManualAimButton_toggled(button_pressed:bool)->void :
	ProgressData.settings.manual_aim = button_pressed


func _on_ManualAimOnMousePressButton_toggled(button_pressed:bool)->void :
	ProgressData.settings.manual_aim_on_mouse_press = button_pressed


func _on_HPbarOnCharacterButton_toggled(button_pressed:bool)->void :
	ProgressData.settings.hp_bar_on_character = button_pressed
	emit_signal("hp_bar_on_character_changed", button_pressed)


func _on_BossHPBarButton_toggled(button_pressed:bool)->void :
	ProgressData.settings.hp_bar_on_bosses = button_pressed


func _on_KeepLockButton_toggled(button_pressed:bool)->void :
	ProgressData.settings.keep_lock = button_pressed


func _on_ScoreButton_item_selected(index:int)->void :
	ProgressData.settings.endless_score_storing = index


func _on_EnemyHealthSlider_value_changed(value)->void :
	ProgressData.settings.enemy_scaling.health = value


func _on_EnemyDamageSlider_value_changed(value)->void :
	ProgressData.settings.enemy_scaling.damage = value


func _on_EnemySpeedSlider_value_changed(value)->void :
	ProgressData.settings.enemy_scaling.speed = value


func _on_ExplosionOpacitySlider_value_changed(value)->void :
	ProgressData.settings.explosion_opacity = value


func _on_ProjectileOpacitySlider_value_changed(value)->void :
	ProgressData.settings.projectile_opacity = value


func _on_FontSizeSlider_value_changed(value)->void :
	ProgressData.set_font_size(value)


func _on_CharacterHighlightingButton_toggled(button_pressed:bool)->void :
	ProgressData.settings.character_highlighting = button_pressed
	emit_signal("character_highlighting_changed", button_pressed)


func _on_WeaponHighlightingButton_toggled(button_pressed:bool)->void :
	ProgressData.settings.weapon_highlighting = button_pressed
	emit_signal("weapon_highlighting_changed", button_pressed)


func _on_ProjectileHighlightingButton_toggled(button_pressed:bool)->void :
	ProgressData.settings.projectile_highlighting = button_pressed


func _on_GoldSoundsButton_toggled(button_pressed:bool)->void :
	ProgressData.settings.alt_gold_sounds = button_pressed


func _on_DarkenScreenButton_toggled(button_pressed:bool)->void :
	ProgressData.settings.darken_screen = button_pressed
	emit_signal("darken_screen_changed", button_pressed)


func _on_DefaultButton_pressed()->void :
	ProgressData.settings.merge(ProgressData.init_gameplay_options(), true)
	init_values_from_progress_data()
