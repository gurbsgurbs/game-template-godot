extends Node
## Settings Manager


# Save configuration file
const SAVE_PATH: String = "user://settings.cfg"

const DEFAULT_SETTINGS: Dictionary = {
	"Graphics": {
		"fullscreen": false,
		"aspect_ratio": "16_by_9",
		"window_size_w": 1920,
		"window_size_h": 1080,
		"max_FPS": 120,
	},
	"Audio": {
		"mute": false,
		"master_volume": 1.0,
		"sfx_volume": 1.0,
		"music_volume": 1.0,
	},
	"Locale": {
		"locale": "en"
	},
	"Visuals": {
		"custom_cursor": true
	},
}

var settings: ConfigFile = ConfigFile.new()


# Visual Settings

const RESOLUTION_FULLSCREEN_DEFAULT: Dictionary = {
	"16_by_9": Vector2i(1920,1080),
	"16_by_10": Vector2i(1920,1200),
	"21_by_9": Vector2i(2560,1080),
}

const WINDOW_SIZES: Dictionary = {
	"16_by_9": {
		"1280x720": Vector2i(1280,720),
		"1920x1080": Vector2i(1920,1080),
		"2560x1440": Vector2i(2560,1440),
		"3840x2160": Vector2i(3840,2160),
	},
	"16_by_10": {
		"1280x800": Vector2i(1280,800),
		"1440x900": Vector2i(1440,900),
		"1920x1200": Vector2i(1920,1200),
		"2560x1600": Vector2i(2560,1600)
	},
	"21_by_9": {
		"2560x1080": Vector2i(2560,1080),
		"3440x1440": Vector2i(3440,1440),
	}
}


func _ready() -> void:
	load_settings_from_file()
	apply_video_settings()
	apply_settings()

#region Save/Load/Reset Settings

## Saves the settings ConfigFile to disk.
func save_settings_to_file() -> void:
	var err: Error = settings.save(SAVE_PATH)
	if err != OK:
		push_error("SettingsManager: Saving settings failed. Error: " + str(err))


## Loads the settings from disk. If a settings file is not available, loads from default.
func load_settings_from_file() -> void:
	# Load settings + handle errors
	var err: Error = settings.load(SAVE_PATH)
	if err != OK:
		# No settings file found, create default.
		if err == ERR_FILE_NOT_FOUND:
			reset_settings()
		else: push_error("SettingsManager: Loading settings failed. Error: " + str(err))


## Reset settings to default values
func reset_settings() -> void:
	settings.clear()
	for section: String in DEFAULT_SETTINGS.keys():
		for key: String in DEFAULT_SETTINGS[section].keys():
			settings.set_value(section, key, DEFAULT_SETTINGS[section][key])

#endregion

## Apply the settings. Also saves the settings file.
func apply_video_settings() -> void:
	
	# Graphics
	if settings.get_value("Graphics", "fullscreen") == true:
		_apply_fullscreen_settings()
	else:
		_apply_windowed_settings()
	
	_apply_max_fps_settings()
	
	save_settings_to_file() # TODO: This should also move away.

func apply_settings() -> void:
	# ---- Audio ----
	AudioManager.set_master_mute(settings.get_value("Audio", "mute"))
	AudioManager.set_master_volume(settings.get_value("Audio", "master_volume"))
	AudioManager.set_sfx_volume(settings.get_value("Audio", "sfx_volume"))
	AudioManager.set_music_volume(settings.get_value("Audio", "music_volume"))
	# ---- Locale ----
	TranslationServer.set_locale(settings.get_value("Locale", "locale"))
	# ---- Visuals ----
	CursorManager.set_custom_cursor(settings.get_value("Visuals", "custom_cursor"))



### Saves the non-video settings in the configuration file.
### When changed, these settings are seen in real-time, but they need to be saved.
#func save_settings() -> void:
	## ---- Audio ----
	#settings.set_value("Audio", "mute", AudioManager.is_master_mute())
	#settings.set_value("Audio", "master_volume", AudioManager.get_master_volume())
	#settings.set_value("Audio", "sfx_volume", AudioManager.get_sfx_volume())
	#settings.set_value("Audio", "music_volume", AudioManager.get_music_volume())
	## ---- Locale ----
	##settings.set_value("Locale", "locale", )
	## ---- Visuals ----
	
	
	save_settings_to_file()


func is_fullscreen() -> bool:
	var current_mode = DisplayServer.window_get_mode()
	if current_mode == DisplayServer.WINDOW_MODE_WINDOWED:
		return false
	elif current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN or current_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		return true
	else:
		return false


func _apply_fullscreen_settings() -> void:
	var aspect_ratio: String = settings.get_value("Graphics", "aspect_ratio") as String
	get_tree().root.content_scale_size = RESOLUTION_FULLSCREEN_DEFAULT[aspect_ratio]
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _apply_windowed_settings() -> void:
	var window_width: int = settings.get_value("Graphics", "window_size_w") as int
	var window_height: int = settings.get_value("Graphics", "window_size_h") as int
	var window_size: Vector2i = Vector2i(window_width, window_height)
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(window_size)
	#_center_window() # <- BUG: Was misbehaving when the computer has two monitors


func _apply_max_fps_settings() -> void:
	Engine.max_fps = settings.get_value("Graphics", "max_FPS") as int


# Not being used, needs more work for identifying current screen.
func _center_window() -> void:
	var screen_size: Vector2i = DisplayServer.screen_get_size()
	var window_size: Vector2i = DisplayServer.window_get_size()
	@warning_ignore("integer_division")
	var target_position: Vector2i = (screen_size - window_size) / 2
	DisplayServer.window_set_position(target_position)


# Not being used, currently
func _get_aspect_ratio_from_screen_size() -> String:
	var screen_size: Vector2i = DisplayServer.screen_get_size()
	var aspect_ratio: float
	var aspect_ratio_string: String
	
	aspect_ratio = float(screen_size.x) / float(screen_size.y)
	
	if aspect_ratio > 2.0:
		aspect_ratio_string = "21_by_9"
	elif aspect_ratio > 1.7:
		aspect_ratio_string = "16_by_9"
	elif aspect_ratio > 1.5:
		aspect_ratio_string = "16_by_10"
		
	return aspect_ratio_string
