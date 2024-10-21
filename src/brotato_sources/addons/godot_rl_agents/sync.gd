extends Node
# --fixed-fps 2000 --disable-render-loop
export (int) var action_repeat = 8
# ANCHOR : Speed settings
export (int) var speed_up = 5
var n_action_steps = 0

const DEFAULT_SEED := "1"
const DEFAULT_ACTION_REPEAT := "8"

var connected = false
var message_center
var should_connect = true
var agents
var need_to_send_obs = false
var args = null
var timer: Timer
var just_reset = false
var last_reward

onready var start_time = OS.get_ticks_msec()

var onnx_model_path: String
var onnx_model: ONNXModel

var initialized = false

# Called when the node enters the scene tree for the first time.

func _ready():
#	print('sync node ready ...')
	
	get_parent().connect("ready", self, "_on_root_ready")
	get_tree().root.connect("ready", self, "_on_root_ready")

func _on_root_ready():
	print('********************************')
	print('*****      ROOT READY      *****')
	print('********************************')

	_initialize()
		
func _set_agents():
	agents = get_tree().get_nodes_in_group("AGENT")

func _set_heuristic(heuristic):
	for agent in agents:
		agent.set_heuristic(heuristic)

func _send_env_info():
	var json_dict = GodotRLClient._get_dict_json_message()
	assert(json_dict["type"] == "env_info")
	
	var message = {
		"type" : "env_info",
		# "obs_size": agents[0].get_obs_size(),
		"observation_space": agents[0].get_obs_space(),
		"action_space":agents[0].get_action_space(),
		"n_agents": len(agents)
	}
	GodotRLClient._send_dict_as_json_message(message)

func _get_args():
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
	return args.get("port", GodotRLClient.DEFAULT_PORT).to_int()

func _set_seed():
	var _seed = args.get("env_seed", DEFAULT_SEED).to_int()
	seed(_seed)
	
func _set_onnx_model_path():
	onnx_model_path = args.get("onnx_model_path", '')
#	onnx_model_path = args.get("onnx_model_path", '/Users/eguenichon/Development/BrotatoAI/workspace/model/model_3.onnx')
	pass

func _set_action_repeat():
	action_repeat = args.get("action_repeat", DEFAULT_ACTION_REPEAT).to_int()
	
func _load_onnx_model():
	var file = File.new()
	assert(
		file.file_exists(onnx_model_path),
		"Onnx Model Path set on Sync node does not exist: " + onnx_model_path
	)
	onnx_model = ONNXModel.new(onnx_model_path, 1)
	# onnx_model.set_action_means_only(action_space)

func _initialize():
#	print('initialize')
	_set_agents()
	
	args = _get_args()
#	print('args', args)

	var speedup = _get_speedup()
	Engine.iterations_per_second = speedup * 60 # Replace with function body.
	Engine.time_scale = speedup * 1.0
	GodotRLClient.speedup = speedup
	
	_set_onnx_model_path()
	
#	prints("physics ticks", Engine.iterations_per_second, Engine.time_scale, speedup, speed_up)

	if onnx_model_path != '':
		_load_onnx_model()
	else:
		var port = _get_port()
		GodotRLClient.port = port
		
		_connect()

		if !GodotRLClient.env_info_sent:
			_set_heuristic("model")
			_send_env_info()
			GodotRLClient.env_info_sent = true
	
#	print('init done')

func _connect():
	if GodotRLClient.stream.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		print('try to connect to server ...')
		connected = GodotRLClient.connect_to_server()
	else:
		connected = true
		# We assume that previous env was triggering action
		need_to_send_obs = true
	
	print("connected ... lets go, connected: ", connected, ", env sent: ", GodotRLClient.env_info_sent)
	

func _physics_process(delta): 

	if GodotRLClient.manual_input:
		return
		
	if onnx_model_path != '':
		var obs = _get_obs_from_agents()
		var action = onnx_model.run_inference(obs, 1.0)
		
#		print('action: ', action)
		_set_agent_actions([action])

	# two modes, human control, agent control
	# pause tree, send obs, get actions, set actions, unpause tree
	if n_action_steps % action_repeat != 0:
		n_action_steps += 1
		return
		
	#print('process ... need_to_send_obs: ', need_to_send_obs, ', just reset: ', just_reset, ', needs_reset: ', GodotRLClient.needs_reset)

	n_action_steps += 1

	if connected:
		get_tree().set_pause(true)

		if just_reset:
			
			print('just reset')
			
			just_reset = false
			
			var obs = _get_obs_from_agents()

			var reply = {
				"type": "reset",
				"obs": obs
			}
			
			print('Send reset ...')

			GodotRLClient._send_dict_as_json_message(reply)
			# this should go straight to getting the action and setting it checked the agent, no need to perform one phyics tick
			get_tree().set_pause(false)
			return

		if need_to_send_obs:
			# print('need to send obs')
			need_to_send_obs = false
			var reward = _get_reward_from_agents()
			last_reward = reward
			var done = _get_done_from_agents()
			
			if done[0]:
				print('********************************')
				print('*****  #  AGENT DONE  #    *****')
				print('********************************')
				
			_reset_agents_if_done() # this ensures the new observation is from the next env instance : NEEDS REFACTOR

			var obs = _get_obs_from_agents()

			var reply = {
				"type": "step",
				"obs": obs,
				"reward": reward,
				"done": done
			}

			# print('Send obs ...')

			GodotRLClient._send_dict_as_json_message(reply)

		var handled = handle_message()
	else:
		print('not connected reset agents')
		_reset_agents_if_done()
	# print('********************************')

func handle_message() -> bool:
	
	# print('handle message')

	# get json message: reset, step, close
	var message = GodotRLClient._get_dict_json_message()
	
	# print('handle message: ', message["type"])
	
	if message == null:
		print('received null message')
		return false
	
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
		# print("resetting forcing draw")
		# RenderingServer.force_draw()
		
		var obs = _get_obs_from_agents()
		print("obs ", obs)
		var reply = {
			"type": "reset",
			"obs": obs
		} 
		GodotRLClient._send_dict_as_json_message(reply)   
		return true
		
	if message["type"] == "call":
		var method = message["method"]
		var returns = _call_method_on_agents(method)
		var reply = {
			"type": "call",
			"returns": returns
		}
#		print("calling method from Python")
		GodotRLClient._send_dict_as_json_message(reply)   
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
#	print('reset agents if done')
	if agents:
		for agent in agents:
			if agent.get_done(): 
				agent.set_done_false()

func _reset_all_agents():
	print('reset all agents')
	for agent in agents:
		agent.needs_reset = true
		agent.reset()   

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
	
func _exit_tree() -> void:
	queue_free()
	print('exit tree')
