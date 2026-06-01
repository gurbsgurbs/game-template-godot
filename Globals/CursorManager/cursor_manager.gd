extends Node

enum Cursor {
	POINTER,
	HAND,
}

const CURSOR_IMAGES: Dictionary[Cursor, String] = {
	Cursor.POINTER: "uid://jpmycgpd06p6",
	Cursor.HAND: "uid://du6phyyut8lj3",
}

var custom_cursor_enabled: bool = true


func set_custom_cursor(enable: bool) -> void:
	if enable == true:
		_enable_custom_cursor()
	else:
		_disable_custom_cursor()


func _enable_custom_cursor() -> void:
	custom_cursor_enabled = true
	Input.set_custom_mouse_cursor(load(CURSOR_IMAGES[Cursor.POINTER]))


func _disable_custom_cursor() -> void:
	custom_cursor_enabled = false
	Input.set_custom_mouse_cursor(null)
