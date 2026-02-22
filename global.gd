extends Node

var game_manager:GameManager
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

# TODO don't queue_free() items, they should re-appear
# TODO place way more items in the course