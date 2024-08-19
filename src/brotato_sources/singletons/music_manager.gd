extends Node

var bus = "Music"
var player:AudioStreamPlayer
var _tween:Tween

export (Array, Resource) var music_tracks

var shuffled_tracks: = []


func _ready()->void :
	pause_mode = PAUSE_MODE_PROCESS
	player = AudioStreamPlayer.new()
	_tween = Tween.new()
	add_child(_tween)
	add_child(player)
	player.bus = bus

	var _error = player.connect("finished", self, "on_track_finished")


func on_track_finished()->void :
	play()


func play(volume:float = player.volume_db)->void :

	if shuffled_tracks.size() <= 0:
		shuffled_tracks = music_tracks.duplicate()
		shuffled_tracks.shuffle()

	var new_track = shuffled_tracks.pop_back()

	if new_track != player.stream:
		player.stream = new_track
	else :
		player.stream = shuffled_tracks.pop_back()

	player.volume_db = - 20
	player.play()
	tween(volume)


func tween(to:float, from:float = player.volume_db, duration:float = 1)->void :
	if _tween.is_active():
		yield (_tween, "tween_all_completed")

	var _error_interpolate = _tween.interpolate_property(
		player, 
		"volume_db", 
		from, 
		to, 
		duration, 
		Tween.TRANS_LINEAR
	)

	var _error = _tween.start()
