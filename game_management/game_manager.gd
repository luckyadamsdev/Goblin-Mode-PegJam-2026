extends Node
class_name GameManager

static var instance:GameManager

var current_map:Map 

@export var goblins:Array[Goblin]

## whether the players have pressed buttons to start
var buttons_pressed:Array[bool] = [false, false]

@export var cameras:Array[CameraMovement]

@export var win_screens:Array[Label]

@export var timer_label:TimerLabel

var selected_map_path:String = "res://map/map01.tscn"

var winner:int = 0

enum GameMode {
	MENU,
	RACING,
	WON,
}

var game_mode:GameMode = GameMode.MENU

func _ready() -> void:
	instance = self

func _process(_delta: float) -> void:
	match game_mode:
		GameMode.MENU:
			_handle_menu_mode()
		GameMode.RACING:
			pass
		GameMode.WON:
			pass

func _load_map(map_name:String) -> void:
	if current_map != null:
		clean_up_old_map()
	
	current_map = load(map_name).instantiate() as Map
	add_child(current_map)
	
	# move two goblins to starting positions
	goblins[0].set_start_pos(current_map.goblin_1_start)
	goblins[1].set_start_pos(current_map.goblin_2_start)
	cameras[0].set_target(goblins[0])
	cameras[1].set_target(goblins[1])
	for goblin in goblins:
		goblin.pause() # TODO pause the goblins for the timer?
	start_timer()
	
	current_map.end_zone.body_entered.connect(_on_check_player_finished_race)

func _on_check_player_finished_race(body: Node3D) -> void:
	if body is Goblin:
		if winner == 0: # no winner yet
			winner = (body as Goblin).player_id
			print("is goblin! ", winner)
			win_screens[winner - 1].visible = true
			timer_label.counting = false # we can stop counting
			# open a menu to play again?

func start_timer() -> void:
	# TODO play a start light
	
	print("ready")
	timer_label.show_message("ready")
	await get_tree().create_timer(1.0).timeout
	print("set")
	timer_label.show_message("set")
	await get_tree().create_timer(1.0).timeout
	
	print("go")
	
	for goblin in goblins:
		goblin.unpause()
	#timer_label.start()
	
	
func clean_up_old_map() -> void:
	current_map.end_zone.body_entered.disconnect(_on_check_player_finished_race)
	remove_child(current_map)
	current_map.queue_free()
	
func _handle_menu_mode() -> void:
	# TODO wait for both players to press start?
	# TODO if we have map select, let them select different maps?
	var all_buttons_pressed:bool = true
	for bp in buttons_pressed:
		if bp == false:
			all_buttons_pressed = false
	if all_buttons_pressed:
		game_mode = GameMode.RACING
		_load_map(selected_map_path)
	else:
		# check if any of the players have pressed a button
		for goblin in goblins:
			if goblin.controller.button_one_just_pressed() || goblin.controller.button_two_just_pressed():
				buttons_pressed[goblin.player_id - 1] = true
				print("goblin %d ready!"%goblin.player_id)
