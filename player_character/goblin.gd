extends CharacterBody3D
class_name Goblin

const ACCELERATION := 0.2
const MIN_SPEED := 3.0

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
	var new_velocity: Vector3 = basis.z * current_speed
	new_velocity.y = velocity.y - gravity * delta
	velocity = new_velocity
	move_and_slide()
	# self.look_at(self.global_position + Vector3(0.5,0.3,0.9))

func set_start_pos(new_pos:Node3D) -> void:
	global_position = new_pos.global_position
	global_rotation = new_pos.global_rotation
	