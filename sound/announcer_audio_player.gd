extends AudioStreamPlayer

@export var countdown : AudioStream
@export var race_start : AudioStream
@export var race_finished : AudioStream
@export var winner : AudioStream
@export var paused : AudioStream
@export var resumed : AudioStream

var next_sound = null

func play_sound(sound: AudioStream) -> void:
	if(is_instance_valid(sound) && sound != null):
		if(playing):
			stop()
		stream = sound
		play()

func _on_game_manager_race_countdown_started() -> void:
	play_sound(countdown)


func _on_game_manager_race_start() -> void:
	play_sound(race_start)


func _on_game_manager_race_resumed() -> void:
	play_sound(resumed)


func _on_game_manager_race_paused() -> void:
	play_sound(paused)


func _on_game_manager_first_finished() -> void:
	play_sound(winner)


func _on_game_manager_race_over() -> void:
	if(playing):
		next_sound = race_finished


func _on_finished() -> void:
	play_sound(next_sound)
	next_sound = null
