extends Node
class_name GameManager

static var instance:GameManager

## SIGNALS
signal race_countdown_started()
signal race_start()
signal first_finished()
signal race_over()
signal race_paused()
signal race_resumed()
signal in_main_menu()
signal in_pause_menu()

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

@export var lapLeft: Label
@export var lapRight: Label
@export var placeLeft: Label
@export var placeRight: Label

@export var map_title : Label

@export var hud:Control

@export var racing_overlay:Control

var selected_map_path:String = "res://map/map03.tscn"

# player_id of a the player that reached the finish line
var winner:int = 0

# player_id of player leading the race
var leading_player:int = 0

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
			_handle_racing_mode()
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
	
	map_title.visible = false
	
	racing_overlay.visible = true
	
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
	
	placeLeft.text = ""
	placeRight.text = ""
	
	current_map.end_zone.body_entered.connect(_on_check_player_finished_race) # listen for a goblin reaching the finish line
	current_map.end_zone.collision_mask ^= 2
	
func _on_check_player_finished_race(body: Node3D) -> void:
	if body is Goblin:
		if body.current_lap < 3:
			body.current_lap += 1
			if body.player_id == 1:
				lapLeft.text = 'Lap ' + str(body.current_lap)
			else:
				lapRight.text = 'Lap ' + str(body.current_lap)
			current_map.retart_player(body)
		elif game_mode != GameMode.WON: # no winner yet
			winner = (body as Goblin).player_id
			print("is goblin! ", winner)
			win_screens[winner - 1].visible = true
			timer_label.counting = false # we can stop counting
			game_mode = GameMode.WON
			first_finished.emit();
			race_over.emit()
			cameras[winner - 1].game_mode = GameMode.WON
			if winner == 1:
				goblins[0].place = 1
				goblins[1].place = 2
				placeLeft.text = '1st'
				placeRight.text = '2nd'
			else:
				goblins[0].place = 2
				goblins[1].place = 1
				placeLeft.text = '2nd'
				placeRight.text = '1st'

func start_timer() -> void:
	race_countdown_started.emit()
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
	race_start.emit()
	
## deletes the current map before we laod a new one
func clean_up_old_map() -> void:
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

func go_to_start_screen() -> void:
	#hide main menu
	main_menu.visible = false
	# show hud
	hud.visible = true
	racing_overlay.visible = false
	game_mode = GameMode.MENU

func go_to_main_menu() -> void:
	#hide main menu
	main_menu.visible = true
	main_menu.set_focus()
	# show hud
	hud.visible = false
	game_mode = GameMode.MENU
	in_main_menu.emit()


func go_to_pause_menu() -> void:
	# show main menu
	pause_menu.visible = true
	pause_menu.set_focus()
	# hide hud
	hud.visible = false
	game_mode = GameMode.PAUSE_MENU
	race_paused.emit()
	in_pause_menu.emit()

func unpause() -> void:
	game_mode = GameMode.RACING
	main_menu.visible = false
	pause_menu.visible = false
	get_tree().paused = false
	race_resumed.emit()

func back_to_main_menu() -> void:
	game_mode = GameMode.MAIN_MENU
	main_menu.visible = true
	main_menu.set_focus()
	pause_menu.visible = false
	get_tree().paused = false
	clean_up_old_map()
	for goblin in goblins:
		goblin.pause()
	for camera in cameras:
		camera.game_mode = GameMode.MENU

func set_map_tile(title:String) -> void:
	map_title.text = title
	map_title.visible = true

func _handle_racing_mode() -> void:
	if Input.is_action_just_pressed("pause"):
		game_mode = GameMode.PAUSE_MENU
		pause_menu.visible = true
		pause_menu.set_focus()
		get_tree().paused = true
	else:
		if current_map.is_race:
			if goblins[1].current_lap < goblins[0].current_lap:
				set_leading(1)
			elif goblins[0].current_lap < goblins[1].current_lap:
				set_leading(2)
			else:
				for goblin in goblins:
					# player_id of 2 had index of 1, but player_id mod 2 gets index of 0 which is player 1
					# player_id of 1 had index of 0, and player_id mod 2 gets index of 1 which is player 2
					# so this gets the other goblin
					# I'm very sorry
					var other_goblin_id := (goblin.player_id) % 2
					var other_goblin := goblins[other_goblin_id]
					# needs to exceed other by a little before it counts as taking the lead
					if (goblin.global_position.y < other_goblin.global_position.y - 0.2):
						set_leading(goblin.player_id)

func set_leading(player_id:int) -> void:
	if player_id == leading_player:
		return
	leading_player = player_id
	match player_id:
		1:
			goblins[0].place = 1
			goblins[1].place = 2
			placeLeft.text = '1st'
			placeRight.text = '2nd'
			var tween := create_tween()
			tween.set_parallel(false)
			tween.tween_property(placeLeft, "scale", Vector2.ONE * 2.0, 0.02)
			tween.tween_property(placeLeft, "scale", Vector2.ONE * 1.0, 0.3)
		2:
			goblins[0].place = 2
			goblins[1].place = 1
			placeLeft.text = '2nd'
			placeRight.text = '1st'
			var tween := create_tween()
			tween.set_parallel(false)
			tween.tween_property(placeRight, "scale", Vector2.ONE * 2.0, 0.02)
			tween.tween_property(placeRight, "scale", Vector2.ONE * 1.0, 0.3)
