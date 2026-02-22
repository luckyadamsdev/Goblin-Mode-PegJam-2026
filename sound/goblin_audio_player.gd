extends AudioStreamPlayer
@export var landed_sound : AudioStream
@export var jump_sound : AudioStream
@export var hurt_sound : AudioStream
@export var surf_sound : AudioStream
@export var airtime_sound : AudioStream

var ambient_sound = surf_sound

func play_sound(sound: AudioStream) -> void:
	if(is_instance_valid(sound)):
		if(playing):
			stop()
		stream = sound
		play()

func _on_finished() -> void:
	play_sound(ambient_sound)

func _on_goblin_jumped() -> void:
	play_sound(jump_sound)
	ambient_sound = airtime_sound

func _on_goblin_landed() -> void:
	play_sound(landed_sound)
	ambient_sound = surf_sound

func _on_goblin_fell_down() -> void:
	play_sound(hurt_sound)
	ambient_sound = surf_sound
