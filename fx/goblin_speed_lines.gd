extends Node3D
class_name GoblinSpeedLines

@export var goblin:Goblin

@export var speed_material:ShaderMaterial

func _ready() -> void:
	goblin.speed_increased.connect(_on_speed_increased)

func _process(_delta: float) -> void:
	if visible == true:
		global_position = goblin.goblin_template.global_position
		global_rotation = goblin.goblin_template.global_rotation
		speed_material.set_shader_parameter("velocity", goblin.velocity)

func _on_speed_increased(_new_speed:float) -> void:
	visible = true
	await get_tree().create_timer(1.2).timeout
	visible = false
