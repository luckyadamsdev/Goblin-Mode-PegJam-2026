extends CharacterBody3D
class_name Goblin

signal jumped()
signal landed()

const BASE_ACCELERATION := 0.05
const COYOTE_TIME := 0.2
const FRICTION := 0.3
const FRICTION_OFF_TRACK := 0.2
const JUMP_VELOCITY_ADD := 6.0
const JUMP_VELOCITY_MULT := 10.0
const MAX_JUMP_MULT := 5.0
const MIN_SPEED := 16.0
const MAX_SPEED := 50.0
const TRICK_SPEED_BOOST := 10.0

const LAND_THRESHOLD_TIME := 1.0 # don't count as "landing" unless you're in the air this long

@export var player_id:int = 1
@export var controller:GoblinController
@export var follow_pivot:Node3D
@export var follow_direction:Node3D

# whether the goblin is currently paused and waiting to move
var goblin_paused:bool = true

var banked_spins := 0
var current_speed := MIN_SPEED
var gravity = ProjectSettings.get_setting('physics/3d/default_gravity')
var is_on_track := true
var num_tricks_in_air := 0
var tilt_turn_target := 0.0
var time_since_jumped_in_air := 10.0
var time_since_on_floor := 10.0
var was_on_floor := false

@onready var goblin_template:Node3D = $GoblinTemplate
@onready var anim:AnimationPlayer = goblin_template.get_animation_player()

func _ready() -> void:
	velocity = Vector3(0.0, 0.0, MIN_SPEED)
	controller.set_player_id(player_id)

func _physics_process(delta: float) -> void:
	if goblin_paused:
		return
	# if is_off_track:
	# 	self.scale.z = 2.0
	# else:
	# 	self.scale.z = 1.0
	# movement logic
	_handle_accelerate(delta)
	move_and_slide()
	_handle_jumps(delta)
	_handle_lands()
	_handle_rotation_controls(delta)
	was_on_floor = is_on_floor()
	goblin_template.scale.y = clamp(1.0 + 0.1 * get_real_velocity().y, 0.9, 1.2)

func apply_jump_force() -> void:
	velocity.y += JUMP_VELOCITY_ADD + clamp(get_real_velocity().y * JUMP_VELOCITY_MULT, 0.0, MAX_JUMP_MULT)

func _handle_lands() -> void:
	if not was_on_floor and is_on_floor():
		time_since_jumped_in_air = 10.0
		banked_spins = 0
		if anim.current_animation == 'spin':
			anim.play('fall')
			current_speed = MIN_SPEED
		else:
			anim.play('land')
			current_speed += TRICK_SPEED_BOOST * num_tricks_in_air
		anim.queue('idle')
		num_tricks_in_air = 0

func _do_spin_trick():
	anim.play('spin')
	anim.queue('idle')

func _handle_jumps(delta: float) -> void:
	# lets player jump even if they pressed the button too early or too late
	if is_on_floor():
		if time_since_on_floor > LAND_THRESHOLD_TIME:
			landed.emit()
		time_since_on_floor = 0.0
		if time_since_jumped_in_air < COYOTE_TIME and anim.current_animation != 'fall' and anim.current_animation != 'spin':
			jump()
	else:
		time_since_on_floor += delta
		if COYOTE_TIME < time_since_jumped_in_air and time_since_jumped_in_air < 0.5:
			_do_spin_trick()
	time_since_jumped_in_air += delta
	if controller.button_one_just_pressed():
		if time_since_on_floor < COYOTE_TIME:
			jump()
		else:
			time_since_jumped_in_air = 0.0
			banked_spins += 1

func _handle_accelerate(delta: float) -> void:
	current_speed += BASE_ACCELERATION * delta
	current_speed -= _get_brake_speed_change()
	if is_on_floor() and not is_on_track:
		current_speed -= FRICTION_OFF_TRACK
	current_speed = max(MIN_SPEED, current_speed)
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

func _get_brake_speed_change() -> float:
	return (-1 + _get_brake_turn_change()) * FRICTION

func _get_brake_turn_change() -> float:
	if is_on_floor():
		return clamp(1.0 + 2.0 * controller.v_axis, 1.0, 3.0)
	else:
		return 1.0

func _handle_rotation_controls(delta: float) -> void:
	if is_on_floor():
		# going up means get_real_velocity().y = positive -> fast turning. going down means get_real_velocity().y = negative -> slow turning
		var slope_rotate_strength:float = clamp(0.2 * (6.5 + get_real_velocity().y), 0.5, 2.0)
		# going fast means you turn faster
		var speed_rotate_strength:float = _get_speed_rotate_strength()

		follow_pivot.rotation.y = -1.0 * _get_brake_turn_change() * controller.h_axis * delta * slope_rotate_strength * speed_rotate_strength

		self.look_at(to_global(follow_pivot.quaternion * follow_direction.position))
	else:
		self.rotate(Vector3.UP, -controller.h_axis * delta)

	goblin_template.rotation.x = deg_to_rad(-1.0 * get_real_velocity().y)
	tilt_turn_target = controller.h_axis * 0.5
	goblin_template.rotation.z = lerpf(goblin_template.rotation.z, tilt_turn_target, 0.03)

func set_start_pos(new_pos:Node3D) -> void:
	visible = true
	global_position = new_pos.global_position
	global_rotation = new_pos.global_rotation
	print("setting start position ", global_rotation, ", ", new_pos.global_rotation)

func jump() -> void:
	apply_jump_force()
	time_since_jumped_in_air = 10.0
	time_since_on_floor = 10.0
	jumped.emit()
	anim.play('jump')

func pause() -> void:
	goblin_paused = true
	
func unpause() -> void:
	goblin_paused = false
	
# reset any parameters on the goblin that need resetting when starting the race again
func reset() -> void:
	velocity = Vector3(0.0, 0.0, MIN_SPEED)
	current_speed = MIN_SPEED
	goblin_template.rotation.x = 0
	anim.play('idle')

func finished_trick() -> void:
	num_tricks_in_air += 1
	if 1 < banked_spins:
		banked_spins -= 1
		_do_spin_trick()

func _on_track_area_entered(_area: Area3D) -> void:
	is_on_track = true

func _on_track_area_exited(_area: Area3D) -> void:
	is_on_track = false

func print_p1(string_given: String) -> void:
	if player_id == 1:
		print(string_given)
