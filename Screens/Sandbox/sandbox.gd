extends Control


func _on_to_main_menu_button_pressed() -> void:
	ScreenManager.go_to_screen(ScreenManager.Screen.MAIN_MENU)


func _on_music_1_button_pressed() -> void:
	AudioManager.play_music(AudioManager.Music.THEME_TEST)


func _on_music_2_button_pressed() -> void:
	AudioManager.play_music(AudioManager.Music.THEME_2_TEST)


func _on_stop_music_now_button_pressed() -> void:
	AudioManager.stop_music(0.0)


func _on_stop_music_fade_button_pressed() -> void:
	AudioManager.stop_music()


func _on_pause_music_button_pressed() -> void:
	AudioManager.pause_music()


func _on_resume_music_button_pressed() -> void:
	AudioManager.resume_music()


func _on_play_sfx_button_pressed() -> void:
	AudioManager.play_sound(AudioManager.SoundEffect.UI_BUTTON_CLICK)


func _on_play_sfx_pitch_button_pressed() -> void:
	AudioManager.play_sound(AudioManager.SoundEffect.UI_BUTTON_CLICK, true)
