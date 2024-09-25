extends Label

onready var _sync_node = get_node("/root/Main/Sync")

var last_key = 'none'
var paused = false

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	
func _process(delta):
	text = str('Last key: ', last_key, ' (pause: ', get_tree().paused, ')')
	
func _input(event: InputEvent):
	if event is InputEventKey:
		last_key = event.as_text()
	
	if Input.is_key_pressed(KEY_P):
		get_tree().paused = !get_tree().paused
		
	if Input.is_key_pressed(KEY_R):
		_sync_node.just_reset = true
