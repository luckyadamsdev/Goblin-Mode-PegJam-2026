extends Camera3D
class_name CameraMovement


@export var follow_distance := 5.0

@export var follow_height := 2.0

@export var goblin : Node3D

@export var starting_offset:Vector3 = Vector3(0.0, 2.0, -4.0)

@export var look_curve:Curve

var start_rotation : Vector3
var start_position : Vector3

## position that the camera would be 
var target_position: Vector3

var last_target_position: Vector3

var last_target_velocity: Vector3

var max_accel:float = 3.0

func _ready():
	start_rotation = global_rotation
	start_position = global_position
	target_position = global_position
	last_target_position = target_position
	last_target_velocity = Vector3.ZERO

func _physics_process(_delta : float):
	var delta_v := target_position - goblin.global_position
	delta_v.y = 0.0
	var follow_distance_with_speed := follow_distance # + clampf(car_body.linear_velocity.length(), 0.0, 2.0)
	
	if (delta_v.length() > follow_distance_with_speed):
		delta_v = delta_v.normalized() * follow_distance_with_speed
		delta_v.y = follow_height
		
		last_target_position = target_position
		target_position = goblin.global_position + delta_v
		var velo_target_postion = last_target_position + last_target_velocity
		#target_position = lerp(velo_target_postion, target_position, 0.01)
		
		global_position = target_position
		
		last_target_velocity = (target_position - last_target_position)
	
	var look_position:Vector3 = goblin.global_position
	
	look_at(look_position + Vector3.UP, Vector3.UP)

func set_target(new_target:Node3D) -> void:
	goblin = new_target
	global_position = new_target.to_global(starting_offset)
	look_at(goblin.global_position)
