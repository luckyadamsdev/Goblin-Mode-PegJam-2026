extends Node3D
class_name Map

# whether this map should track the leading goblin
@export var is_race:bool = true

var goblin_1_start:Node3D:
	get:
		if goblin_1_start == null:
			goblin_1_start = find_child("goblin_1_start")
		return goblin_1_start
		
var goblin_2_start:Node3D:
	get:
		if goblin_2_start == null:
			goblin_2_start = find_child("goblin_2_start")
		return goblin_2_start

var end_zone:Area3D:
	get:
		if end_zone == null:
			end_zone = find_child("end_zone")
		return end_zone

func restart_player(player_given: Goblin) -> void:
	var start := goblin_1_start
	if player_given.player_id == 2:
		start = goblin_2_start
		
	if player_given.sparkles_effect == null:
		player_given.sparkles_effect = load("res://fx/sparlkes_effect.tscn").instantiate() as SparkleEffect
		get_parent().add_child(player_given.sparkles_effect)
	player_given.pause()
	
	player_given.teleport_swirled.emit()
	player_given.sparkles_effect.global_position = player_given.global_position
	player_given.sparkles_effect.show_sparkles()
	# timer so teleport isn't completely instant
	await get_tree().create_timer(0.3).timeout
		
	player_given.global_position = start.global_position
	player_given.rotation = start.rotation
	player_given.teleported.emit()
	
	await get_tree().create_timer(0.5).timeout # waiting for camera
	player_given.sparkles_effect.global_position = player_given.global_position
	
	player_given.reset()
	player_given.unpause()
