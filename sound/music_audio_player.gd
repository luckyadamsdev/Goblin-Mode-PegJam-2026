extends AudioStreamPlayer

@export var race_music : AudioStream
@export var pause_music : AudioStream
@export var main_menu_music : AudioStream

var playback_pos = 0
var current_track = null

func play_sound(sound: AudioStream) -> void:
	if(is_instance_valid(sound)):
		if(playing):
			stop()
		stream = sound
		play()

func _on_game_manager_race_start() -> void:
	current_track = race_music
	play_sound(current_track)


func _on_game_manager_race_paused() -> void:
	playback_pos = get_playback_position()


func _on_game_manager_race_resumed() -> void:
	play_sound(race_music)


func _on_game_manager_in_main_menu() -> void:
	current_track = main_menu_music
#	play_sound(main_menu_music)


func _on_game_manager_in_pause_menu() -> void:
	current_track = pause_music
#	play_sound(current_track)


func _on_finished() -> void:
	play_sound(current_track)


func _on_game_manager_race_over() -> void:
	pass # Replace with function body.
