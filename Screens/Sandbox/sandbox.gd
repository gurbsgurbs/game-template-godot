extends Control



func _on_to_main_menu_button_pressed() -> void:
	ScreenManager.go_to_screen(ScreenManager.Screen.MAIN_MENU)


func _on_button_pressed() -> void:
	AudioManager.play_music(AudioManager.Music.THEME_TEST)


func _on_button_2_pressed() -> void:
	AudioManager.play_music(AudioManager.Music.THEME_2_TEST)


func _on_button_4_pressed() -> void:
	AudioManager._music_stop_all_players()
