extends CharacterBody3D
class_name Goblin

const ACCELERATION := 0.2
const COYOTE_TIME := 0.2
const JUMP_VELOCITY := 5.0
const MIN_SPEED := 3.0

@export var player_id:int = 1
@export var controller:GoblinController
@export var follow_pivot:Node3D

var goblin_paused:bool = true

var current_speed := MIN_SPEED
var follow_direction:Node3D = null
var gravity = ProjectSettings.get_setting('physics/3d/default_gravity')
var time_since_jumped_in_air := 10.0
var time_since_on_floor := 10.0

func _ready() -> void:
	velocity = Vector3(0.0, 0.0, MIN_SPEED)
	controller.set_player_id(player_id)
	follow_direction = follow_pivot.get_child(0)

func _physics_process(delta: float) -> void:
	if goblin_paused:
		return
	# movement logic
	_handle_accelerate(delta)
	_handle_jumps(delta)
	move_and_slide()
	_handle_rotation_controls(delta)

func _handle_jumps(delta: float) -> void:
	# lets player jump even if they pressed the button too early or too late
	if is_on_floor():
		time_since_on_floor = 0.0
		if time_since_jumped_in_air < COYOTE_TIME:
			velocity.y += JUMP_VELOCITY
			time_since_jumped_in_air = COYOTE_TIME
	else:
		time_since_on_floor += delta
	time_since_jumped_in_air += delta
	if controller.button_one_just_pressed():
		if time_since_on_floor < COYOTE_TIME:
			velocity.y += JUMP_VELOCITY
			time_since_on_floor = COYOTE_TIME
		else:
			time_since_jumped_in_air = 0.0

func _handle_accelerate(delta: float) -> void:
	current_speed += ACCELERATION * delta
	var new_velocity: Vector3 = basis.z * current_speed
	new_velocity.y = velocity.y - gravity * delta
	velocity = new_velocity

func _handle_rotation_controls(delta: float) -> void:
	follow_pivot.rotation.y = -1.0 * controller.h_axis * delta
	self.look_at(follow_direction.global_position)

func set_start_pos(new_pos:Node3D) -> void:
	visible = true
	global_position = new_pos.global_position
	global_rotation = new_pos.global_rotation
	print("setting start position ", global_rotation, ", ", new_pos.global_rotation)

func pause() -> void:
	goblin_paused = true
	
func unpause() -> void:
	goblin_paused = false
