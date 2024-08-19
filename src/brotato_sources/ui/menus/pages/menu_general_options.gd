class_name MenuGeneralOptions
extends Control

signal back_button_pressed


onready var master_slider = $"%MasterSlider"
onready var sound_slider = $"%SoundSlider"
onready var music_slider = $"%MusicSlider"

onready var language_button = $"%LanguageButton" as OptionButton
onready var screenshake_button = $"%ScreenshakeButton" as CheckButton
onready var fullscreen_button = $"%FullScreenButton" as CheckButton
onready var visual_effects_button = $"%VisualEffectsButton" as CheckButton
onready var background_button = $"%BackgroundButton" as OptionButton
onready var damage_display_button = $"%DamageDisplayButton" as CheckButton
onready var optimize_end_waves_button = $"%OptimizeEndWavesButton" as CheckButton
onready var limit_fps_button = $"%LimitFPSButton" as CheckButton

onready var mute_on_focus_lost_button = $"%MuteOnFocusLostButton" as CheckButton
onready var pause_on_focus_lost_button = $"%PauseOnFocusLostButton" as CheckButton


func init()->void :
	$BackButton.grab_focus()

	master_slider.set_value(ProgressData.settings.volume.master )
	sound_slider.set_value(ProgressData.settings.volume.sound)
	music_slider.set_value(ProgressData.settings.volume.music)

	var i = 0

	for key in ProgressData.languages:
		if ProgressData.languages.get(key) == ProgressData.settings.language:
			language_button.select(i)
			break
		i += 1

	background_button.select(ProgressData.settings.background)
	background_button._on_BackgroundButton_item_selected(ProgressData.settings.background)

	visual_effects_button.pressed = ProgressData.settings.visual_effects
	screenshake_button.pressed = ProgressData.settings.screenshake
	fullscreen_button.pressed = ProgressData.settings.fullscreen
	damage_display_button.pressed = ProgressData.settings.damage_display
	optimize_end_waves_button.pressed = ProgressData.settings.optimize_end_waves
	limit_fps_button.pressed = ProgressData.settings.limit_fps

	mute_on_focus_lost_button.pressed = ProgressData.settings.mute_on_focus_lost
	pause_on_focus_lost_button.pressed = ProgressData.settings.pause_on_focus_lost


func _on_BackButton_pressed()->void :
	emit_signal("back_button_pressed")


func _on_MasterSlider_value_changed(value:float)->void :
	ProgressData.settings.volume.master = value
	set_volume(value, "Master")


func _on_SoundSlider_value_changed(value:float)->void :
	ProgressData.settings.volume.sound = value
	set_volume(value, "Sound")


func _on_MusicSlider_value_changed(value:float)->void :
	ProgressData.settings.volume.music = value
	set_volume(value, "Music")


func set_volume(value:float, bus:String)->void :
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), linear2db(value))


func _on_MenuOptions_hide()->void :
	ProgressData.save()


func _on_LanguageButton_item_selected(index:int)->void :

	var i = 0

	for key in ProgressData.languages:
		if i == index:
			ProgressData.settings.language = ProgressData.languages.get(key)
			TranslationServer.set_locale(ProgressData.languages.get(key))
			break
		i += 1


func _on_ScreenshakeButton_toggled(button_pressed:bool)->void :
	ProgressData.settings.screenshake = button_pressed


func _on_FullScreenButton_toggled(button_pressed:bool)->void :
	ProgressData.settings.fullscreen = button_pressed
	OS.window_fullscreen = button_pressed


func _on_BackgroundButton_item_selected(index:int)->void :
	ProgressData.settings.background = index
	RunData.reset_background()


func _on_VisualEffectsButton_toggled(button_pressed:bool)->void :
	ProgressData.settings.visual_effects = button_pressed


func _on_DamageDisplayButton_toggled(button_pressed:bool)->void :
	ProgressData.settings.damage_display = button_pressed


func _on_MuteOnFocusLostButton_toggled(button_pressed:bool)->void :
	ProgressData.settings.mute_on_focus_lost = button_pressed


func _on_PauseOnFocusLostButton_toggled(button_pressed:bool)->void :
	ProgressData.settings.pause_on_focus_lost = button_pressed


func _on_OptimizeEndWavesButton_toggled(button_pressed:bool)->void :
	ProgressData.settings.optimize_end_waves = button_pressed


func _on_LimitFPSButton_toggled(button_pressed:bool)->void :
	ProgressData.set_fps_limit(button_pressed)
