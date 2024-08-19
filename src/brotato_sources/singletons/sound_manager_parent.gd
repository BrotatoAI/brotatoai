class_name SoundManagerParent
extends Node

enum {SOUND, VOLUME, PITCH_RAND, POSITION}

const MAX_SOUNDS = 32

var num_players = 12
var bus = "Sound"

var players_available = []
var sounds_to_play = []


func _ready()->void :

	pause_mode = PAUSE_MODE_PROCESS

	for i in num_players:
		var p = instance_player()
		add_child(p)
		players_available.append(p)
		p.connect("finished", self, "_on_stream_finished", [p])
		p.bus = bus


func instance_player()->Node:
	return AudioStreamPlayer.new()


func _on_stream_finished(stream:Object)->void :
	players_available.append(stream)


func _process(_delta)->void :
	if not sounds_to_play.empty() and not players_available.empty():
		var sound_to_play = sounds_to_play.pop_front()
		set_additional_properties_if_needed(sound_to_play)
		players_available[0].stream = sound_to_play[SOUND]
		players_available[0].volume_db = sound_to_play[VOLUME]
		players_available[0].pitch_scale = 1.0 + rand_range( - sound_to_play[PITCH_RAND], sound_to_play[PITCH_RAND])

		players_available[0].play()
		players_available.pop_front()


func set_additional_properties_if_needed(_sound_to_play:Array)->void :
	pass
