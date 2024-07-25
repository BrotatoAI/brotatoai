extends Node
# --fixed-fps 2000 --disable-render-loop
export (int) var action_repeat = 8
export (int) var speed_up = 3
var n_action_steps = 0

const MAJOR_VERSION := "0"
const MINOR_VERSION := "3" 
const DEFAULT_PORT := "11008"
const DEFAULT_SEED := "1"
const DEFAULT_ACTION_REPEAT := "8"
var stream : StreamPeerTCP = null
var connected = false
var message_center
var should_connect = true
var agents
var need_to_send_obs = false
var args = null

onready var start_time = OS.get_ticks_msec()

var initialized = false
var just_reset = false


# Called when the node enters the scene tree for the first time.

func _ready():
	print_debug('sync ready ...', get_tree(), get_parent())
	
	get_parent().connect("ready", self, "_on_root_ready")

	get_tree().root.connect("ready", self, "_on_root_ready")

func _on_root_ready():
	print_debug('root ready')
	get_tree().set_pause(true)
	_initialize()
	
	var timer = Timer.new()
	timer.set_wait_time(1.0)
	timer.set_one_shot(true)
	add_child(timer)
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.start()

func _on_timer_timeout():
	get_tree().set_pause(false)
	# Nettoyer le timer s'il n'est plus nécessaire
	var timer = get_node("Timer")
	if timer:
		timer.queue_free()
		
func _get_agents():
	agents = get_tree().get_nodes_in_group("AGENT")

func _set_heuristic(heuristic):
	for agent in agents:
		agent.set_heuristic(heuristic)

func _handshake():
	print("performing handshake")
	
	var json_dict = _get_dict_json_message()
	JSON.print(json_dict)

	assert(json_dict["type"] == "handshake")
	var major_version = json_dict["major_version"]
	var minor_version = json_dict["minor_version"]
	if major_version != MAJOR_VERSION:
		print("WARNING: major verison mismatch ", major_version, " ", MAJOR_VERSION)  
	if minor_version != MINOR_VERSION:
		print("WARNING: minor verison mismatch ", minor_version, " ", MINOR_VERSION)
		
	print("handshake complete")

func _get_dict_json_message():
	# returns a dictionary from of the most recent message
	# this is not waiting
	while stream.get_available_bytes() == 0:
		if stream.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			print("server disconnected status, closing")
			get_tree().quit()
			return null

		OS.delay_usec(10)
		
	var message = stream.get_string()
	
	return _parse_json(message)
	
func _parse_json(json_string: String):
	var result = JSON.parse(json_string)
	if result.error == OK:
		return result.result
	else:
		push_error("JSON Parse Error: " + result.error_string + " in " + json_string + " at line " + result.error_line)
	
func _send_dict_as_json_message(dict):
	stream.put_string(JSON.print(dict))

func _send_env_info():
	var json_dict = _get_dict_json_message()
	assert(json_dict["type"] == "env_info")
	
	var message = {
		"type" : "env_info",
		#"obs_size": agents[0].get_obs_size(),
		"observation_space": agents[0].get_obs_space(),
		"action_space":agents[0].get_action_space(),
		"n_agents": len(agents)
		}
	_send_dict_as_json_message(message)


func connect_to_server():
	print("Waiting for one second to allow server to start")
	OS.delay_msec(1000)
	
	stream = StreamPeerTCP.new()
	
	# "localhost" was not working on windows VM, had to use the IP
	var ip = "127.0.0.1"
	var port = _get_port()
	
	print("trying to coclient.gdnnect to server: ", ip, ":", port)
	
	while true:
		var connect = stream.connect_to_host(ip, port)
		var attempt = 0
		
		if attempt > 3:
			break
		
		if stream.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			attempt = attempt + 1
			OS.delay_msec(1000)
			print_debug('connect', stream.get_status())
		else:
			break

	stream.set_no_delay(true)
	return stream.get_status() == StreamPeerTCP.STATUS_CONNECTED

func _get_args():
	print("getting command line arguments")
#	var arguments = {}
#	for argument in OS.get_cmdline_args():
#		# Parse valid command-line arguments into a dictionary
#		if argument.find("=") > -1:
#			var key_value = argument.split("=")
#			arguments[key_value[0].lstrip("--")] = key_value[1]
			
	var arguments = {}
	for argument in OS.get_cmdline_args():
		print(argument)
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
		else:
			# Options without an argument will be present in the dictionary,
			# with the value set to an empty string.
			arguments[argument.lstrip("--")] = ""

	return arguments   

func _get_speedup():
	print(args)
	return args.get("speedup", str(speed_up)).to_int()

func _get_port():    
	return args.get("port", DEFAULT_PORT).to_int()

func _set_seed():
	var _seed = args.get("env_seed", DEFAULT_SEED).to_int()
	seed(_seed)

func _set_action_repeat():
	action_repeat = args.get("action_repeat", DEFAULT_ACTION_REPEAT).to_int()
	
func disconnect_from_server():
	stream.disconnect_from_host()

func _initialize():
	print_debug('initialize')
	_get_agents()
	
	args = _get_args()
	print_debug('args', args)
	var speedup = _get_speedup();
	Engine.iterations_per_second = speedup * 60 # Replace with function body.
	Engine.time_scale = speedup * 1.0
	prints("physics ticks", Engine.iterations_per_second, Engine.time_scale, speedup, speed_up)
	
	connected = connect_to_server()
	
	print("connected ... lets go ", connected)
	
	if connected:
		_set_heuristic("model")
		_handshake()
		_send_env_info()
	else:
		_set_heuristic("human")  
		
	_set_seed()
	_set_action_repeat()
	initialized = true  

func _physics_process(delta): 
	# two modes, human control, agent control
	# pause tree, send obs, get actions, set actions, unpause tree
	if n_action_steps % action_repeat != 0:
		n_action_steps += 1
		return

	n_action_steps += 1
	
	if connected:
		get_tree().set_pause(true) 
		
		if just_reset:
			just_reset = false
			var obs = _get_obs_from_agents()
		
			var reply = {
				"type": "reset",
				"obs": obs
			}
			_send_dict_as_json_message(reply)
			# this should go straight to getting the action and setting it checked the agent, no need to perform one phyics tick
			get_tree().set_pause(false) 
			return
		
		if need_to_send_obs:
			need_to_send_obs = false
			var reward = _get_reward_from_agents()
			var done = _get_done_from_agents()
			#_reset_agents_if_done() # this ensures the new observation is from the next env instance : NEEDS REFACTOR
			
			var obs = _get_obs_from_agents()
			
			var reply = {
				"type": "step",
				"obs": obs,
				"reward": reward,
				"done": done
			}
			_send_dict_as_json_message(reply)
		
		var handled = handle_message()
	else:
		_reset_agents_if_done()

func handle_message() -> bool:
	# get json message: reset, step, close
	var message = _get_dict_json_message()
	if message["type"] == "close":
		print("received close message, closing game")
		get_tree().quit()
		get_tree().set_pause(false) 
		return true
		
	if message["type"] == "reset":
		print("resetting all agents")
		_reset_all_agents()
		just_reset = true
		get_tree().set_pause(false) 
		#print("resetting forcing draw")
#        RenderingServer.force_draw()
#        var obs = _get_obs_from_agents()
#        print("obs ", obs)
#        var reply = {
#            "type": "reset",
#            "obs": obs
#        }
#        _send_dict_as_json_message(reply)   
		return true
		
	if message["type"] == "call":
		var method = message["method"]
		var returns = _call_method_on_agents(method)
		var reply = {
			"type": "call",
			"returns": returns
		}
		print("calling method from Python")
		_send_dict_as_json_message(reply)   
		return handle_message()
	
	if message["type"] == "action":
		var action = message["action"]
		_set_agent_actions(action) 
		need_to_send_obs = true
		get_tree().set_pause(false) 
		return true
		
	print("message was not handled")
	return false

func _call_method_on_agents(method):
	var returns = []
	for agent in agents:
		returns.append(agent.call(method))
		
	return returns


func _reset_agents_if_done():
	if agents:
		for agent in agents:
			if agent.get_done(): 
				agent.set_done_false()

func _reset_all_agents():
	for agent in agents:
		agent.needs_reset = true
		#agent.reset()   

func _get_obs_from_agents():
	var obs = []
	for agent in agents:
		obs.append(agent.get_obs())
	return obs
	
func _get_reward_from_agents():
	var rewards = [] 
	for agent in agents:
		rewards.append(agent.get_reward())
		agent.zero_reward()
	return rewards    
	
func _get_done_from_agents():
	var dones = [] 
	for agent in agents:
		var done = agent.get_done()
		if done: agent.set_done_false()
		dones.append(done)
	return dones    
	
func _set_agent_actions(actions):
	for i in range(len(actions)):
		agents[i].set_action(actions[i])
	
