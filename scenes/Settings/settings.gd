extends Control

# Video settings controls
@onready var _16_9_radio: CheckBox = %"16_9_Radio"
@onready var _16_10_radio: CheckBox = %"16_10_Radio"
@onready var _21_9_radio: CheckBox = %"21_9_Radio"

@onready var window_size_option: OptionButton = %WindowSize_Option
@onready var fullscreen_toggle: CheckButton = %Fullscreen_Toggle

# Audio controls
@onready var mute_toggle: TextureButton = %Mute_Toggle
@onready var master_slider: VBoxContainer = %Master_Slider
@onready var sfx_slider: VBoxContainer = %SFX_Slider
@onready var music_slider: VBoxContainer = %Music_Slider



# Save
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

var config: ConfigFile = ConfigFile.new()


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


@onready var icon_2: Sprite2D = %Icon2 # TODO: REMOVE LATER
@onready var icon: Sprite2D = %Icon # TODO: REMOVE LATER

func _ready() -> void:
	_load_settings()
	_set_resolution_label_from_current_window_size()
	_populate_resolution_options("16_by_9")
	
	
	
func _process(delta: float) -> void:
	icon.rotation_degrees += 30 * delta
	icon_2.rotation_degrees -= 60 * delta
	

#region Display Controls

func _on_16_9_radio_pressed() -> void:
	resolution_ratio = "16_by_9"
	_populate_resolution_options(resolution_ratio)


func _on_16_10_radio_pressed() -> void:
	resolution_ratio = "16_by_10"
	_populate_resolution_options(resolution_ratio)


func _on_21_9_radio_pressed() -> void:
	resolution_ratio = "21_by_9"
	_populate_resolution_options(resolution_ratio)


func _on_apply_button_pressed() -> void:
	if fullscreen_toggle.button_pressed:
		_apply_fullscreen_settings()
	else:
		var resolution_to_apply = window_size_option.get_item_metadata(window_size_option.get_selected_id())
		_apply_windowed_settings(resolution_to_apply)
	
	_apply_max_fps_settings()


#endregion

#region Max FPS Controls

func _on_fps_15_radio_pressed() -> void:
	max_FPS = 15


func _on_fps_30_radio_pressed() -> void:
	max_FPS = 30


func _on_fps_60_radio_pressed() -> void:
	max_FPS = 60


func _on_fps_120_radio_pressed() -> void:
	max_FPS = 120


func _on_fps_240_radio_pressed() -> void:
	max_FPS = 240

#endregion

#region Audio Controls



func _populate_resolution_options(ratio: String) -> void:
	if fullscreen_toggle.button_pressed== false:
		window_size_option.clear()
		var index = 0
		for res in WINDOW_SIZES[ratio]:
			window_size_option.add_item(res)
			window_size_option.set_item_metadata(index, WINDOW_SIZES[ratio][res])
			index += 1


func _apply_fullscreen_settings() -> void:
	get_tree().root.content_scale_size = RESOLUTION_FULLSCREEN_DEFAULT[resolution_ratio]
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _apply_windowed_settings(resolution: Vector2i) -> void:
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(resolution)


func _apply_display_settings(resolution: Vector2i) -> void:
	if fullscreen_toggle.button_pressed:
		_apply_fullscreen_settings()
	else:
		var resolution_to_apply = window_size_option.get_item_metadata(window_size_option.get_selected_id())
		_apply_windowed_settings(resolution_to_apply)


func _apply_max_fps_settings() -> void:
	Engine.max_fps = max_FPS


func _on_fullscreen_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on:
		# Disable window size dropdown
		window_size_option.disabled = true
		window_size_option.text = "n/a"
	else:
		# Enable window size dropdown
		window_size_option.disabled = false
		_set_resolution_label_from_current_window_size()
		
		


func _set_resolution_label_from_current_window_size() -> void:
	var current_resolution: Vector2i = get_tree().root.size
	window_size_option.text = str(current_resolution.x) + "x" + str(current_resolution.y)


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



func _save_settings() -> void:
	pass


func _load_settings() -> void:
	config.load(SAVE_PATH)
