class_name StatsContainer
extends PanelContainer

enum Tab{PRIMARY, SECONDARY}

signal stat_focused(stat_button, stat_title, stat_value)
signal stat_unfocused()
signal stat_hovered(stat_button, stat_title, stat_value)
signal stat_unhovered()

var primary_stats:Array
var secondary_stats:Array
var _focused_tab:int = Tab.PRIMARY

onready var _primary_tab = $"%Primary" as Button
onready var _secondary_tab = $"%Secondary" as Button
onready var _general_stats = $"%GeneralStats"
onready var _primary_stats = $"%PrimaryStats"
onready var _secondary_stats = $"%SecondaryStats"


func _ready()->void :
	primary_stats = _primary_stats.get_children()
	secondary_stats = _secondary_stats.get_children()

	update_tab(_focused_tab)

	for stat in primary_stats:
		stat.connect("focused", self, "on_stat_focused")
		stat.connect("unfocused", self, "on_stat_unfocused")
		stat.connect("hovered", self, "on_stat_hovered")
		stat.connect("unhovered", self, "on_stat_unhovered")


func _input(event:InputEvent)->void :
	if event is InputEventJoypadButton and (event.is_action_pressed("ltrigger") or event.is_action_pressed("rtrigger")):
		if _focused_tab == Tab.PRIMARY:
			update_tab(Tab.SECONDARY)
		else :
			update_tab(Tab.PRIMARY)


func disable_focus_except_mouse()->void :
	for stat_container in primary_stats:
		stat_container.disable_focus_except_mouse()


func set_neighbour_right(node:Node)->void :
	for stat_container in primary_stats:
		stat_container.set_neighbour_right(node)


func update_stats()->void :
	for stat in primary_stats:
		stat.update_stat()
	for stat in secondary_stats:
		stat.update_stat()


func enable_focus()->void :
	for stat in primary_stats:
		stat.enable_focus()


func disable_focus()->void :
	for stat in primary_stats:
		stat.disable_focus()


func on_stat_focused(stat_button, stat_title, stat_value)->void :
	emit_signal("stat_focused", stat_button, stat_title, stat_value)


func on_stat_unfocused()->void :
	emit_signal("stat_unfocused")


func on_stat_hovered(stat_button, stat_title, stat_value)->void :
	emit_signal("stat_hovered", stat_button, stat_title, stat_value)


func on_stat_unhovered()->void :
	emit_signal("stat_unhovered")


func _on_Primary_pressed()->void :
	update_tab(Tab.PRIMARY)


func _on_Secondary_pressed()->void :
	update_tab(Tab.SECONDARY)


func update_tab(tab:int)->void :
	_focused_tab = tab

	if tab == Tab.PRIMARY:
		_primary_tab.flat = true
		_secondary_tab.flat = false
		_general_stats.show()
		_primary_stats.show()
		_secondary_stats.hide()
	else :
		_primary_tab.flat = false
		_secondary_tab.flat = true
		_secondary_stats.show()
		_general_stats.hide()
		_primary_stats.hide()
