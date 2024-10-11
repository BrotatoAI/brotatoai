extends Label

var last_key = 'none'

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	
func _process(delta):
	if (GodotRLClient.last_key != null):
		last_key = GodotRLClient.last_key
	text = str('Last key: ', last_key, ' (pause: ', get_tree().paused, ', speed: ', GodotRLClient.speedup, ')')
