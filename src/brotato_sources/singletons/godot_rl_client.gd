extends Node

const DEFAULT_PORT := "11008"

var nb_exchanged_msg:int = 0

var stream : StreamPeerTCP = null
var port:int = DEFAULT_PORT.to_int()
var env_info_sent = false
var is_done = false

var last_key: String
var speedup: int

const MAJOR_VERSION := "0"
const MINOR_VERSION := "3" 

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	stream = StreamPeerTCP.new()
		
func _input(_event: InputEvent):
	if Input.is_key_pressed(KEY_P):
		last_key = 'P'
		get_tree().paused = !get_tree().paused
		
	if Input.is_key_pressed(KEY_R):
		last_key = 'R'
		RunData.reset(true)
		MusicManager.play(0)
		var _error = get_tree().change_scene(MenuData.game_scene)
		
	if Input.is_key_pressed(KEY_D):
		last_key = 'D'
		is_done = true
		
	if Input.is_key_pressed(KEY_PLUS):
		last_key = '+'
		speedup += 1
		
	if Input.is_key_pressed(KEY_MINUS):
		last_key = '-'
		if (speedup > 1):
			speedup -= 1

func connect_to_server():
	print("Waiting for one second to allow server to start")
	OS.delay_msec(1000)
	
	# "localhost" was not working on windows VM, had to use the IP
	var ip = "127.0.0.1"
	
	print("trying to connect to server: ", ip, ":", port)
	
	while true:
		var connect = stream.connect_to_host(ip, port)
		
		var attempt = 0
		
		if attempt > 3:
			break
		
		if stream.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			attempt = attempt + 1
			OS.delay_msec(1000)
			print_debug('connect (', connect, ')')
		else:
			break

	var connected = stream.get_status() == StreamPeerTCP.STATUS_CONNECTED
	if connected:
		_handshake()
		stream.set_no_delay(true)
	
	return stream.get_status() == StreamPeerTCP.STATUS_CONNECTED

func _get_dict_json_message():
	# returns a dictionary from of the most recent message
	# this is not waiting
	while stream.get_available_bytes() == 0:
		if stream.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			print("server disconnected status, closing")
			# get_tree().quit()
			return null

		OS.delay_usec(10)
		
	var message = stream.get_string()
	
	return _parse_json(message)
	
func _parse_json(json_string: String):
	var result = JSON.parse(json_string)
	if result.error == OK:
		return result.result
	else:
		print_debug("JSON Parse Error: ", result.error_string, " in ", json_string, " at line ", result.error_line)
	
func _send_dict_as_json_message(dict):
	nb_exchanged_msg += 1
	stream.put_string(JSON.print(dict))
	
func disconnect_from_server():
	stream.disconnect_from_host()
	
func _handshake():
	print("performing handshake")
	
	var json_dict = _get_dict_json_message()
	print_debug('dict', JSON.print(json_dict))

	assert(json_dict["type"] == "handshake")
	var major_version = json_dict["major_version"]
	var minor_version = json_dict["minor_version"]
	if major_version != MAJOR_VERSION:
		print("WARNING: major version mismatch ", major_version, " ", MAJOR_VERSION)  
	if minor_version != MINOR_VERSION:
		print("WARNING: minor version mismatch ", minor_version, " ", MINOR_VERSION)
		
	print("handshake complete")
