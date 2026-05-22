extends Control


# Video settings controls
@onready var _16_9_radio: CheckBox = %"16_9_Radio"
@onready var _16_10_radio: CheckBox = %"16_10_Radio"
@onready var _21_9_radio: CheckBox = %"21_9_Radio"

@onready var resolution_option: OptionButton = %Resolution_Option
@onready var fullscreen_toggle: CheckButton = %Fullscreen_Toggle

const PROJECT_RESOLUTION: Vector2i = Vector2i(1920,1080)

const SCREEN_RESOLUTIONS: Dictionary = {
	"16_by_9": {
		"640x360": Vector2i(640,360),
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


@onready var icon_2: Sprite2D = %Icon2
@onready var icon: Sprite2D = %Icon

func _ready() -> void:
	#TODO: Create current settings from saved settings (e.g. resolution, volumes, etc)
	
	_populate_resolution_options("16_by_9")
	
	
	
func _process(delta: float) -> void:
	icon.rotation_degrees += 30 * delta
	icon_2.rotation_degrees -= 60 * delta
	

#region Display Buttons

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
	var resolution = resolution_option.get_item_metadata(resolution_option.get_selected_id())
	
	if fullscreen_toggle.button_pressed:
		_apply_fullscreen_settings(resolution)
	else:
		_apply_windowed_settings(resolution)
	
	_apply_max_fps_settings()


#endregion

#region Max FPS Buttons

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


func _populate_resolution_options(ratio: String) -> void:
	resolution_option.clear()
	var index = 0
	for res in SCREEN_RESOLUTIONS[ratio]:
		resolution_option.add_item(res)
		resolution_option.set_item_metadata(index, SCREEN_RESOLUTIONS[ratio][res])
		index += 1


func _apply_fullscreen_settings(resolution: Vector2i) -> void:
	get_viewport().size = resolution
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _apply_windowed_settings(resolution: Vector2i) -> void:
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(resolution)



func _apply_max_fps_settings() -> void:
	Engine.max_fps = max_FPS
