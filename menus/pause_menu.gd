extends Control
class_name PauseMenu

func _ready() -> void:
	$Panel/ContinuePlaying.grab_focus()


func _on_continue_playing_button_down() -> void:
	GameManager.instance.unpause()


func _on_back_button_down() -> void:
	GameManager.instance.back_to_main_menu()
