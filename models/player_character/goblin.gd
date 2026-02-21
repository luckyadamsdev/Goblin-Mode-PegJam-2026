extends CharacterBody3D
class_name Goblin

signal jumped()
signal landed()


const BASE_ACCELERATION := 0.1
const COYOTE_TIME := 0.2
const JUMP_VELOCITY_ADD := 6.0
const JUMP_VELOCITY_MULT := 1.0
const MIN_SPEED := 3.0
const MAX_SPEED := 50.0

const LAND_THRESHOLD_TIME := 1.0 # don't count as "landing" unless you're in the air this long

@export var player_id:int = 1
@export var controller:GoblinController
@export var follow_pivot:Node3D

# whether the goblin is currently paused and waiting to move
var goblin_paused:bool = true

var current_speed := MIN_SPEED
var follow_direction:Node3D = null
var gravity = ProjectSettings.get_setting('physics/3d/default_gravity')
var time_since_jumped_in_air := 10.0
var time_since_on_floor := 10.0

var on_track:bool = false
@onready var goblin_template:Node3D = $GoblinTemplate

func _ready() -> void:
	velocity = Vector3(0.0, 0.0, MIN_SPEED)
	controller.set_player_id(player_id)
	follow_direction = follow_pivot.get_child(0)

func _physics_process(delta: float) -> void:
	if goblin_paused:
		return
	# movement logic
	_handle_accelerate(delta)
	move_and_slide()
	_handle_jumps(delta)
	_handle_rotation_controls(delta)

func apply_jump_force() -> void:
	velocity.y += JUMP_VELOCITY_ADD + get_real_velocity().y * JUMP_VELOCITY_MULT

func _handle_jumps(delta: float) -> void:
	# lets player jump even if they pressed the button too early or too late
	if is_on_floor():
		if time_since_on_floor > LAND_THRESHOLD_TIME:
			landed.emit()
		time_since_on_floor = 0.0
		if time_since_jumped_in_air < COYOTE_TIME:
			jump()
	else:
		time_since_on_floor += delta
	time_since_jumped_in_air += delta
	if controller.button_one_just_pressed():
		if time_since_on_floor < COYOTE_TIME:
			jump()
		else:
			time_since_jumped_in_air = 0.0

func _handle_accelerate(delta: float) -> void:
	current_speed += BASE_ACCELERATION * delta
	if is_on_floor():
		var realVelocityY := get_real_velocity().y
		if realVelocityY < 0.0:
			current_speed -= get_real_velocity().y * delta
		else:
			current_speed -= get_real_velocity().y * delta * 0.1
	current_speed = min(current_speed, MAX_SPEED)
	var new_velocity: Vector3 = basis.z * current_speed
	new_velocity.y = velocity.y - gravity * delta
	velocity = new_velocity

func _get_speed_rotate_strength() -> float:
	var normalized_velocity := Vector2(abs(velocity.x), abs(velocity.z)).normalized()
	return clamp(0.5 + 0.015 * abs(velocity.x) * normalized_velocity.x + 0.015 * abs(velocity.z) * normalized_velocity.y, 0.5, 2.0)

func _handle_rotation_controls(delta: float) -> void:
	if is_on_floor():
		var floor_normal := quaternion.inverse() * get_floor_normal()
		# I'm using quaternion which is local to parent but if we always keep goblins out of rotated parents that's fine
		# floor_normal is now in goblin space
		# we create a quaternion that rotates from our up to the floor normal
		var axis := -floor_normal.cross(Vector3.UP).normalized()
		var angle := Vector3.UP.angle_to(floor_normal)

		# going up means get_real_velocity().y = positive -> fast turning. going down means get_real_velocity().y = negative -> slow turning
		var slope_rotate_strength:float = clamp(0.2 * (6.5 + get_real_velocity().y), 0.5, 2.0)
		# going fast means you turn faster
		var speed_rotate_strength:float = _get_speed_rotate_strength()

		follow_pivot.rotation.y = -1.0 * controller.h_axis * delta * slope_rotate_strength * speed_rotate_strength

		# TODO need to smooth out the slope rotation 
		# maybe use .slerp with - b + (a - b) * 2.71828 ** (-decay * dt)
		# - expDecay(a, b, decay = 16, delta) # stole from Freya Holmer's lerp smoothing video
		# or just slerp at constant rate, whichever looks better
		var slope_rotation := Quaternion.IDENTITY if angle == 0.0 else Quaternion(axis, angle)
		self.look_at(to_global(follow_pivot.quaternion * follow_direction.position))
		goblin_template.look_at(slope_rotation * follow_direction.position)
		goblin_template.rotation.y = 0.0
	else:
		#var look_vec := follow_direction.global_position
		#look_vec.y = 0.0
		#self.look_at(to_global(look_vec))
		self.rotate(Vector3.UP, -controller.h_axis * delta)

func set_start_pos(new_pos:Node3D) -> void:
	visible = true
	global_position = new_pos.global_position
	global_rotation = new_pos.global_rotation
	print("setting start position ", global_rotation, ", ", new_pos.global_rotation)

func jump() -> void:
	apply_jump_force()
	time_since_jumped_in_air = COYOTE_TIME
	time_since_on_floor = COYOTE_TIME
	jumped.emit()

func pause() -> void:
	goblin_paused = true
	
func unpause() -> void:
	goblin_paused = false
	
# reset any parameters on the goblin that need resetting when starting the race again
func reset() -> void:
	velocity = Vector3(0.0, 0.0, MIN_SPEED) #
	current_speed = MIN_SPEED
	
func enter_track() -> void:
	on_track = true
	
func exit_track() -> void:
	on_track = false
