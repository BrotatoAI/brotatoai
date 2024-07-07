extends "res://main.gd"

const AIClient = preload("res://mods-unpacked/BaRRaK-BrotatoAI/extensions/client/ai_client.gd")
const AICanvas = preload("res://mods-unpacked/BaRRaK-BrotatoAI/extensions/ai_canvas.gd")
const FPSMeterLabel = preload("res://mods-unpacked/BaRRaK-BrotatoAI/extensions/ui/fps_meter.gd")
const ServerStatusLabel = preload("res://mods-unpacked/BaRRaK-BrotatoAI/extensions/ui/server_status.gd")

var start_position = Vector2(50, 270)
var shift_down = Vector2(0, 15)

var ai_client
var canvas_layer
var fps_meter
var server_status

func _init():
	Engine.time_scale = 2
	
	ai_client = AIClient.new();
	add_child(ai_client)
	print('registered ai_client')
	
	canvas_layer = AICanvas.new()
	add_child(canvas_layer)

func _ready():
	fps_meter = FPSMeterLabel.new()
	server_status = ServerStatusLabel.new(ai_client)

	$UI.add_child(fps_meter)
	fps_meter.set_position(start_position)

	$UI.add_child(server_status)
	server_status.set_position(start_position + shift_down)

func free():
	remove_child(canvas_layer)
	remove_child(fps_meter)
	remove_child(server_status)
	.free()
