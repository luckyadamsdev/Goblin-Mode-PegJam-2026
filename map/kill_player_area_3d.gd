extends Area3D

@onready var map_parent = get_parent()

func _physics_process(delta: float) -> void:
	if Global.game_manager.goblins[0].global_position.y < global_position.y:
		map_parent.restart_player(Global.game_manager.goblins[0])
	if Global.game_manager.goblins[1].global_position.y < global_position.y:
		map_parent.restart_player(Global.game_manager.goblins[1])
