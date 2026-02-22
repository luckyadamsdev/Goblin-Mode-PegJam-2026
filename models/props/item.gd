extends Node3D

func _ready() -> void:
	$ItemArea3D.claimed_item.connect(claim)

func claim():
	queue_free()# TODO disable and re-enable after 1 second
