extends Control
class_name MainMenu

func _ready() -> void:
	await get_tree().process_frame
	$Panel/StartButton.grab_focus()

func _on_start_button_pressed() -> void:
	GameManager.instance.go_to_start_screen()
