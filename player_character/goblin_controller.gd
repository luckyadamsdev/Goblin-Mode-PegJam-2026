extends Node
class_name GoblinController

@export var control_def:GoblinControlDefinition

var v_axis:float = 0.0
var h_axis:float = 0.0
var button1:bool = false
var button2:bool = false

var button1changed:bool = false
var button2changed:bool = false

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
