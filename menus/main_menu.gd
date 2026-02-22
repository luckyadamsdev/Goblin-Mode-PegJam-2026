extends Control
class_name MainMenu

func _ready() -> void:
	await get_tree().process_frame
	$Panel/StartButton.grab_focus()
	
func set_focus() -> void:
	$Panel/StartButton.grab_focus()

func _on_practice_button_pressed() -> void:
	GameManager.instance.selected_map_path = "res://map/map04.tscn"
	GameManager.instance.set_map_tile("Practice")
	# do we need ot show title of selected map somewhere?
	GameManager.instance.go_to_start_screen()

func _on_vs_button_pressed() -> void:
	GameManager.instance.selected_map_path = "res://map/map03.tscn"
	GameManager.instance.set_map_tile("VS Race")
	GameManager.instance.go_to_start_screen()
