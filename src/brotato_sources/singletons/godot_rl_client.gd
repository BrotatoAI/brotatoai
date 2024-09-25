extends Node

const DEFAULT_PORT := "11008"

var nb_exchanged_msg:int = 0

var stream : StreamPeerTCP = null
var port:int = DEFAULT_PORT.to_int()

func _ready():
	pass # Replace with function body.

func connect_to_server():
	print("Waiting for one second to allow server to start")
	OS.delay_msec(1000)
	
	stream = StreamPeerTCP.new()
	
	# "localhost" was not working on windows VM, had to use the IP
	var ip = "127.0.0.1"
	
	print("trying to coclient.gdnnect to server: ", ip, ":", port)
	
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
