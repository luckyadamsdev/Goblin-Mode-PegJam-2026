extends Node3D

signal finish_item()

var bombRes = load('res://models/props/bomb.tscn')

@export var displayHolder: Node3D
@export var item_anvil: Node3D
@export var item_bomb : Node3D
@export var item_hands: Node3D
@export var item_potion: Node3D
@export var normal_hands: Node3D
@export var bombSpawnPoint: Node3D

func get_animation_player() -> AnimationPlayer:
	return $AnimationPlayer

func finished_trick() -> void:
	get_parent().finished_trick()# TODO replace with event. This is an anti-pattern

func emit_finish_item() -> void:
	finish_item.emit()

func spawn_bomb() -> void:
	var bombInst = bombRes.instantiate()
	Global.add_child(bombInst)
	bombInst.global_position = bombSpawnPoint.global_position
	bombInst.play_flash_animation()
