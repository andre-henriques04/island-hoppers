
extends Node

@export var music: AudioStream
@export_range(-80.0, 6.0, 0.1) var volume_db: float = 0.0

func _ready():
	if music:
		MusicManager.play_music(music, volume_db)
