class_name ItemDescription
extends VBoxContainer

signal mouse_hovered_category
signal mouse_exited_category

export (bool) var expand_indefinitely = true

var item:ItemParentData

onready var _icon = $HBoxContainer / IconPanel / Icon as TextureRect
onready var _name = $"%Name"
onready var _category = $"%Category"

onready var _vbox_container = $VBoxContainer
onready var _effects = $VBoxContainer / Effects as RichTextLabel
onready var _weapon_stats = $VBoxContainer / WeaponStats as RichTextLabel

onready var _scroll_container = $ScrollContainer as ScrollContainer
onready var _effects_scrolled = $ScrollContainer / VBoxContainer / Effects as RichTextLabel
onready var _weapon_stats_scrolled = $ScrollContainer / VBoxContainer / WeaponStats as RichTextLabel


func _ready()->void :
	if expand_indefinitely:
		_vbox_container.show()
	else :
		_scroll_container.show()


func set_item(item_data:ItemParentData)->void :

	get_effects().show()

	if item_data is WeaponData:
		get_weapon_stats().show()
		get_weapon_stats().bbcode_text = item_data.get_weapon_stats_text()
		_category.text = tr(ItemService.get_weapon_sets_text(item_data.sets))
	else :
		get_weapon_stats().hide()
		if item_data is CharacterData:
			_category.text = tr("CHARACTER")
		elif item_data is UpgradeData:
			_category.text = tr("UPGRADE")
		elif item_data is DifficultyData:
			_category.text = tr("DIFFICULTY")
		else :
			if item_data.max_nb == 1:
				_category.text = tr("UNIQUE")
			elif item_data.max_nb != - 1:
				_category.text = Text.text("LIMITED", [str(item_data.max_nb)])
			else :
				_category.text = tr("ITEM")

	if item_data is WeaponData or item_data is UpgradeData:
		var tier_number = ItemService.get_tier_number(item_data.tier)
		_name.text = tr(item_data.name) + (" " + tier_number if tier_number != "" else "")
	elif item_data is DifficultyData:
		_name.text = Text.text(tr(item_data.name), [str(item_data.value)])
	else :
		_name.text = item_data.name

	item = item_data
	_icon.texture = item_data.icon
	_name.modulate = ItemService.get_color_from_tier(item_data.tier)

	if item_data is DifficultyData and item_data.effects.size() == 0:
		get_effects().bbcode_text = item_data.description
	else :
		get_effects().bbcode_text = item_data.get_effects_text()


func get_weapon_stats()->Node2D:
	return _weapon_stats if expand_indefinitely else _weapon_stats_scrolled


func get_effects()->Node2D:
	return _effects if expand_indefinitely else _effects_scrolled


func _on_Category_mouse_entered()->void :
	emit_signal("mouse_hovered_category")


func _on_Category_mouse_exited()->void :
	emit_signal("mouse_exited_category")
