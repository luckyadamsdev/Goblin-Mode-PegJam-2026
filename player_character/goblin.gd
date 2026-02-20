extends CharacterBody3D
class_name Goblin

@export var player_id:int = 1

# movement 

@export var controller:GoblinController

func _physics_process(_delta: float) -> void:
	#poll status from controller
	if controller != null:
		pass
	# apply physics
	
	
	pass


func set_start_pos(new_pos:Node3D) -> void:
	visible = true
	global_position = new_pos.global_position
	global_rotation = new_pos.global_rotation
	
