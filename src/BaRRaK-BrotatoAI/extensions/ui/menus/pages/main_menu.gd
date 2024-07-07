extends "res://ui/menus/pages/main_menu.gd"

const BrotatoAIOptions = preload("res://mods-unpacked/BaRRaK-BrotatoAI/brotatoai_options.gd")

func _ready():
	var options_node = BrotatoAIOptions.new()

	options_node.set_name("BrotatoAIOptions")

	$"/root".add_child(options_node)
