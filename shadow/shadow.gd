extends MeshInstance3D
class_name Shadow

@export var goblin:Goblin

@export var shadow_range:float = 3.0

@export var position_offset:Vector3 = Vector3(0.0, 0.0, 0.5)

@export var shadow_materal:ShaderMaterial

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
		global_position = raycast.get_collision_point() + normal * 0.01
		shadow_materal.set_shader_parameter("surface_normal", normal)
		shadow_materal.set_shader_parameter("forward", goblin.basis.z)
		shadow_materal.set_shader_parameter("shadow_mult", shadow_mult)
		visible = true
	else:
		visible = false
	raycast.global_position = goblin.to_global(position_offset)
	
