extends TextureButton

func _on_toggled(toggled_on: bool) -> void:
	AudioManager.set_master_mute(toggled_on)
	SettingsManager.settings.set_value("Audio", "mute", toggled_on)
