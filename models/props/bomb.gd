extends Node3D

@onready var anim:AnimationPlayer = $AnimationPlayer

func play_flash_animation() -> void:
	anim.play('flash')
