class_name UpgradesUI
extends Control

signal upgrade_selected

var _reroll_price: = 0
var _level = 0
var _old_upgrades = []
var _button_pressed: = false

onready var _upgrade_ui_1 = $MarginContainer / Content / VBoxContainer / HBoxContainer2 / VBoxContainer / HBoxContainer / UpgradeUI
onready var _upgrade_ui_2 = $MarginContainer / Content / VBoxContainer / HBoxContainer2 / VBoxContainer / HBoxContainer / UpgradeUI2
onready var _upgrade_ui_3 = $MarginContainer / Content / VBoxContainer / HBoxContainer2 / VBoxContainer / HBoxContainer / UpgradeUI3
onready var _upgrade_ui_4 = $MarginContainer / Content / VBoxContainer / HBoxContainer2 / VBoxContainer / HBoxContainer / UpgradeUI4
onready var _stats_container = $MarginContainer / Content / VBoxContainer / HBoxContainer2 / StatsContainer
onready var _focus_manager = $FocusManager
onready var _stat_popup = $MarginContainer / Content / StatPopup
onready var _reroll_button = $MarginContainer / Content / VBoxContainer / HBoxContainer2 / VBoxContainer / RerollButton
onready var _button_delay_timer = $ButtonDelayTimer


func _ready()->void :
	_upgrade_ui_1.connect("choose_button_pressed", self, "on_choose_button_pressed")
	_upgrade_ui_2.connect("choose_button_pressed", self, "on_choose_button_pressed")
	_upgrade_ui_3.connect("choose_button_pressed", self, "on_choose_button_pressed")
	_upgrade_ui_4.connect("choose_button_pressed", self, "on_choose_button_pressed")
	_reroll_price = ItemService.get_reroll_price(RunData.current_wave, RunData.current_wave)

	_focus_manager.init(
		null, 
		_stat_popup, 
		null, 
		null, 
		_stats_container, 
		null, 
		false
	)


func focus()->void :
	_upgrade_ui_2.focus()


func show_upgrade_options(level:int)->void :
	_reroll_button.init(_reroll_price)
	var upgrades = ItemService.get_upgrades(level, 4, _old_upgrades)
	_old_upgrades = upgrades
	_level = level
	_upgrade_ui_1.set_upgrade(upgrades[0])
	_upgrade_ui_2.set_upgrade(upgrades[1])
	_upgrade_ui_3.set_upgrade(upgrades[2])
	_upgrade_ui_4.set_upgrade(upgrades[3])
	_stats_container.update_stats()
	show()


func on_choose_button_pressed(upgrade_data:UpgradeData)->void :

	if _button_pressed:return 

	_button_pressed = true
	_button_delay_timer.start()

	hide()
	emit_signal("upgrade_selected", upgrade_data)
	LinkedStats.reset()
	_stats_container.update_stats()


func _on_UpgradesUI_visibility_changed()->void :
	_upgrade_ui_2.focus()


func _on_RerollButton_pressed()->void :
	if RunData.gold >= _reroll_price and not _button_pressed:
		_button_pressed = true
		_button_delay_timer.start()
		RunData.remove_gold(_reroll_price)
		_reroll_price = ItemService.get_reroll_price(RunData.current_wave, _reroll_price)
		show_upgrade_options(_level)


func _on_ButtonDelayTimer_timeout()->void :
	_button_pressed = false
