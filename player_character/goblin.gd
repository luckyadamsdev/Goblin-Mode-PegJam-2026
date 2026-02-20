extends Node3D
class_name Goblin

# movement 

@export var controller:GoblinController

func _physics_process(_delta: float) -> void:
	#poll status from controller
	
	# apply physics
	
	
	pass


func set_start_pos(new_pos:Node3D) -> void:
	global_position = new_pos.global_position
	global_rotation = new_pos.global_rotation
	
