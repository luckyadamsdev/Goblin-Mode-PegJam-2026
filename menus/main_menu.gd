extends Control
class_name MainMenu

func _ready() -> void:
	$Panel/StartButton.grab_focus()

func _on_start_button_down() -> void:
	GameManager.instance.go_to_start_screen()
