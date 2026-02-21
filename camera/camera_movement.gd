extends Camera3D
class_name CameraMovement


@export var follow_distance := 5.0

@export var follow_height := 2.0

@export var vertical_offset := 1.0

@export var goblin : Goblin

@export var starting_offset:Vector3 = Vector3(0.0, 2.0, -4.0)

@export var look_curve:Curve


## position that the camera would be 
var target_position: Vector3

var last_target_position: Vector3

var last_target_velocity: Vector3

var max_accel:float = 3.0

const REMEMBER_TIME:float = 1.0 / 15.0

const MAX_MEMORY:int = 20

var remember_counter:float = REMEMBER_TIME

var remember_velocity:Array[Vector3]

func _ready():
	target_position = global_position
	last_target_position = target_position
	last_target_velocity = Vector3.ZERO
	goblin.landed.connect(_on_landed)
	goblin.jumped.connect(_on_jumped)

func _physics_process(delta : float):
	if goblin == null:
		return
	
	## track old velocities of goblin
	remember_counter -= delta
	if remember_counter <= 0.0:
		remember_counter = REMEMBER_TIME
		remember_velocity.append(goblin.velocity)
		if remember_velocity.size() > MAX_MEMORY:
			remember_velocity.pop_front()
	
	var global_look_at_position := goblin.global_position
	global_look_at_position.y += vertical_offset
	var delta_v := target_position - global_look_at_position
	delta_v.y = 3.0
	var follow_distance_with_speed := follow_distance
	
	if (delta_v.length() > follow_distance_with_speed):
		delta_v = delta_v.normalized() * follow_distance_with_speed
		delta_v.y = follow_height
		
		last_target_position = target_position
		target_position = global_look_at_position + delta_v
		
		global_position = target_position
		
		last_target_velocity = (target_position - last_target_position)
	
	var look_position:Vector3 = global_look_at_position
	
	look_at(look_position + Vector3.UP, Vector3.UP)

func set_target(new_target:Node3D) -> void:
	goblin = new_target
	global_position = new_target.to_global(starting_offset)
	target_position = global_position
	look_at(goblin.global_position)

func _on_landed() -> void:
	pass

func _on_jumped() -> void:
	pass
