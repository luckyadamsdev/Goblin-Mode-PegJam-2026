extends CharacterBody3D
class_name Goblin

signal jumped()
signal landed()
signal speed_increased(new_speed:float)
signal fell_down()

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

enum ItemStateKeys {
	NONE,
	ANVIL,
	BOMB,
}

# whether the goblin is currently paused and waiting to move
var goblin_paused:bool = true

var banked_spins := 0
var current_lap := 1
var current_speed := MIN_SPEED
var gravity = ProjectSettings.get_setting('physics/3d/default_gravity')
var is_on_track := true
var item_state:ItemStateKeys = ItemStateKeys.NONE
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
	# movement logic
	_handle_accelerate(delta)
	move_and_slide()
	_handle_jumps(delta)
	_handle_lands()
	_handle_rotation_controls(delta)
	_handle_stretching()
	_hand_item_usage()
	was_on_floor = is_on_floor()

func _hand_item_usage() -> void:
	if item_state != ItemStateKeys.NONE and controller.button_two_just_pressed():
		_enter_item_state_none()

func _enter_item_state_none() -> void:
	item_state = ItemStateKeys.NONE
	goblin_template.normal_hands.visible = true
	goblin_template.item_hands.visible = false

func _enter_item_state_anvil() -> void:
	item_state = ItemStateKeys.ANVIL
	goblin_template.normal_hands.visible = false
	goblin_template.item_hands.visible = true
	goblin_template.item_anvil.visible = true

func _apply_jump_force() -> void:
	velocity.y += JUMP_VELOCITY_ADD + clamp(get_real_velocity().y * JUMP_VELOCITY_MULT, 0.0, MAX_JUMP_MULT)

func _handle_stretching() -> void:
	# when rising and falling
	var target_rise_fall_stretch = clamp(1.0 + 0.1 * get_real_velocity().y, 0.9, 1.2)
	goblin_template.scale.y = lerpf(goblin_template.scale.y, target_rise_fall_stretch, 0.1)
	# crouching for speed boost
	var target_crouch_squash = clamp(_get_brake_turn_change(true), 0.5, 1.0)
	self.scale.y = lerpf(self.scale.y, target_crouch_squash, 0.1)
	self.scale.x = lerpf(self.scale.x, 1.0 + 0.5 * (1.0 - target_crouch_squash), 0.1)

func _handle_lands() -> void:
	if not was_on_floor and is_on_floor():
		time_since_jumped_in_air = 10.0
		banked_spins = 0
		if anim.current_animation == 'spin':
			anim.play('fall')
			current_speed = MIN_SPEED
			fell_down.emit()
		else:
			anim.play('land')
			current_speed += TRICK_SPEED_BOOST * num_tricks_in_air
			speed_increased.emit(current_speed)
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
			_jump()
	else:
		time_since_on_floor += delta
		if COYOTE_TIME < time_since_jumped_in_air and time_since_jumped_in_air < 0.5:
			_do_spin_trick()
	time_since_jumped_in_air += delta
	if controller.button_one_just_pressed():
		if time_since_on_floor < COYOTE_TIME and anim.current_animation != 'fall' and anim.current_animation != 'spin':
			_jump()
		else:
			time_since_jumped_in_air = 0.0
			banked_spins += 1

func _get_combined_real_velocity_value() -> float:
	var real_velocity = get_real_velocity()
	return abs(real_velocity.normalized().x * real_velocity.x) + abs(real_velocity.normalized().z * real_velocity.z)

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
	current_speed = clamp(current_speed, MIN_SPEED, MAX_SPEED)

	if _get_combined_real_velocity_value() < MIN_SPEED * 0.5:
		current_speed = MIN_SPEED

	var new_velocity: Vector3 = basis.z * current_speed
	new_velocity.y = velocity.y - gravity * delta
	velocity = new_velocity

func _get_speed_rotate_strength() -> float:
	var normalized_velocity := Vector2(abs(velocity.x), abs(velocity.z)).normalized()
	return clamp(0.5 + 0.015 * abs(velocity.x) * normalized_velocity.x + 0.015 * abs(velocity.z) * normalized_velocity.y, 0.5, 2.0)

func _get_brake_speed_change() -> float:
	return (-1 + clamp(_get_brake_turn_change(true), 0.9, 2.6)) * FRICTION

func _get_brake_turn_change(ignore_floor:=false) -> float:
	if is_on_floor() or ignore_floor:
		return clamp(1.0 + 2.0 * controller.v_axis, 0.5, 3.0)
	else:
		return 1.0

func _handle_rotation_controls(delta: float) -> void:
	if is_on_floor():
		# going up means get_real_velocity().y = positive -> fast turning. going down means get_real_velocity().y = negative -> slow turning
		var slope_rotate_strength:float = clamp(0.2 * (6.5 + get_real_velocity().y), 0.5, 2.0)
		# going fast means you turn faster
		var speed_rotate_strength:float = _get_speed_rotate_strength()

		var brake_turn_change := _get_brake_turn_change()

		follow_pivot.rotation.y = -1.0 * brake_turn_change * controller.h_axis * delta * slope_rotate_strength * speed_rotate_strength

		self.look_at(to_global(follow_pivot.quaternion * follow_direction.position))
	else:
		self.rotate(Vector3.UP, -controller.h_axis * delta)

	goblin_template.rotation.x = deg_to_rad(-1.0 * get_real_velocity().y)
	tilt_turn_target = 0.02 * controller.h_axis * _get_combined_real_velocity_value()
	goblin_template.displayHolder.position.x = lerpf(goblin_template.displayHolder.position.x, 0.4 * tilt_turn_target, 0.03)
	goblin_template.rotation.z = lerpf(goblin_template.rotation.z, tilt_turn_target, 0.03)
	goblin_template.normal_hands.rotation.y = goblin_template.rotation.z * -1.0
	goblin_template.item_hands.rotation.y = goblin_template.rotation.z * 1.2
	goblin_template.item_hands.position.x = -0.5 * abs(goblin_template.rotation.z)

func set_start_pos(new_pos:Node3D) -> void:
	visible = true
	global_position = new_pos.global_position
	global_rotation = new_pos.global_rotation
	print("setting start position ", global_rotation, ", ", new_pos.global_rotation)

func _jump() -> void:
	_apply_jump_force()
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
	num_tricks_in_air = 0
	tilt_turn_target = 0.0
	time_since_jumped_in_air = 10.0
	time_since_on_floor = 10.0
	_enter_item_state_none()

func finished_trick() -> void:
	num_tricks_in_air += 1
	if 1 < banked_spins:
		banked_spins -= 1
		_do_spin_trick()

func _on_track_area_entered(area: Area3D) -> void:
	if area.name == 'ItemArea3D':
		area.claim()
		_enter_item_state_anvil()
	else:
		is_on_track = true

func _on_track_area_exited(area: Area3D) -> void:
	if area.name != 'ItemArea3D':
		is_on_track = false

func print_p1(value_given) -> void:
	if player_id == 1:
		print(value_given)
