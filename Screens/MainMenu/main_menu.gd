extends Control

const CONFIRM_QUIT_MODAL = preload("uid://bf6j0e30qtq4x")

func _on_button_pressed() -> void:
	ScreenManager.go_to_screen(ScreenManager.Screen.SETTINGS)


func _on_debug_button_2_pressed() -> void:
	ScreenManager.go_to_screen(ScreenManager.Screen.SANDBOX)


func _on_debug_button_3_pressed() -> void:
	var modal = CONFIRM_QUIT_MODAL.instantiate()
	add_child(modal)
