extends CharacterBody3D
class_name Goblin

const ACCELERATION := 0.2
const MIN_SPEED := 1.0

@export var player_id:int = 1
@export var controller:GoblinController

var current_speed := MIN_SPEED
var gravity = ProjectSettings.get_setting('physics/3d/default_gravity')

func _ready() -> void:
	velocity = Vector3(0.0, 0.0, MIN_SPEED)

func _physics_process(delta: float) -> void:
	#poll status from controller
	if controller != null:
		pass

	# apply physics
	current_speed += ACCELERATION * delta
	velocity.y -= gravity * delta
	velocity.z = current_speed
	move_and_slide()

func set_start_pos(new_pos:Node3D) -> void:
	global_position = new_pos.global_position
	global_rotation = new_pos.global_rotation
	