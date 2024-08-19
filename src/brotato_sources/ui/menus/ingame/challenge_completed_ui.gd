class_name ChallengeCompletedUI
extends Control

signal started
signal finished

export (Resource) var sound_popup
export (Resource) var sound_popout

var challenge:ChallengeData
var chal_queue: = []

onready var _chal_ui = $VBoxContainer / ChallengeUI
onready var _animation_player = $AnimationPlayer
onready var _hide_timer = $HideTimer


func _ready()->void :
	var _error = ChallengeService.connect("challenge_completed", self, "on_challenge_completed")


func on_challenge_completed(p_challenge:ChallengeData)->void :
	popup(p_challenge)


func set_challenge(chal_data:ChallengeData)->void :
	challenge = chal_data
	_chal_ui.set_data(chal_data)


func queue(chal_data:ChallengeData)->void :
	chal_queue.push_back(chal_data)


func popup(chal_data:ChallengeData)->void :

	if not _hide_timer.is_stopped():
		queue(chal_data)
		return 

	emit_signal("started")
	set_challenge(chal_data)
	SoundManager.play(sound_popup, - 5, 0.2)
	_animation_player.play("popup")
	show()
	_hide_timer.start()


func _on_HideTimer_timeout()->void :
	SoundManager.play(sound_popout)
	_animation_player.play("popout")
	if chal_queue.size() > 0:
		var chal = chal_queue.pop_back()
		popup(chal)
	else :
		emit_signal("finished")
