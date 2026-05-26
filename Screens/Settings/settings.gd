extends Control

# Video settings controls
@onready var fullscreen_toggle: CheckButton = %Fullscreen_Toggle

@onready var _16_9_radio: CheckBox = %"16_9_Radio"
@onready var _16_10_radio: CheckBox = %"16_10_Radio"
@onready var _21_9_radio: CheckBox = %"21_9_Radio"

@onready var window_size_option: OptionButton = %WindowSize_Option

@onready var fps_15_radio: CheckBox = %FPS_15_Radio
@onready var fps_30_radio: CheckBox = %FPS_30_Radio
@onready var fps_60_radio: CheckBox = %FPS_60_Radio
@onready var fps_120_radio: CheckBox = %FPS_120_Radio
@onready var fps_240_radio: CheckBox = %FPS_240_Radio


# Audio controls
@onready var mute_toggle: TextureButton = %Mute_Toggle
@onready var master_slider: VBoxContainer = %Master_Slider
@onready var sfx_slider: VBoxContainer = %SFX_Slider
@onready var music_slider: VBoxContainer = %Music_Slider

# TESTING: FPS TEST !!!!REMOVE LATER!!!!
@onready var icon_2: Sprite2D = %Icon2
@onready var icon: Sprite2D = %Icon


func _ready() -> void:
	_load_state_settings()


func _load_state_settings() -> void:
	# ---- Graphics ----
	# Fullscreen toggle
	fullscreen_toggle.button_pressed = SettingsManager.settings.get_value("Graphics", "fullscreen")
	
	# Aspect Ratio radio buttons
	var aspect_ratio: String = SettingsManager.settings.get_value("Graphics", "aspect_ratio")
	match aspect_ratio:
		"16_by_9":
			_16_9_radio.button_pressed = true
		"16_by_10":
			_16_10_radio.button_pressed = true
		"21_by_9":
			_21_9_radio.button_pressed = true
	_populate_size_options(aspect_ratio)
	
	# Window Size option dropdown
	
	
	
	# Max FPS radio buttons
	match SettingsManager.settings.get_value("Graphics", "max_FPS"):
		15:
			fps_15_radio.button_pressed = true
		30:
			fps_30_radio.button_pressed = true
		60:
			fps_60_radio.button_pressed = true
		120:
			fps_120_radio.button_pressed = true
		240:
			fps_240_radio.button_pressed = true
	
	## ---- Audio ----
	#mute_toggle.button_pressed = SettingsManager.settings.get_value("Audio", "mute")
	#master_slider.volume_slider.value = SettingsManager.settings.get_value("Audio", "master_volume")
	#sfx_slider.volume_slider.value = SettingsManager.settings.get_value("Audio", "sfx_volume")
	#music_slider.volume_slider.value = SettingsManager.settings.get_value("Audio", "music_volume")
	
	# ---- Audio ----
	mute_toggle.button_pressed = AudioManager.is_master_mute()
	master_slider.volume_slider.value = AudioManager.get_master_volume()
	sfx_slider.volume_slider.value = AudioManager.get_sfx_volume()
	music_slider.volume_slider.value = AudioManager.get_music_volume()


# TESTING: !!!!REMOVE LATER!!!!
func _process(delta: float) -> void:
	icon.rotation_degrees += 30 * delta
	icon_2.rotation_degrees -= 60 * delta
	

#region Display Controls

func _on_fullscreen_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on:
		# Disable window size dropdown
		window_size_option.disabled = true
		window_size_option.text = "n/a"
		SettingsManager.settings.set_value("Graphics", "fullscreen", true)
	else:
		# Enable window size dropdown
		window_size_option.disabled = false
		_set_resolution_label_from_current_window_size() # TODO: 1- Probably change this: When tuning off from fullscreen, go to default res from screen size, always.
		SettingsManager.settings.set_value("Graphics", "fullscreen", false)


func _on_16_9_radio_pressed() -> void:
	_populate_size_options("16_by_9")
	_pick_default_size_in_ratio("16_by_9")
	SettingsManager.settings.set_value("Graphics", "aspect_ratio", "16_by_9")


func _on_16_10_radio_pressed() -> void:
	_populate_size_options("16_by_10")
	_pick_default_size_in_ratio("16_by_10")
	SettingsManager.settings.set_value("Graphics", "aspect_ratio", "16_by_10")


func _on_21_9_radio_pressed() -> void:
	_populate_size_options("21_by_9")
	_pick_default_size_in_ratio("21_by_9")
	SettingsManager.settings.set_value("Graphics", "aspect_ratio", "21_by_9")


func _on_window_size_option_item_selected(_index: int) -> void:
	var window_size = window_size_option.get_item_metadata(window_size_option.get_selected_id())
	SettingsManager.settings.set_value("Graphics", "window_size_w", window_size.x)
	SettingsManager.settings.set_value("Graphics", "window_size_h", window_size.y)

#endregion

#region Max FPS Controls

func _on_fps_15_radio_pressed() -> void:
	SettingsManager.settings.set_value("Graphics", "max_FPS", 15)


func _on_fps_30_radio_pressed() -> void:
	SettingsManager.settings.set_value("Graphics", "max_FPS", 30)


func _on_fps_60_radio_pressed() -> void:
	SettingsManager.settings.set_value("Graphics", "max_FPS", 60)


func _on_fps_120_radio_pressed() -> void:
	SettingsManager.settings.set_value("Graphics", "max_FPS", 120)


func _on_fps_240_radio_pressed() -> void:
	SettingsManager.settings.set_value("Graphics", "max_FPS", 240)

#endregion



func _populate_size_options(ratio: String) -> void:
	window_size_option.clear()
	var index = 0
	for res in SettingsManager.WINDOW_SIZES[ratio]:
		window_size_option.add_item(res)
		window_size_option.set_item_metadata(index, SettingsManager.WINDOW_SIZES[ratio][res])
		index += 1


func _pick_default_size_in_ratio(aspect_ratio) -> void:
	var window_size: Vector2i = SettingsManager.RESOLUTION_FULLSCREEN_DEFAULT[aspect_ratio]
	for i in window_size_option.item_count:
		if window_size_option.get_item_metadata(i) == window_size:
			window_size_option.select(i)
			window_size_option.emit_signal("item_selected", i) 
			return



func _pick_current_size_option() -> void:
	pass


func _on_apply_button_pressed() -> void:
	SettingsManager.apply_settings()





# TODO: 2 - Might remove this, not needed
func _set_resolution_label_from_current_window_size() -> void:
	var current_resolution: Vector2i = get_tree().root.size
	window_size_option.text = str(current_resolution.x) + "x" + str(current_resolution.y)

# TODO: 2 - Might remove this, not needed
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


func _on_debug_button_pressed() -> void:
	ScreenManager.go_to_screen(ScreenManager.Screen.MAIN_MENU)
