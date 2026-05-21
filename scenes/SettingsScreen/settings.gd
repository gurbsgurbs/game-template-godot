extends Control

@onready var resolution_option: OptionButton = %ResolutionOption
@onready var display_option: OptionButton = %DisplayOption

var resolution_ratio: String = "16_by_9"

var screen_resolutions: Dictionary = {
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


func _ready() -> void:
	pass


func _populate_resolution_options(ratio: String) -> void:
	resolution_option.clear()
	var index = 0
	for res in screen_resolutions[ratio]:
		resolution_option.add_item(res)
		resolution_option.set_item_metadata(index, screen_resolutions[ratio][res])
		index += 1


func _on_radio_16_9_pressed() -> void:
	resolution_ratio = "16_by_9"
	_populate_resolution_options(resolution_ratio)


func _on_radio_16_10_pressed() -> void:
	resolution_ratio = "16_by_10"
	_populate_resolution_options(resolution_ratio)


func _on_radio_21_9_pressed() -> void:
	resolution_ratio = "21_by_9"
	_populate_resolution_options(resolution_ratio)


func _on_resolution_option_item_selected(index: int) -> void:
	var resolution: Vector2i = resolution_option.get_item_metadata(index)
	DisplayServer.window_set_size(resolution)


func _on_display_option_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		2:
			pass
