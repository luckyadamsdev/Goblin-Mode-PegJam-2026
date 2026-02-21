extends CharacterBody3D
class_name Goblin

const ACCELERATION := 0.2
const MIN_SPEED := 3.0

@export var player_id:int = 1
@export var controller:GoblinController
@export var follow_pivot:Node3D

# whether the goblin is currently paused and waiting to move
var goblin_paused:bool = true

var current_speed := MIN_SPEED
var follow_direction:Node3D = null
var gravity = ProjectSettings.get_setting('physics/3d/default_gravity')

func _ready() -> void:
	velocity = Vector3(0.0, 0.0, MIN_SPEED)
	controller.set_player_id(player_id)
	follow_direction = follow_pivot.get_child(0)

func _physics_process(delta: float) -> void:
	if goblin_paused:
		return
	# movement logic
	handle_accelerate(delta)
	move_and_slide()
	handle_rotation_controls(delta)

func handle_accelerate(delta: float) -> void:
	current_speed += ACCELERATION * delta
	var new_velocity: Vector3 = basis.z * current_speed
	new_velocity.y = velocity.y - gravity * delta
	velocity = new_velocity

func handle_rotation_controls(delta: float) -> void:
	follow_pivot.rotation.y = -1.0 * controller.h_axis * delta
	if is_on_floor():
		var floor_normal := quaternion.inverse() * get_floor_normal()
		# I'm using quaternion which is local to parent but if we always keep goblins out of rotated parents that's fine
		# floor_normal is now in goblin space
		# we create a quaternion that rotates from our up to the floor normal
		var axis := -floor_normal.cross(Vector3.UP).normalized()
		var angle := Vector3.UP.angle_to(floor_normal)
		var slope_rotation := Quaternion.IDENTITY if angle == 0.0 else Quaternion(axis, angle)
		self.look_at(to_global( slope_rotation * follow_pivot.quaternion * follow_direction.position))
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

func pause() -> void:
	goblin_paused = true
	
func unpause() -> void:
	goblin_paused = false
