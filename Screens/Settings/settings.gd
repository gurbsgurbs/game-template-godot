extends Control
## Settings screen

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


# Localization controls
@onready var localization_option: OptionButton = %Localization_Option

# Other
@onready var cursor_toggle: CheckButton = %Cursor_Toggle

# TESTING: FPS TEST !!!!REMOVE LATER!!!!
@onready var icon_2: Sprite2D = %Icon2
@onready var icon: Sprite2D = %Icon


func _ready() -> void:
	_load_state_settings()


# TESTING: !!!!REMOVE LATER!!!!
func _process(delta: float) -> void:
	icon.rotation_degrees += 30 * delta
	icon_2.rotation_degrees -= 60 * delta


func _load_state_settings() -> void:
	# ---- Graphics ----
	var fullscreen: bool = SettingsManager.settings.get_value("Graphics", "fullscreen")
	var aspect_ratio: String = SettingsManager.settings.get_value("Graphics", "aspect_ratio")
	
	# Fullscreen toggle
	fullscreen_toggle.button_pressed = fullscreen
	_populate_size_options(aspect_ratio)
	if fullscreen:
		window_size_option.disabled = true
		window_size_option.text = "n/a"
	else:
		_pick_current_size_option()
	
	# Aspect Ratio radio buttons
	match aspect_ratio:
		"16_by_9":
			_16_9_radio.button_pressed = true
		"16_by_10":
			_16_10_radio.button_pressed = true
		"21_by_9":
			_21_9_radio.button_pressed = true
	
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

	# ---- Audio ----
	mute_toggle.button_pressed = SettingsManager.settings.get_value("Audio", "mute")
	master_slider.volume_slider.value = SettingsManager.settings.get_value("Audio", "master_volume")
	sfx_slider.volume_slider.value = SettingsManager.settings.get_value("Audio", "sfx_volume")
	music_slider.volume_slider.value = SettingsManager.settings.get_value("Audio", "music_volume")
	
	# ---- Localization ----
	_populate_localization_option()
	_pick_current_locale_option()
	
	# ---- Cursor ----
	cursor_toggle.button_pressed = SettingsManager.settings.get_value("Visuals", "custom_cursor")


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
		SettingsManager.settings.set_value("Graphics", "fullscreen", false)
		var aspect_ratio: String = SettingsManager.settings.get_value("Graphics", "aspect_ratio")
		_populate_size_options(aspect_ratio)
		_pick_default_size_in_ratio(aspect_ratio)


func _on_16_9_radio_pressed() -> void:
	SettingsManager.settings.set_value("Graphics", "aspect_ratio", "16_by_9")
	_populate_size_options("16_by_9")
	if fullscreen_toggle.button_pressed:
		_disable_window_size_option()
		return
	_pick_default_size_in_ratio("16_by_9")


func _on_16_10_radio_pressed() -> void:
	SettingsManager.settings.set_value("Graphics", "aspect_ratio", "16_by_10")
	_populate_size_options("16_by_10")
	if fullscreen_toggle.button_pressed:
		_disable_window_size_option()
		return
	_pick_default_size_in_ratio("16_by_10")


func _on_21_9_radio_pressed() -> void:
	SettingsManager.settings.set_value("Graphics", "aspect_ratio", "21_by_9")
	_populate_size_options("21_by_9")
	if fullscreen_toggle.button_pressed:
		_disable_window_size_option()
		return
	_pick_default_size_in_ratio("21_by_9")


func _on_window_size_option_item_selected(_index: int) -> void:
	var window_size = window_size_option.get_item_metadata(window_size_option.get_selected_id())
	SettingsManager.settings.set_value("Graphics", "window_size_w", window_size.x)
	SettingsManager.settings.set_value("Graphics", "window_size_h", window_size.y)


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


func _on_apply_video_button_pressed() -> void:
	SettingsManager.apply_video_settings()

#endregion


#region Other controls

func _on_localization_option_item_selected(index: int) -> void:
	var locale = localization_option.get_item_metadata(index)
	TranslationServer.set_locale(locale)
	SettingsManager.settings.set_value("Locale", "locale", locale)


func _on_cursor_toggle_toggled(toggled_on: bool) -> void:
	CursorManager.set_custom_cursor(toggled_on)
	SettingsManager.settings.set_value("Visuals", "custom_cursor", toggled_on)


func _on_reset_button_pressed() -> void:
	SettingsManager.reset_settings()
	_load_state_settings()

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
	var saved_w: int = SettingsManager.settings.get_value("Graphics", "window_size_w")
	var saved_h: int = SettingsManager.settings.get_value("Graphics", "window_size_h")
	var saved_size: Vector2i = Vector2i(saved_w, saved_h)
	
	for i in window_size_option.item_count:
		if window_size_option.get_item_metadata(i) == saved_size:
			window_size_option.select(i)
			return
	
	# Fallback: If saved size is not found for some reason, pick the default value from saved aspect ratio
	var aspect_ratio: String = SettingsManager.settings.get_value("Graphics", "aspect_ratio")
	_pick_default_size_in_ratio(aspect_ratio)


func _enable_window_size_option() -> void:
	window_size_option.disabled = false


func _disable_window_size_option() -> void:
	window_size_option.disabled = true
	window_size_option.text = "n/a"


func _populate_localization_option() -> void:
	localization_option.clear()
	var index = 0
	for locale in TranslationServer.get_loaded_locales():
		var translation_resource = TranslationServer.get_translation_object(locale)
		var native_name = translation_resource.get_message("LANGUAGE_NAME")
		localization_option.add_item(native_name)
		localization_option.set_item_metadata(index, locale)
		index += 1


func _pick_current_locale_option() -> void:
	var saved_locale = SettingsManager.settings.get_value("Locale", "locale")
	for i in localization_option.item_count:
		if localization_option.get_item_metadata(i) == saved_locale:
			localization_option.select(i)
			return


func _on_debug_button_pressed() -> void:
	SettingsManager.save_settings_to_file()
	ScreenManager.go_to_screen(ScreenManager.Screen.MAIN_MENU)
