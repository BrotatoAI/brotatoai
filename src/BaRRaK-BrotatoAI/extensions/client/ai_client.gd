extends Node

signal action_received

const HOST: String = "127.0.0.1"
const PORT: int = 4242
const RECONNECT_TIMEOUT: float = 1.0

const Client = preload("res://mods-unpacked/BaRRaK-BrotatoAI/extensions/client/client.gd")
var _client: Client = Client.new()

var ticks = 0

var connected = false;
	
func _ready():
	print_debug('AI client init ...')
	set_pause_mode(PAUSE_MODE_PROCESS)
	_client.connect("connected", self, "_handle_client_connected")
	_client.connect("disconnected", self, "_handle_client_disconnected")
	_client.connect("error", self, "_handle_client_error")
	_client.connect("data", self, "_handle_client_data")
	add_child(_client)
	_client.connect_to_host(HOST, PORT)
	print_debug('AI client init done')
	
func _connect_after_timeout(timeout: float) -> void:
	yield(get_tree().create_timer(timeout), "timeout") # Delay for timeout
	_client.connect_to_host(HOST, PORT)

func _handle_client_connected() -> void:
	print("Client connected to server.")
	connected = true

func _handle_client_data(data: PoolByteArray) -> void:
	var message = data.get_string_from_utf8();
	print("Client data: ", message)
	emit_signal("action_received", message)

func _handle_client_disconnected() -> void:
	print("Client disconnected from server.")
	connected = false
	_connect_after_timeout(RECONNECT_TIMEOUT) # Try to reconnect after 3 seconds

func _handle_client_error() -> void:
	print("Client error.")
	connected = false
	_connect_after_timeout(RECONNECT_TIMEOUT) # Try to reconnect after 3 seconds

func string_to_pool_byte_array(input_string: String) -> PoolByteArray:
	var byte_array = input_string.to_utf8()
	var pool_byte_array = PoolByteArray()
	for byte in byte_array:
		pool_byte_array.append(byte)
	return pool_byte_array
	
func send_state(state):
	var seconds = OS.get_unix_time()
	
	var bytearray = string_to_pool_byte_array(state)

	var result_header = _client.send_64(bytearray.size())
	if result_header:
		_client.send(bytearray)
	
func get_status() -> String:
	return _client.get_status()
