extends Node

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

var resolution_ratio: String = "16_by_9"
var max_FPS: int = 60


func _ready() -> void:
	reset_settings()
	save_settings()


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


func apply_settings() -> void:
	pass
