extends Control
class_name PauseMenu

func set_focus() -> void:
	$Panel/ContinuePlaying.grab_focus()

func _on_continue_playing_pressed() -> void:
	GameManager.instance.unpause()

func _on_main_menu_pressed() -> void:
	GameManager.instance.back_to_main_menu()
