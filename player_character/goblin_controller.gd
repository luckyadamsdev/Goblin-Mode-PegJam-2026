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

func update_inputs() -> void:
	v_axis = Input.get_axis(control_def.up, control_def.down)
	h_axis = Input.get_axis(control_def.left, control_def.right)
	pass
