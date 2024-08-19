extends SoundManagerParent


func instance_player()->Node:
	return AudioStreamPlayer.new()


func play(sound:Resource, volume_mod:float = 0.0, pitch_rand:float = 0.0, always_play:bool = false)->void :
	if ( not players_available.empty() and sounds_to_play.size() < MAX_SOUNDS) or always_play:
		sounds_to_play.append([sound, volume_mod, pitch_rand])
