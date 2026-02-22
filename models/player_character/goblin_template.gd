extends Node3D

@export var displayHolder: Node3D
@export var item_anvil: Node3D
@export var item_bomb : Node3D
@export var item_hands: Node3D
@export var item_potion: Node3D
@export var normal_hands: Node3D

func get_animation_player() -> AnimationPlayer:
	return $AnimationPlayer

func finished_trick() -> void:
	get_parent().finished_trick()# TODO replace with event. This is an anti-pattern
