class_name ButtonWithIcon
extends MyMenuButtonParent

const MARGIN = 24.0

var _focused: = false
var _hovered: = false
var _pressed: = false
var _color_locked: = false
var _value: = 0

onready var _content = $HBoxContainer
onready var _label = $HBoxContainer / Label
onready var _gold_icon = $HBoxContainer / GoldIcon


func _ready()->void :
	_content.connect("resized", self, "on_content_resized")


func reinitialize_colors()->void :
	_color_locked = false
	_label.modulate = get_color("font_color")
	_focused = false
	_hovered = false
	_pressed = false

	set_color_from_currency()


func set_color_from_currency(currency:int = RunData.get_currency())->void :
	if currency < _value:
		_label.modulate = Color.red
		_color_locked = true
	else :
		_color_locked = false
		_label.modulate = get_color("font_color")


func on_content_resized():
	if (_content.rect_size.x > self.rect_min_size.x):
		self.rect_min_size.x = _content.rect_size.x + MARGIN
	if (_content.rect_size.y > self.rect_size.y):
		self.rect_min_size.y = _content.rect_size.y


func set_text(new_text:String)->void :
	_label.text = new_text


func set_value(value:int, currency:int = RunData.get_currency())->void :
	_value = value
	_label.text = str(value)
	set_color_from_currency(currency)


func _on_ButtonWithIcon_pressed()->void :
	on_pressed()
	if not _color_locked:
		_label.modulate = get_color("font_color_pressed")
	_pressed = true


func _on_ButtonWithIcon_focus_entered()->void :
	if not _color_locked:
		_label.modulate = get_color("font_color_focus")
	_focused = true
	on_focus_entered()


func _on_ButtonWithIcon_focus_exited()->void :
	_focused = false

	if not _hovered:
		_pressed = false

	if not _hovered and not _pressed and not _color_locked:
		_label.modulate = get_color("font_color")


func _on_ButtonWithIcon_mouse_entered()->void :
	if not _color_locked:
		_label.modulate = get_color("font_color_hover")
	_hovered = true
	on_mouse_entered()


func _on_ButtonWithIcon_mouse_exited()->void :
	_hovered = false

	if not _focused:
		_pressed = false

	if not _focused and not _pressed and not _color_locked:
		_label.modulate = get_color("font_color")


func set_icon(icon:Texture, color:Color = Color.white)->void :
	_gold_icon.set_icon(icon, color)
