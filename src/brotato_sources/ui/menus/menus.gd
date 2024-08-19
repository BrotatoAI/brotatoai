class_name Menus
extends Control

signal menu_page_switched(from, to)

onready var _main_menu = $MainMenu
onready var _menu_general_options = $MenuGeneralOptions
onready var _menu_gameplay_options = $MenuGameplayOptions
onready var _menu_choose_options = $MenuChooseOptions

var _current_page:Control


func _ready()->void :
	var _error_options = _main_menu.connect("options_button_pressed", self, "on_options_button_pressed")
	var _error_back_choose_options = _menu_choose_options.connect("back_button_pressed", self, "on_choose_options_back_button_pressed")
	var _error_back_general_options = _menu_general_options.connect("back_button_pressed", self, "on_options_general_back_button_pressed")
	var _error_back_gameplay_options = _menu_gameplay_options.connect("back_button_pressed", self, "on_options_gameplay_back_button_pressed")
	var _error_general_choose_options = _menu_choose_options.connect("general_button_pressed", self, "on_options_general_button_pressed")
	var _error_gameplay_choose_options = _menu_choose_options.connect("gameplay_button_pressed", self, "on_options_gameplay_button_pressed")
	_current_page = _main_menu


func back()->void :
	if _current_page != _main_menu:
		switch(_current_page, _main_menu)


func reset()->void :
	switch(_current_page, _main_menu)


func on_options_button_pressed()->void :
	switch(_main_menu, _menu_choose_options)


func on_choose_options_back_button_pressed()->void :
	switch(_menu_choose_options, _main_menu)


func on_options_general_back_button_pressed()->void :
	switch(_menu_general_options, _menu_choose_options)


func on_options_gameplay_back_button_pressed()->void :
	switch(_menu_gameplay_options, _menu_choose_options)


func on_options_general_button_pressed()->void :
	switch(_menu_choose_options, _menu_general_options)


func on_options_gameplay_button_pressed()->void :
	switch(_menu_choose_options, _menu_gameplay_options)


func switch(from:Control, to:Control)->void :
	from.hide()
	to.show()
	to.init()
	_current_page = to
	emit_signal("menu_page_switched", from, to)
