extends CanvasLayer
## Screen Manager


enum Screen {
	INTRO,
	MAIN_MENU,
	SETTINGS,
	SANDBOX
}

const SCREEN_PATHS: Dictionary[Screen, String] = {
	Screen.INTRO: "res://Screens/Intro/intro.tscn",
	Screen.MAIN_MENU: "res://Screens/MainMenu/main_menu.tscn",
	Screen.SETTINGS: "res://Screens/Settings/settings.tscn",
	Screen.SANDBOX: "res://Screens/Sandbox/sandbox.tscn"
}

func go_to_screen(screen: Screen) -> void:
	var path: String = SCREEN_PATHS[screen]
	get_tree().change_scene_to_file(path)
