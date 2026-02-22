extends AudioStreamPlayer
@export var landed_sound : AudioStream
@export var jump_sound : AudioStream
@export var hurt_sound : AudioStream
@export var surf_sound : AudioStream
var ambient_sound = surf_sound


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_sound(sound: AudioStream) -> void:
	if(playing):
		stop()
	stream = sound
	if(is_instance_valid(stream)):
		play()

	

func _on_goblin_jumped() -> void:
	play_sound(jump_sound)
	ambient_sound = null

func _on_goblin_landed() -> void:
	play_sound(jump_sound)
	ambient_sound = surf_sound

func _on_finished() -> void:
	play_sound(ambient_sound)
