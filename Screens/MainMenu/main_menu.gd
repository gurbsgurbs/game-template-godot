extends Control


func _on_button_pressed() -> void:
	ScreenManager.go_to_screen(ScreenManager.Screen.SETTINGS)


func _on_debug_button_2_pressed() -> void:
	ScreenManager.go_to_screen(ScreenManager.Screen.SANDBOX)
