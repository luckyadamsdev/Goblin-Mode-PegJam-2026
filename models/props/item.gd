extends Node3D

const TIME_INVISIBLE := 2.0

var invisible_timer := 0.0
var start_position := Vector3()

func _ready() -> void:
	$ItemArea3D.claimed_item.connect(claim)

func claim():
	invisible_timer = TIME_INVISIBLE
	start_position = global_position
	global_position.y += 10000.0

func _physics_process(delta: float) -> void:
	if 0.0 < invisible_timer:
		invisible_timer -= delta
		if invisible_timer <= 0.0:
			global_position = start_position
	else:
		invisible_timer = 0.0
