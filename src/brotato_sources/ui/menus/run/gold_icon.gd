extends TextureRect

func _ready()->void :
	modulate = Utils.GOLD_COLOR


func set_icon(icon:Texture, color:Color = Color.white)->void :
	texture = icon
	modulate = color
