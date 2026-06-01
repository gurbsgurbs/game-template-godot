class_name VolumeSlider
extends VBoxContainer


@export var slider_name: String
@export var bus_code: String

@onready var name_label: Label = $Name_Label
@onready var volume_slider: HSlider = %Volume_Slider
@onready var volume_value: Label = %Volume_Value


func _ready() -> void:
	name_label.text = slider_name
	volume_slider.value_changed.connect(_on_value_changed)


func _on_value_changed(value:float) -> void:
	AudioManager.call("set_" + bus_code + "_volume", value)
	volume_value.text = str(int(round(value * 100)))
	SettingsManager.settings.set_value("Audio", bus_code + "_volume", value)
	
