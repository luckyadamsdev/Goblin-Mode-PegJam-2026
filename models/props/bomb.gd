extends Node3D

@onready var anim:AnimationPlayer = $AnimationPlayer

func play_flash_animation() -> void:
	anim.play('flash')

func try_to_hurt() -> void:
	Global.game_manager.explode(global_position)
