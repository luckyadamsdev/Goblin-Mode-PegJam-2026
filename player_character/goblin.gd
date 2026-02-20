extends CharacterBody3D
class_name Goblin

const ACCELERATION := 0.2
const MIN_SPEED := 3.0

@export var player_id:int = 1
@export var controller:GoblinController
@export var follow_pivot:Node3D

var current_speed := MIN_SPEED
var follow_direction:Node3D = null
var gravity = ProjectSettings.get_setting('physics/3d/default_gravity')

func _ready() -> void:
	velocity = Vector3(0.0, 0.0, MIN_SPEED)
	controller.set_player_id(player_id)
	follow_direction = follow_pivot.get_child(0)

func _physics_process(delta: float) -> void:
	#poll status from controller
	if controller != null:
		pass

	# apply physics
	current_speed += ACCELERATION * delta
	var new_velocity: Vector3 = basis.z * current_speed
	new_velocity.y = velocity.y - gravity * delta
	velocity = new_velocity
	move_and_slide()
	follow_pivot.look_at(self.global_position + Vector3(controller.h_axis,0.0,-1.0))
	self.look_at(follow_direction.global_position)
	print(controller.h_axis)

func set_start_pos(new_pos:Node3D) -> void:
	visible = true
	global_position = new_pos.global_position
	global_rotation = new_pos.global_rotation
