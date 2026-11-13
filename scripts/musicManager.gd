
extends Node

var current_music: AudioStream

var music_player: AudioStreamPlayer

func _ready():
	music_player = AudioStreamPlayer.new()
	add_child(music_player)

func play_music(music: AudioStream, volume: float = 0.0):
	if music_player.stream == music and music_player.playing:
		music_player.volume_db = volume
		return

	current_music = music
	music_player.stream = music
	music_player.volume_db = volume
	music_player.play()
