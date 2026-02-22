extends Node3D
class_name Map

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

var track_zone:Area3D:
	get:
		if track_zone == null:
			track_zone = find_child("track_zone")
		return track_zone

func retart_player(player_given: Goblin) -> void:
	var start = goblin_1_start
	if player_given.player_id == 2:
		start = goblin_2_start
	player_given.global_position = start.global_position
	player_given.rotation = start.rotation
	player_given.reset()
