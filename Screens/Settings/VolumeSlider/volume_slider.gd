class_name VolumeSlider
extends VBoxContainer


@export var slider_name: String
@export var bus_name: String

var bus_index: int

@onready var name_label: Label = $Name_Label
@onready var volume_slider: HSlider = %Volume_Slider
@onready var volume_value: Label = %Volume_Value


func _ready() -> void:
	name_label.text = slider_name
	bus_index = AudioServer.get_bus_index(bus_name)
	volume_slider.value_changed.connect(_on_value_changed)


func _on_value_changed(value:float) -> void:
	AudioServer.set_bus_volume_linear(bus_index, value)
	volume_value.text = str(int(round(value * 100)))
