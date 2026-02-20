extends Node
class_name GameManager

static var instance:GameManager

var current_map:Map 

@export var goblins:Array[Goblin]

@export var cameras:Array[CameraMovement]



func _ready() -> void:
	instance = self
	_load_map("res://map/map01.tscn")

func _load_map(map_name:String) -> void:
	current_map = load(map_name).instantiate() as Map
	add_child(current_map)
	
	# move two goblins to starting positions
	goblins[0].set_start_pos(current_map.goblin_1_start)
	goblins[1].set_start_pos(current_map.goblin_2_start)
	cameras[0].set_target(goblins[0])
	cameras[1].set_target(goblins[1])
	
	current_map.end_zone.body_entered.connect(_on_check_player_finished_race)

func _on_check_player_finished_race(body: Node3D) -> void:
	pass
