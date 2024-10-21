extends Label

onready var _sync_node = get_node("/root/Main/Sync")

#func _ready():
#	pause_mode = Node.PAUSE_MODE_PROCESS
	
func _process(delta):	
	text = str('Last reward: ', _sync_node.last_reward)
