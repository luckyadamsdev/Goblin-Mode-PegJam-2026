extends MeshInstance3D
class_name Shadow

@export var goblin:Goblin

@export var shadow_range:float = 3.2

@export var position_offset:Vector3 = Vector3(0.0, 0.2, 0.4)

@export var shadow_materal:ShaderMaterial

var pan_value:float = 0.0

var raycast:RayCast3D

func _ready() -> void:
	raycast = RayCast3D.new()
	raycast.target_position = Vector3.DOWN * shadow_range
	raycast.collision_mask = 1
	raycast.enabled = true
	raycast.collide_with_bodies = true
	get_parent_node_3d().add_child.call_deferred(raycast)
	
	visible = false

func _process(_delta: float) -> void:
	if raycast.is_colliding():
		var normal := raycast.get_collision_normal()
		var shadow_dist := raycast.get_collision_point().distance_to(raycast.global_position)
		var shadow_mult:float = clamp(shadow_range - shadow_dist, 0.0, 1.0)
		var new_position := raycast.get_collision_point() + normal * 0.01
		var relative_velocity := Plane(normal).project(goblin.velocity)
		pan_value += new_position.distance_to(global_position)
		global_position = new_position
		shadow_materal.set_shader_parameter("surface_normal", normal)
		shadow_materal.set_shader_parameter("forward", goblin.basis.z)
		shadow_materal.set_shader_parameter("shadow_mult", shadow_mult)
		shadow_materal.set_shader_parameter("pan_value", pan_value)
		shadow_materal.set_shader_parameter("speed", relative_velocity.length())
		visible = true
	else:
		visible = false
	raycast.global_position = goblin.to_global(position_offset)
	
