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

const DEFAULT_FADE_DURATION: float = 3.0

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
	else:
		_play_music_crossfade(music_path, fade_duration)


func stop_music(fade_duration: float = DEFAULT_FADE_DURATION) -> void:
	# No music playing
	if music_active_player.playing == false:
		return
	
	# Stop immediately
	if fade_duration <= 0.0:
		if fade_tween != null and fade_tween.is_valid():
			_kill_fade_tween()
		_music_stop_all_players()
		return
	
	# Crossfade is happening (fade_duration is ignored)
	if fade_tween != null and fade_tween.is_valid():
		_music_resolve_crossfade()
		return
	
	# Stop with a fade
	fade_tween = create_tween()
	fade_tween.tween_property(music_active_player, "volume_linear", VOLUME_SILENT, fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	fade_tween.tween_callback(
		func():
			_music_stop_all_players()
			_kill_fade_tween()
	)


func pause_music() -> void:
	if music_active_player.playing == true:
		music_active_player.stream_paused = true


func resume_music() -> void:
	if music_active_player.stream_paused == true:
		music_active_player.stream_paused = false


func is_music_playing() -> bool:
	if music_active_player.playing == true and music_active_player.stream_paused == false:
		return true
	else:
		return false



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
	
	if fade_tween != null and fade_tween.is_valid():
		_kill_fade_tween()
	_music_stop_all_players()
	
	music_active_player = music_player_a
	music_player_a.volume_linear = VOLUME_FULL
	music_player_a.stream = load(music_path)
	music_player_a.play()


func _play_music_crossfade(music_path: String, fade_duration: float) -> void:
	var fade_in_player: AudioStreamPlayer = _get_music_inactive_player()
	var fade_out_player: AudioStreamPlayer = music_active_player
	
	# If a crossfade is already running, resort to a "flush and play from scratch"
	if fade_tween != null and fade_tween.is_valid():
		_music_resolve_crossfade(music_path, fade_duration)
		return
	
	fade_in_player.stream = load(music_path)
	fade_in_player.volume_linear = VOLUME_SILENT
	fade_in_player.play()
	
	music_active_player = fade_in_player
	
	fade_tween = create_tween()
	fade_tween.tween_property(fade_out_player, "volume_linear", VOLUME_SILENT, fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	fade_tween.parallel().tween_property(fade_in_player, "volume_linear", VOLUME_FULL, fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	fade_tween.tween_callback(
		func():
			fade_out_player.stop()
			fade_out_player.volume_linear = VOLUME_SILENT
			_kill_fade_tween()
	)


func _music_resolve_crossfade(music_path: String = "", fade_duration: float = 0.0) -> void:
	_kill_fade_tween()
	
	fade_tween = create_tween()
	fade_tween.tween_property(music_player_a, "volume_linear", VOLUME_SILENT, DEFAULT_FADE_DURATION / 4)
	fade_tween.parallel().tween_property(music_player_b, "volume_linear", VOLUME_SILENT, DEFAULT_FADE_DURATION / 4)
	fade_tween.tween_callback(
		func():
			_music_stop_all_players()
			_kill_fade_tween()
			if music_path != "":
				_play_music_crossfade(music_path, fade_duration)
	)
	


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


func _kill_fade_tween() -> void:
	fade_tween.kill()
	fade_tween = null

#endregion
