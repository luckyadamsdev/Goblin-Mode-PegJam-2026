extends MeshInstance3D
class_name Shadow

@export var goblin:Goblin

@export var shadow_range:float = 3.0

@export var position_offset:Vector3 = Vector3(0.0, 0.0, 0.5)

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
	raycast.global_position = goblin.to_global(position_offset)
	if raycast.is_colliding():
		var normal := raycast.get_collision_normal()
		global_position = raycast.get_collision_point() + normal * 0.01
		look_at(global_position + normal)
		visible = true
	else:
		#print("not colliding ", goblin.global_position)
		visible = false
