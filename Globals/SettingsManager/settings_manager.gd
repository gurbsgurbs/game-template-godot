extends Node
## Screen Manager


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
		"mute": true,
		"master_volume": 1.0,
		"sfx_volume": 1.0,
		"music_volume": 1.0,
	}
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


# Virtual methods

func _ready() -> void:
	load_settings()
	#apply_settings()

#region Save/Load/Reset Settings

## Saves the settings ConfigFile to disk.
func save_settings() -> void:
	var err: Error = settings.save(SAVE_PATH)
	if err != OK:
		push_error("SettingsManager: Saving settings failed. Error: " + str(err))


## Loads the settings from disk. If a settings file is not available, loads from default.
func load_settings() -> void:
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
func apply_settings() -> void:
	
	# Graphics
	if settings.get_value("Graphics", "fullscreen") == true:
		_apply_fullscreen_settings()
	else:
		_apply_windowed_settings()
	
	_apply_max_fps_settings()
	
	# Audio
	# Audio values are changed at runtime, and saved to settings here
	settings.set_value("Audio", "mute", AudioServer.is_bus_mute(0))
	settings.set_value("Audio", "master_volume", AudioServer.get_bus_volume_linear(0))
	settings.set_value("Audio", "sfx_volume", AudioServer.get_bus_volume_linear(1))
	settings.set_value("Audio", "music_volume", AudioServer.get_bus_volume_linear(2))
	
	save_settings()
	pass


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
	_center_window()


func _apply_max_fps_settings() -> void:
	Engine.max_fps = settings.get_value("Graphics", "max_FPS") as int


func _center_window() -> void:
	var screen_size: Vector2i = DisplayServer.screen_get_size()
	var window_size: Vector2i = DisplayServer.window_get_size()
	@warning_ignore("integer_division")
	var target_position: Vector2i = (screen_size - window_size) / 2
	DisplayServer.window_set_position(target_position)


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
