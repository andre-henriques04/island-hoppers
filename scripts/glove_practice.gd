extends Node2D
## Reuses the actual tutorial bunny without keeping a second player definition.

func _ready() -> void:
	var tutorial := preload("res://scenes/main.tscn").instantiate()
	var player := tutorial.get_node("CharacterBody2D") as CharacterBody2D
	tutorial.remove_child(player)
	tutorial.free()
	player.position = Vector2(400, 300)
	add_child(player)


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		get_tree().reload_current_scene()
