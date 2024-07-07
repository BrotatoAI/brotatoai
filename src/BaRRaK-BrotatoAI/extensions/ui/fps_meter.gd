extends Label


func _ready():
	add_color_override("font_color", Color(1, 1, 1))  # Blanc
	add_color_override("outline_color", Color(0, 0, 0))  # Noir

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var fps = Engine.get_frames_per_second()
	
	text = "FPS: " + str(fps)
