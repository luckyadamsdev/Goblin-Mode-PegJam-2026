extends Node
class_name GoblinController

@export var control_def:GoblinControlDefinition

var v_axis:float = 0.0
var h_axis:float = 0.0

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	update_inputs()

func update_inputs() -> void:
	v_axis = Input.get_axis(control_def.up, control_def.down)
	h_axis = Input.get_axis(control_def.left, control_def.right)

func set_player_id(id: int):
	# Only call this function once or else values will be something like this: "p1_p1_up"
	control_def.up      = 'p' + str(id) + '_' + control_def.up
	control_def.down    = 'p' + str(id) + '_' + control_def.down
	control_def.left    = 'p' + str(id) + '_' + control_def.left
	control_def.right   = 'p' + str(id) + '_' + control_def.right
	control_def.button1 = 'p' + str(id) + '_' + control_def.button1
	control_def.button2 = 'p' + str(id) + '_' + control_def.button2


func button_one_pressed() -> bool:
	return Input.is_action_pressed(control_def.button1)
	
func button_two_pressed() -> bool:
	return Input.is_action_pressed(control_def.button1)
	
func button_one_just_pressed() -> bool:
	return Input.is_action_just_pressed(control_def.button1)
	
func button_two_just_pressed() -> bool:
	return Input.is_action_just_pressed(control_def.button2)
	
func button_one_just_released() -> bool:
	return Input.is_action_just_released(control_def.button1)
	
func button_two_just_released() -> bool:
	return Input.is_action_just_released(control_def.button2)
