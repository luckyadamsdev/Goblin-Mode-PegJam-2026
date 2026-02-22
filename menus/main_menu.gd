extends Control
class_name MainMenu

@export var places:Control

@export var laps:Control

func _ready() -> void:
	await get_tree().process_frame
	$Panel/PracticeButton.grab_focus()
	
func set_focus() -> void:
	$Panel/PracticeButton.grab_focus()

func _on_practice_button_pressed() -> void:
	places.visible = false
	laps.visible = false
	GameManager.instance.selected_map_path = "res://map/map04.tscn"
	GameManager.instance.set_map_tile("Practice")
	# do we need ot show title of selected map somewhere?
	GameManager.instance.go_to_start_screen()

func _on_vs_button_pressed() -> void:
	places.visible = true
	laps.visible = true
	GameManager.instance.selected_map_path = "res://map/map03.tscn"
	GameManager.instance.set_map_tile("VS Race")
	GameManager.instance.go_to_start_screen()

func _on_test_map_pressed() -> void:
	places.visible = true
	GameManager.instance.selected_map_path = "res://map/short_map.tscn"
	GameManager.instance.set_map_tile("Secret Third Map")
	GameManager.instance.go_to_start_screen()
