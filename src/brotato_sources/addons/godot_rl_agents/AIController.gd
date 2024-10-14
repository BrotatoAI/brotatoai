extends Node2D
class_name AIController2D

enum ControlModes {
	INHERIT_FROM_SYNC,
	HUMAN,
	TRAINING,
	ONNX_INFERENCE,
	RECORD_EXPERT_DEMOS
}

export(int, "INHERIT_FROM_SYNC", "HUMAN", "TRAINING", "ONNX_INFERENCE", "RECORD_EXPERT_DEMOS") var control_mode: int = ControlModes.INHERIT_FROM_SYNC
export(String) var onnx_model_path := ""
export(int) var reset_after := 1000

# Record expert demos mode options
export(String) var expert_demo_save_path: String = ""
# export(InputEvent) var remove_last_episode_key: InputEvent = InputEvent.new()
export(int) var action_repeat: int = 1

# Multi-policy mode options
export(String, "Multi-policy mode options") var policy_name: String = "shared_policy"

var onnx_model: ONNXModel

var heuristic := "human"
var reward := 0.0
var n_steps := 0
var needs_reset := false

var _player: Player

func _ready():
	add_to_group("AGENT")

func init(player: Player):
	print_debug("player: ", player)
	_player = player

#-- Methods that need implementing using the "extend script" option in Godot --#
func get_obs() -> Dictionary:	
	assert(false, "the get_obs method is not implemented when extending from ai_controller")
	var obs = []
	return {"obs": obs}

func get_reward() -> float:
	assert(false, "the get_reward method is not implemented when extending from ai_controller")
	return 0.0

func get_action_space() -> Dictionary:
	assert(false, "the get_action_space method is not implemented when extending from ai_controller")
	return {
		"example_actions_continous": {"size": 2, "action_type": "continuous"},
	}

func set_action(action) -> void:
	print_debug('action', action);
	assert(false, "the set_action method is not implemented when extending from ai_controller")	

#-- Methods that sometimes need implementing using the "extend script" option in Godot --#
func get_action() -> Array:
	assert(false, "the get_action method is not implemented in extended AIController but demo_recorder is used")
	return []

func _physics_process(delta):
	n_steps += 1
	if n_steps > reset_after:
		needs_reset = true
		
	if needs_reset || GodotRLClient.needs_reset:
		print('needs_reset: ', needs_reset, ', GDClient: ', GodotRLClient.needs_reset)
		reset()

func get_obs_space():
	# may need overriding if the obs space is complex
	var obs = get_obs()
	return {
		"obs": {"size": [len(obs["obs"])], "space": "box"},
	}

func reset():
	n_steps = 0
	needs_reset = false
	GodotRLClient.needs_reset = false
	
	# ANCHOR : Reset scene (single agent env)

func reset_if_done():
	if GodotRLClient.is_done:
		reset()

func set_heuristic(h):
	# sets the heuristic from "human" or "model" nothing to change here
	heuristic = h

func get_done():
	return GodotRLClient.is_done

func set_done_false():
	GodotRLClient.is_done = false

func zero_reward():
	reward = 0.0
