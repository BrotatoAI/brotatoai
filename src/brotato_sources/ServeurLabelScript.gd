extends Label

onready var _sync_node = get_node("/root/Main/Sync")

#func _ready():
#	pause_mode = Node.PAUSE_MODE_PROCESS
	
func _process(delta):
	var label = 'UNKNOWN'
	
	if GodotRLClient.stream.get_status() == StreamPeerTCP.STATUS_NONE:
		label = 'NONE'	
	elif GodotRLClient.stream.get_status() == StreamPeerTCP.STATUS_CONNECTING:
		label = 'CONNECTING'
	elif GodotRLClient.stream.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		label = 'CONNECTED'
	elif GodotRLClient.stream.get_status() == StreamPeerTCP.STATUS_ERROR:
		label = 'ERROR'
	
	text = str(label, ' (msg ', GodotRLClient.nb_exchanged_msg, ')')
