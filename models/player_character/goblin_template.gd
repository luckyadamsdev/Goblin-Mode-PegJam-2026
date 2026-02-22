extends Node3D

func get_animation_player() -> AnimationPlayer:
	return $AnimationPlayer

func finished_trick() -> void:
	get_parent().finished_trick()# TODO replace with event. This is an anti-pattern
