extends Node
class_name GameManager

static var instance:GameManager

var current_map:Map 

@export var goblins:Array[Goblin]

## whether the players have pressed buttons to start
var buttons_pressed:Array[bool] = [false, false]

@export var cameras:Array[CameraMovement]

@export var win_screens:Array[Control]

@export var ready_screens:Array[Control]

@export var press_to_start_screens:Array[Control]

@export var timer_label:TimerLabel

@export var main_menu:MainMenu

@export var pause_menu:PauseMenu

@export var hud:Control

var selected_map_path:String = "res://map/map03.tscn"

var winner:int = 0

enum GameMode {
	MENU,
	RACING,
	WON,
	STARTING,
	PAUSE_MENU,
	MAIN_MENU,
}

var game_mode:GameMode = GameMode.MAIN_MENU

func _ready() -> void:
	instance = self

func _process(_delta: float) -> void:
	match game_mode:
		GameMode.MENU:
			_handle_menu_mode()
		GameMode.RACING:
			if Input.is_action_just_pressed("pause"):
				game_mode = GameMode.PAUSE_MENU
				pause_menu.visible = true
				pause_menu.set_focus()
				get_tree().paused = true
		GameMode.WON:
			_handle_menu_mode()
		GameMode.PAUSE_MENU:
			if Input.is_action_just_pressed("pause"):
				unpause()
		GameMode.MAIN_MENU:
			pass # don't need to do anything else


func _load_map(map_name:String) -> void:
	if current_map != null:
		clean_up_old_map()
	
	buttons_pressed.fill(false)
	## hide any other messages
	for r in ready_screens:
		r.visible = false
	for w in win_screens:
		w.visible = false
	
	current_map = load(map_name).instantiate() as Map
	add_child(current_map)
	
	# move two goblins to starting positions
	goblins[0].set_start_pos(current_map.goblin_1_start)
	goblins[1].set_start_pos(current_map.goblin_2_start)
	for camera in cameras:
		camera.game_mode = GameMode.STARTING
		camera.bonus_follow_distance = 4.0
	cameras[0].set_target(goblins[0])
	cameras[1].set_target(goblins[1])
	for goblin in goblins:
		goblin.pause() # pause the goblins for the timer to complete
		goblin.reset()
	start_timer()
	
	if current_map.track_zone != null:
		current_map.track_zone.area_entered.connect(_on_entered_track_zone)
		current_map.track_zone.body_exited.connect(_on_exited_track_zone)
	current_map.end_zone.body_entered.connect(_on_check_player_finished_race) # listen for a goblin reaching the finish line
	current_map.end_zone.collision_mask ^= 2
	
func _on_check_player_finished_race(body: Node3D) -> void:
	if body is Goblin:
		if game_mode != GameMode.WON: # no winner yet
			winner = (body as Goblin).player_id
			print("is goblin! ", winner)
			win_screens[winner - 1].visible = true
			timer_label.counting = false # we can stop counting
			game_mode = GameMode.WON
			cameras[winner - 1].game_mode = GameMode.WON

func start_timer() -> void:
	# TODO play a start light
	for camera in cameras:
		camera.game_mode = GameMode.STARTING
	print("ready")
	timer_label.show_message("ready")
	await get_tree().create_timer(1.0).timeout
	print("set")
	timer_label.show_message("set")
	await get_tree().create_timer(1.0).timeout
	
	print("go")
	for camera in cameras:
		camera.game_mode = GameMode.RACING
	for goblin in goblins:
		goblin.unpause()
	timer_label.start()
	
## deletes the current map before we laod a new one
func clean_up_old_map() -> void:
	if current_map.track_zone != null:
		current_map.track_zone.body_entered.disconnect(_on_entered_track_zone)
		current_map.track_zone.body_exited.disconnect(_on_exited_track_zone)
	current_map.end_zone.body_entered.disconnect(_on_check_player_finished_race)
	remove_child(current_map)
	current_map.queue_free()

## when in menu mode, wait for both goblins to press a button
func _handle_menu_mode() -> void:
	
	var all_buttons_pressed:bool = true
	for bp in buttons_pressed:
		if bp == false:
			all_buttons_pressed = false
	if all_buttons_pressed:
		buttons_pressed.fill(false)
		game_mode = GameMode.RACING
		_load_map(selected_map_path)
	else:
		# check if any of the players have pressed a button
		for goblin in goblins:
			if goblin.controller.button_one_just_pressed() || goblin.controller.button_two_just_pressed():
				buttons_pressed[goblin.player_id - 1] = true
				print("goblin %d ready!" % goblin.player_id)
				ready_screens[goblin.player_id - 1].visible = true
				press_to_start_screens[goblin.player_id - 1].visible = false


func _on_entered_track_zone(body: Node3D) -> void:
	if body is Goblin:
		var goblin := body as Goblin
		goblin.enter_track()
	
func _on_exited_track_zone(body: Node3D) -> void:
	if body is Goblin:
		var goblin := body as Goblin
		goblin.exit_track()

func go_to_start_screen() -> void:
	#hide main menu
	main_menu.visible = false
	# show hud
	hud.visible = true
	game_mode = GameMode.MENU

func go_to_main_menu() -> void:
	#hide main menu
	main_menu.visible = true
	# show hud
	hud.visible = false
	game_mode = GameMode.MENU


func go_to_pause_menu() -> void:
	# show main menu
	pause_menu.visible = true
	pause_menu.set_focus()
	# hide hud
	hud.visible = false
	game_mode = GameMode.PAUSE_MENU

func unpause() -> void:
	game_mode = GameMode.RACING
	main_menu.visible = false
	pause_menu.visible = false
	get_tree().paused = false

func back_to_main_menu() -> void:
	game_mode = GameMode.MAIN_MENU
	main_menu.visible = true
	pause_menu.visible = false
	get_tree().paused = false
	clean_up_old_map()
	for goblin in goblins:
		goblin.pause()
	for camera in cameras:
		camera.game_mode = GameMode.MENU
