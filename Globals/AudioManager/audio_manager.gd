extends Node
## Audio Manager
## Uses three buses: Master, SoundEffects and Music


#region MUSIC & SOUND LIBRARIES

enum Music {
	THEME_TEST,
	THEME_2_TEST,
}

enum SoundEffects {
	UI_BUTTON_CLICK
}

const  MUSIC_TRACKS: Dictionary[Music, String] = {
	Music.THEME_TEST: "res://Assets/Test/music.wav",
	Music.THEME_2_TEST: "res://Assets/Test/music_2.wav"
}

const SFX_AUDIOS: Dictionary[SoundEffects, String] = {
	SoundEffects.UI_BUTTON_CLICK: "res://Assets/Test/sfx.wav",
}

#endregion

const DEFAULT_FADE_DURATION: float = 2.0

const VOLUME_SILENT: float = 0.0
const VOLUME_FULL: float = 1.0

var music_current_track: Music
var music_active_player: AudioStreamPlayer
var fade_tween: Tween

@onready var music_player_a: AudioStreamPlayer = %MusicPlayerA
@onready var music_player_b: AudioStreamPlayer = %MusicPlayerB
@onready var audio_player: AudioStreamPlayer = %AudioPlayer





func _ready() -> void:
	music_player_a.volume_linear = 0.0
	music_player_b.volume_linear = 0.0
	music_active_player = music_player_a




func play_music(track: Music, fade_duration: float = DEFAULT_FADE_DURATION) -> void:
	
	# End function if same music is already playing
	if track == music_current_track and music_active_player.playing:
		return
	else:
		music_current_track = track
	
	var music_path: String = MUSIC_TRACKS[track]
	
	if fade_duration <= 0.0:
		_play_music_instantly(music_path)
		print("music playing")
	else:
		_play_music_crossfade(music_path, fade_duration)
	

#region BUS VOLUME FUNCTIONS

func set_master_volume(volume: float) -> void:
	_set_bus_volume("Master", volume)


func set_sfx_volume(volume: float) -> void:
	_set_bus_volume("SoundEffects", volume)


func set_music_volume(volume: float) -> void:
	_set_bus_volume("Music", volume)


func get_master_volume() -> float:
	return _get_bus_volume("Master")


func get_sfx_volume() -> float:
	return _get_bus_volume("SoundEffects")


func get_music_volume() -> float:
	return _get_bus_volume("Music")

#endregion


#region MASTER MUTE FUNCTIONS

func set_master_mute(mute: bool) -> void:
	AudioServer.set_bus_mute(0, mute)


func is_master_mute() -> bool:
	return AudioServer.is_bus_mute(0)

#endregion


#region HELPER FUNCTIONS

func _set_bus_volume(bus_name: String, volume: float) -> void:
	var bus_id = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_linear(bus_id, volume)


func _get_bus_volume(bus_name: String) -> float:
	var bus_id = AudioServer.get_bus_index(bus_name)
	return AudioServer.get_bus_volume_linear(bus_id)


func _play_music_instantly(music_path: String) -> void:
	_music_stop_all_players()
	music_active_player = music_player_a
	music_player_a.volume_linear = VOLUME_FULL
	music_player_a.stream = load(music_path)
	music_player_a.play()


func _play_music_crossfade(music_path: String, fade_duration: float) -> void:
	var fade_in: AudioStreamPlayer = _get_music_inactive_player()
	var fade_out: AudioStreamPlayer = music_active_player
	
	fade_in.stream = load(music_path)
	fade_in.volume_linear = VOLUME_SILENT
	fade_in.play()
	

func _get_music_inactive_player() -> AudioStreamPlayer:
	if music_active_player == music_player_a:
		return music_player_b
	else:
		return music_player_a


func _music_stop_all_players() -> void:
	music_player_a.stop()
	music_player_a.volume_linear = VOLUME_SILENT
	music_player_b.stop()
	music_player_b.volume_linear = VOLUME_SILENT

#endregion
