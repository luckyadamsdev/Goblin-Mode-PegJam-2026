extends Node

var game_manager:GameManager
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
