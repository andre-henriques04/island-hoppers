extends Control

const Progress = preload("res://scripts/session_progress.gd")
var _starting := false


func _ready() -> void:
	$CompletionStatus.visible = Progress.is_complete(&"tutorial")


func _on_play_button_pressed() -> void:
	if _starting:
		return
	_starting = true
	get_tree().change_scene_to_file("res://scenes/main.tscn")
