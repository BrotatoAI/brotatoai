class_name Shop
extends Control

signal item_bought(item_data)

export (Array, Resource) var combine_sounds = []
export (Array, Resource) var recycle_sounds = []

var _reroll_price: = 0
var _last_reroll_price: = - 1
var _shop_items: = []
var _go_button_pressed: = false

var _initial_free_rerolls: = 0
var _free_rerolls: = 0

var _need_to_set_locked: = false

onready var _title = $Content / MarginContainer / HBoxContainer / VBoxContainer / HBoxContainer / Title
onready var _go_button = $Content / MarginContainer / HBoxContainer / VBoxContainer2 / GoButton
onready var _endless_button = $"%EndlessButton"
onready var _gold_label = $Content / MarginContainer / HBoxContainer / VBoxContainer / HBoxContainer / GoldUI / GoldLabel
onready var _weapons_container = $Content / MarginContainer / HBoxContainer / VBoxContainer / HBoxContainer3 / WeaponsContainer
onready var _items_container = $Content / MarginContainer / HBoxContainer / VBoxContainer / HBoxContainer3 / ItemsContainer
onready var _shop_items_container = $Content / MarginContainer / HBoxContainer / VBoxContainer / HBoxContainer2 / ShopItemsContainer
onready var _reroll_button = $Content / MarginContainer / HBoxContainer / VBoxContainer / HBoxContainer / RerollButton
onready var _item_popup = $Content / ItemPopup
onready var _block_background = $Content / BlockBackground
onready var _pause_menu = $PauseMenu
onready var _stats_container = $Content / MarginContainer / HBoxContainer / VBoxContainer2 / StatsContainer
onready var _stats_popup = $Content / StatPopup
onready var _synergy_popup = $Content / SynergyPopup as SynergyContainer
onready var _focus_manager = $FocusManager
onready var _elite_info_panel = $"%EliteInfoPanel"
onready var _elite_infobox = $"%EliteInfobox"


func _ready()->void :
	_initial_free_rerolls = RunData.effects["free_rerolls"]
	_free_rerolls = _initial_free_rerolls

	_endless_button.hide()

	if RunData.current_wave == 19 and not RunData.is_endless_run:
		_endless_button.show()
		_go_button.focus_neighbour_top = _endless_button.get_path()

	if not RunData.shop_effects_checked:
		if RunData.effects["destroy_weapons"]:
			RunData.remove_all_weapons()
			_stats_container.update_stats()

		if RunData.effects["upgrade_random_weapon"].size() > 0:
			for effect in RunData.effects["upgrade_random_weapon"]:

				var possible_upgrades = []

				for weapon in RunData.weapons:
					if weapon.upgrades_into != null and weapon.tier < RunData.effects["max_weapon_tier"]:
						possible_upgrades.push_back(weapon)

				if possible_upgrades.size() > 0:
					var weapon_to_upgrade = Utils.get_rand_element(possible_upgrades)
					on_item_combine_button_pressed(weapon_to_upgrade, true)
				else :
					RunData.add_stat(effect[0], effect[1])
					RunData.tracked_item_effects["item_anvil"] += effect[1]

			RunData.emit_stats_updated()
			_stats_container.update_stats()

	RunData.shop_effects_checked = true

	var next_elite_wave = - 1
	var next_elite_type = EliteType.ELITE

	for elite_spawn in RunData.elites_spawn:
		if elite_spawn[0] > RunData.current_wave:
			next_elite_wave = elite_spawn[0]
			next_elite_type = elite_spawn[1]
			break

	var key = "ELITE_APPEARING" if next_elite_type == EliteType.ELITE else "HORDE_APPEARING"

	if next_elite_wave != - 1:
		_elite_infobox.text = Text.text(key, [str(next_elite_wave)])

		if next_elite_wave == RunData.current_wave + 1:
			var stylebox_color = _elite_info_panel.get_stylebox("panel").duplicate()
			stylebox_color.border_color = Color.white
			_elite_info_panel.add_stylebox_override("panel", stylebox_color)

		_elite_info_panel.show()
	else :
		_elite_info_panel.hide()

	if RunData.resumed_from_state:
		_reroll_price = ProgressData.current_run_state.reroll_price
		_last_reroll_price = ProgressData.current_run_state.last_reroll_price
		_shop_items = ProgressData.current_run_state.shop_items
		_initial_free_rerolls = ProgressData.current_run_state.initial_free_rerolls
		_free_rerolls = ProgressData.current_run_state.free_rerolls

		RunData.resumed_from_state = false
		_need_to_set_locked = true
	else :
		if RunData.locked_shop_items.size() > 0:
			fill_shop_items_when_locked(RunData.locked_shop_items)
		else :
			_shop_items = ItemService.get_shop_items(RunData.current_wave, ItemService.NB_SHOP_ITEMS)

		if ProgressData.settings.keep_lock:
			_need_to_set_locked = true
		else :
			RunData.locked_shop_items = []

		_last_reroll_price = ItemService.get_reroll_price(RunData.current_wave, RunData.current_wave)

		set_reroll_button_price()

	_stats_container.set_neighbour_right(_go_button)

	_pause_menu.connect("paused", self, "on_paused")
	_pause_menu.connect("unpaused", self, "on_unpaused")
	_block_background.hide()

	_title.text = tr("MENU_SHOP") + " (" + Text.text("WAVE", [str(RunData.current_wave)]) + ")"
	_go_button.text = tr("MENU_GO") + " (" + Text.text("WAVE", [str(RunData.current_wave + 1)]) + ")"

	_shop_items_container.set_shop_items(_shop_items)

	if _need_to_set_locked:
		update_visual_locks()

	_reroll_button.init(_reroll_price)
	_gold_label.init()

	_weapons_container.set_data(get_weapons_label_text(), Category.WEAPON, RunData.weapons)
	_items_container.set_data("ITEMS", Category.ITEM, RunData.items, true, true)

	var _error_cancel_item = _item_popup.connect("item_cancel_button_pressed", self, "on_item_cancel_button_pressed")
	var _error_discard_item = _item_popup.connect("item_discard_button_pressed", self, "on_item_discard_button_pressed")
	var _error_combine_item = _item_popup.connect("item_combine_button_pressed", self, "on_item_combine_button_pressed")
	var _error_gold = RunData.connect("gold_changed", _gold_label, "update_gold")
	var _error_shop_item_bought = _shop_items_container.connect("shop_item_bought", self, "on_shop_item_bought")
	var _error_shop_item_focused = _shop_items_container.connect("shop_item_focused", self, "on_shop_item_focused")
	var _error_focus_lost = _shop_items_container.connect("focus_lost", self, "on_focus_lost")
	var _error_weapons_item_bought = connect("item_bought", _weapons_container._elements, "on_item_bought")
	var _error_items_item_bought = connect("item_bought", _items_container._elements, "on_item_bought")

	_focus_manager.init(_item_popup, _stats_popup, _weapons_container, _items_container, _stats_container, null)

	var _error_focused = _focus_manager.connect("element_focused", self, "on_element_focused")
	var _error_pressed = _focus_manager.connect("element_pressed", self, "on_element_pressed")
	var _error_focus_lost_inv = _focus_manager.connect("focus_lost", self, "on_focus_lost")

	var _error_category_hovered = _shop_items_container.connect("mouse_hovered_category", self, "on_mouse_hovered_category")
	var _error_category_exited = _shop_items_container.connect("mouse_exited_category", self, "on_mouse_exited_category")

	var focused_shop_item = _shop_items_container.focus()

	if focused_shop_item:
		hide_synergies(focused_shop_item)

	ProgressData.save_run_state(_shop_items, _reroll_price, _last_reroll_price, _initial_free_rerolls, _free_rerolls)


func update_visual_locks()->void :
	for i in _shop_items.size():
		for locked_item in RunData.locked_shop_items:
			if locked_item[0].my_id == _shop_items[i][0].my_id:
				_shop_items_container.lock_shop_item_visually(i)


func _input(event:InputEvent)->void :
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
		enable_shop_buttons_focus()


func on_paused()->void :
	ProgressData.save_run_state(_shop_items, _reroll_price, _last_reroll_price, _initial_free_rerolls, _free_rerolls)
	$Content.hide()


func on_unpaused()->void :
	$Content.show()
	on_focus_lost()


func get_weapons_label_text()->String:
	return tr("WEAPONS") + " (" + str(RunData.weapons.size()) + "/" + str(RunData.effects["weapon_slot"]) + ")"


func on_focus_lost()->void :
	if _reroll_price == 0:
		_reroll_button.grab_focus()
	else :
		_go_button.grab_focus()


func _on_GoButton_pressed()->void :
	if _go_button_pressed:
		return 

	ProgressData.save_run_state(_shop_items, _reroll_price, _last_reroll_price, _initial_free_rerolls, _free_rerolls)

	_go_button_pressed = true
	RunData.current_wave += 1
	MusicManager.tween(0)
	var _error = get_tree().change_scene(MenuData.game_scene)


func fill_shop_items_when_locked(locked_items:Array)->void :
	unlock_all_shop_items_visually()

	var prev_items = _shop_items

	_shop_items = []

	for i in locked_items.size():
		_shop_items.push_back(locked_items[i])

	if prev_items.size() == 0:
		prev_items.append_array(locked_items)

	var other_items = ItemService.NB_SHOP_ITEMS - locked_items.size()

	if other_items > 0:
		var items_to_add = ItemService.get_shop_items(RunData.current_wave, other_items, prev_items, locked_items)

		for item in items_to_add:
			_shop_items.push_back(item)


func _on_RerollButton_pressed()->void :
	if RunData.gold >= _reroll_price and RunData.locked_shop_items.size() < ItemService.NB_SHOP_ITEMS:
		RunData.remove_gold(_reroll_price)

		if RunData.locked_shop_items.size() > 0:
			fill_shop_items_when_locked(RunData.locked_shop_items)
		else :
			_shop_items = ItemService.get_shop_items(RunData.current_wave, ItemService.NB_SHOP_ITEMS, _shop_items)

		_shop_items_container.set_shop_items(_shop_items)

		for i in RunData.locked_shop_items.size():
			_shop_items_container.lock_shop_item_visually(i)

		set_reroll_button_price()
		_stats_container.update_stats()
		_shop_items_container.update_buttons_color()


func set_reroll_button_price()->void :

	if _free_rerolls > 0:
		_reroll_price = 0
		_free_rerolls -= 1

		if _shop_items.size() != 0:
			RunData.tracked_item_effects["item_dangerous_bunny"] += _last_reroll_price
	else :
		_reroll_price = _last_reroll_price
		_last_reroll_price = ItemService.get_reroll_price(RunData.current_wave, _last_reroll_price)

	_reroll_button.init(_reroll_price)


func on_shop_item_bought(shop_item:ShopItem)->void :
	for item in _shop_items:
		if item[0].my_id == shop_item.item_data.my_id:
			_shop_items.erase(item)
			break

	RunData.remove_currency(shop_item.value)

	var nb_coupons = RunData.get_nb_item("item_coupon")

	if nb_coupons > 0:
		var coupon_value = get_coupon_value()
		var coupon_effect = nb_coupons * (coupon_value / 100.0)
		var base_value = ItemService.get_value(shop_item.wave_value, shop_item.item_data.value, false, shop_item.item_data is WeaponData, shop_item.item_data.my_id)
		RunData.tracked_item_effects["item_coupon"] += (base_value * coupon_effect) as int

	emit_signal("item_bought", shop_item.item_data)

	if shop_item.item_data.get_category() == Category.ITEM:
		RunData.add_item(shop_item.item_data)
	elif shop_item.item_data.get_category() == Category.WEAPON:
		if not RunData.has_weapon_slot_available(shop_item.item_data.type):
			for weapon in RunData.weapons:
				if weapon.my_id == shop_item.item_data.my_id and weapon.upgrades_into != null:
					var _weapon = RunData.add_weapon(shop_item.item_data)
					on_item_combine_button_pressed(weapon)
					break
		else :
			var _weapon = RunData.add_weapon(shop_item.item_data)
			_weapons_container.set_label(get_weapons_label_text())

	_stats_container.update_stats()
	_shop_items_container.reload_shop_items_descriptions()

	var has_new_rerolls = false

	if RunData.effects["free_rerolls"] > _initial_free_rerolls:
		var new_rerolls = RunData.effects["free_rerolls"] - _initial_free_rerolls
		_initial_free_rerolls = RunData.effects["free_rerolls"]
		_free_rerolls += new_rerolls
		has_new_rerolls = true

	if _shop_items.size() == 0:

		if _reroll_price == 0:
			_free_rerolls += 1

		_free_rerolls += 1
		has_new_rerolls = true

	if has_new_rerolls:
		set_reroll_button_price()
	else :
		_reroll_button.set_color_from_currency(RunData.gold)


func on_item_combine_button_pressed(weapon_data:WeaponData, is_upgrade:bool = false)->void :
	_focus_manager.reset_focus()

	var nb_to_remove = 2
	var removed_weapons_tracked_value = 0

	if is_upgrade:
		nb_to_remove = 1

	_weapons_container._elements.remove_element(weapon_data, nb_to_remove)
	removed_weapons_tracked_value += RunData.remove_weapon(weapon_data)

	if not is_upgrade:
		removed_weapons_tracked_value += RunData.remove_weapon(weapon_data)

	reset_item_popup_focus()

	var new_weapon = RunData.add_weapon(weapon_data.upgrades_into)

	new_weapon.tracked_value = removed_weapons_tracked_value

	if is_upgrade:
		new_weapon.dmg_dealt_last_wave = weapon_data.dmg_dealt_last_wave

	_stats_container.update_stats()

	_weapons_container._elements.add_element(new_weapon)

	if Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN:
		_weapons_container._elements.focus_element(new_weapon)

	SoundManager.play(Utils.get_rand_element(combine_sounds), 0, 0.1, true)
	_weapons_container.set_label(get_weapons_label_text())


func on_item_discard_button_pressed(weapon_data:WeaponData)->void :
	RunData.add_recycled()
	_focus_manager.reset_focus()
	_weapons_container._elements.remove_element(weapon_data)
	var _weapon = RunData.remove_weapon(weapon_data)
	RunData.add_gold(ItemService.get_recycling_value(RunData.current_wave, weapon_data.value, true))
	RunData.update_recycling_tracking_value(weapon_data)

	var nb_coupons = RunData.get_nb_item("item_coupon")

	if nb_coupons > 0:
		var base_value = ItemService.get_recycling_value(RunData.current_wave, weapon_data.value, true, false)
		var actual_value = ItemService.get_recycling_value(RunData.current_wave, weapon_data.value, true)
		RunData.tracked_item_effects["item_coupon"] -= (base_value - actual_value) as int

	reset_item_popup_focus()
	_shop_items_container.update_buttons_color()
	_reroll_button.set_color_from_currency(RunData.gold)
	SoundManager.play(Utils.get_rand_element(recycle_sounds), 0, 0.1, true)


func get_coupon_value()->int:
	var coupon_value = 0
	for item in RunData.items:
		if item.my_id == "item_coupon":
			coupon_value = abs(item.effects[0].value)
			break
	return coupon_value


func reset_item_popup_focus()->void :
	_block_background.hide()
	_weapons_container.set_label(get_weapons_label_text())
	_stats_container.update_stats()


func on_item_cancel_button_pressed(weapon_data:WeaponData)->void :
	_focus_manager.reset_focus()
	_block_background.hide()
	if $Content.visible:
		_weapons_container._elements.focus_element(weapon_data)


func on_element_focused(_element:InventoryElement)->void :
	disable_shop_buttons_focus()
	disable_shop_lock_buttons_focus()
	_stats_container.disable_focus()


func on_element_pressed(element:InventoryElement)->void :
	if element.item is WeaponData:
		_block_background.show()
	else :
		on_focus_lost()


func disable_shop_buttons_focus()->void :
	_shop_items_container.disable_shop_buttons_focus()


func enable_shop_buttons_focus()->void :
	_shop_items_container.enable_shop_buttons_focus()


func disable_shop_lock_buttons_focus()->void :
	_shop_items_container.disable_shop_lock_buttons_focus()


func enable_shop_lock_buttons_focus()->void :
	_shop_items_container.enable_shop_lock_buttons_focus()


func unlock_all_shop_items_visually()->void :
	_shop_items_container.unlock_all_shop_items_visually()


func update_locks_visually()->void :
	_shop_items_container.update_locks_visually()


func on_mouse_hovered_category(shop_item:ShopItem)->void :
	show_synergies(shop_item)


func on_mouse_exited_category(shop_item:ShopItem)->void :
	hide_synergies(shop_item)


func on_shop_item_focused(_shop_item:ShopItem)->void :
	_stats_container.disable_focus()


func show_synergies(shop_item:ShopItem)->void :
	if shop_item.item_data is WeaponData:
		_synergy_popup.show()
		_synergy_popup.set_synergies_text(shop_item.item_data)
		_synergy_popup.set_pos_from(shop_item)


func hide_synergies(shop_item:ShopItem)->void :
	if shop_item.item_data is WeaponData:
		_synergy_popup.hide()


func _on_RerollButton_focus_entered()->void :
	_stats_container.enable_focus()


func _on_EndlessButton_pressed()->void :
	RunData.is_endless_run = true
	_on_GoButton_pressed()
