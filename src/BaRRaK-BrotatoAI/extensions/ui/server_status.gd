extends Label


var _ai_client

func _init(_ai_client):
	self._ai_client = _ai_client

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_text("host: %s:%s\nstatus: %s" % [_ai_client.HOST, _ai_client.PORT, _ai_client.get_status()])
#	pass
